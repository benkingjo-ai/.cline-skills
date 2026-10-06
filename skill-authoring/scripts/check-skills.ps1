<#
.SYNOPSIS
  Reports one OK/FAIL line per skill, a token budget and a duplicate report.

.DESCRIPTION
  Library-level checker for the global skills folder. Runs the format checks Cline's
  parser enforces (no UTF-8 BOM, '---' at byte 0, frontmatter block, name, description,
  allowed keys) and adds:

    * one OK / FAIL line per skill
    * a token budget: description tokens (always-on), SKILL.md tokens (on-trigger),
      docs and scripts tokens (on-demand), totals, largest SKILL.md files and warnings
    * a duplicate report: description overlap (near) and duplicated SKILL.md lines
      (exact), each priced with the tokens wasted by the copies
    * a link check for relative docs and scripts references

  Tokens are estimated as characters / 4.

  A skill marks a duplicate as intentional with a body comment:
      <!-- duplicate-ok: reason -->

  Read-only. Windows PowerShell 5.1+ / PowerShell 7+. No external modules.
  Exits 0 when every skill passes, 1 otherwise.

.EXAMPLE
  powershell -NoProfile -File skills\skill-authoring\scripts\check-skills.ps1
#>
[CmdletBinding()]
param(
    [Parameter()][string]$SkillsDir,
    [Parameter()][double]$OverlapThreshold = 0.60,
    [Parameter()][int]$DescTokenLimit = 60
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($SkillsDir)) {
    # skills\skill-authoring\scripts\ -> skills\
    $SkillsDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
}
$SkillsDir = [System.IO.Path]::GetFullPath($SkillsDir)

if (-not (Test-Path -LiteralPath $SkillsDir)) {
    Write-Error "Skills directory not found: $SkillsDir"
    exit 1
}

$AllowedKeys     = @('name', 'description', 'license', 'compatibility', 'metadata', 'allowed-tools')
$RetiredKeys     = @('when_to_use', 'argument-hint')
$NamePattern     = '^[a-z0-9]+(?:-[a-z0-9]+)*$'
$MaxTokens       = 5000
$AlwaysOnLimit   = 1500
$MinDupLineChars = 45
$NamingFile = Join-Path (Split-Path -Parent $PSScriptRoot) 'docs\naming.md'
$RegistryFile = Join-Path (Split-Path -Parent $PSScriptRoot) 'docs\registry.md'

$StopWords = @(
    'the','and','for','any','are','use','used','using','this','that','these','those',
    'with','when','from','into','its','it','a','an','as','at','be','by','can','do',
    'does','if','in','is','not','of','on','or','to','up','also','all','more','most',
    'must','should','will','would','you','your','but','before','after','where','which',
    'while','than','then','there','they','them','their','only','other','such','just',
    'like','one','out','over','own','same','so','was','were','has','have'
)

function Read-SkillFile {
    param([string]$Path)

    $bytes  = [System.IO.File]::ReadAllBytes($Path)
    $hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    $text   = [System.Text.Encoding]::UTF8.GetString($bytes)
    if ($hasBom) { $text = $text.Substring(1) }

    $m = [regex]::Match($text, '\A---\r?\n(?<fm>[\s\S]*?)\r?\n---(?:\r?\n|$)(?<body>[\s\S]*)\z')

    $out = [pscustomobject]@{
        HasBom = $hasBom; HasFrontmatter = $m.Success; Body = ''; Lines = @(); Values = @{}
    }
    if (-not $m.Success) { return $out }

    $out.Body = $m.Groups['body'].Value
    $lines    = New-Object System.Collections.Generic.List[string]
    $values   = @{}
    foreach ($line in ($m.Groups['fm'].Value -split "`r?`n")) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        if ($line -match '^[ \t]+') { continue }
        $lines.Add($line)
        $km = [regex]::Match($line, '^(?<k>[A-Za-z0-9_-]+):[ \t]*(?<v>.*)$')
        if (-not $km.Success) { continue }
        $v = $km.Groups['v'].Value
        if ($v.Length -ge 2) {
            $q = $v[0]
            if (($q -eq '"' -or $q -eq "'") -and $v[$v.Length - 1] -eq $q) { $v = $v.Substring(1, $v.Length - 2) }
        }
        $values[$km.Groups['k'].Value] = $v
    }
    $out.Lines  = $lines
    $out.Values = $values
    return $out
}

function Get-MeaningfulWords {
    param([string]$Text)
    $clean = ($Text.ToLowerInvariant() -replace '[^a-z0-9\- ]', ' ')
    $words = @($clean -split '\s+' | Where-Object { $_.Length -gt 2 -and ($StopWords -notcontains $_) })
    return @($words | Sort-Object -Unique)
}

function Get-TokenCount {
    param([string]$Text)
    if ([string]::IsNullOrEmpty($Text)) { return 0 }
    return [int][math]::Ceiling($Text.Length / 4.0)
}

function Get-ApprovedPrefixes {
    param([string]$Path)
    $list = New-Object System.Collections.Generic.List[string]
    if (-not (Test-Path -LiteralPath $Path)) { return $list }
    $inside = $false
    foreach ($line in (Get-Content -LiteralPath $Path)) {
        if ($line -match '^\s*<!--\s*prefixes:start\s*-->') { $inside = $true; continue }
        if ($line -match '^\s*<!--\s*prefixes:end\s*-->')   { $inside = $false; continue }
        if (-not $inside) { continue }
        $m = [regex]::Match($line, '^\s*-\s*`([a-z0-9]+-)`')
        if ($m.Success) { $list.Add($m.Groups[1].Value) }
    }
    return $list
}

function Get-RegistryRules {
    param([string]$Path)
    $rows = New-Object System.Collections.Generic.List[object]
    if (-not (Test-Path -LiteralPath $Path)) { return $rows }
    $inside = $false
    foreach ($line in (Get-Content -LiteralPath $Path)) {
        if ($line -match '^\s*<!--\s*registry:start\s*-->') { $inside = $true; continue }
        if ($line -match '^\s*<!--\s*registry:end\s*-->')   { $inside = $false; continue }
        if (-not $inside) { continue }
        if ($line -notmatch '^\s*\|') { continue }
        $body = $line.Trim()
        if ($body.StartsWith('|')) { $body = $body.Substring(1) }
        if ($body.EndsWith('|'))   { $body = $body.Substring(0, $body.Length - 1) }
        $c = @($body -split '\|' | ForEach-Object { $_.Trim().Trim([char]0x60) })
        if ($c.Count -lt 4) { continue }
        if ($c[0] -eq 'rule (literal anchor)') { continue }
        if ($c[0] -match '^-+$') { continue }
        $rows.Add([pscustomobject]@{ Rule = $c[0]; Owner = $c[1]; File = $c[2] })
    }
    return $rows
}

function Get-FolderTokens {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return 0 }
    $sum = (Get-ChildItem -LiteralPath $Path -Recurse -File -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum).Sum
    if (-not $sum) { return 0 }
    return [int][math]::Ceiling($sum / 4.0)
}
$skillDirs = @(Get-ChildItem -LiteralPath $SkillsDir -Directory |
    Where-Object { $_.Name -notlike '.*' } | Sort-Object Name)
$failed        = 0
$descWords     = @{}
$descTokensMap = @{}
$ApprovedPrefixes = Get-ApprovedPrefixes -Path $NamingFile
$namingViolations = New-Object System.Collections.Generic.List[string]
$RegistryRules = Get-RegistryRules -Path $RegistryFile
$registryBad = 0
$budget        = New-Object System.Collections.Generic.List[object]
$lineIndex     = @{}
$intentional   = @{}

Write-Output '=== Skill checks ==='
foreach ($dir in $skillDirs) {
    $name       = $dir.Name
    $file       = Join-Path $dir.FullName 'SKILL.md'
    $errs       = New-Object System.Collections.Generic.List[string]
    $tokText    = ''
    $descTokens = 0; $skillTokens = 0; $docsTokens = 0; $scriptsTokens = 0

    if (-not (Test-Path -LiteralPath $file)) {
        $errs.Add('missing SKILL.md')
    }
    else {
        $s = Read-SkillFile -Path $file

        if ($s.HasBom)                             { $errs.Add("starts with a UTF-8 BOM; Cline requires '---' at byte 0") }
        if (-not $s.HasFrontmatter)                { $errs.Add("must start with YAML frontmatter delimited by '---'") }
        if ([string]::IsNullOrWhiteSpace($s.Body)) { $errs.Add('empty body (instructions are required)') }

        foreach ($line in $s.Lines) {
            if ($line -notmatch '^[A-Za-z0-9_-]+:[ \t]*') { $errs.Add("unrecognised frontmatter line -> $line") }
        }
        foreach ($k in $s.Values.Keys) {
            if ($RetiredKeys -contains $k)        { $errs.Add("'$k' is Claude Code-only and invisible to Cline; fold it into 'description'") }
            elseif ($AllowedKeys -notcontains $k) { $errs.Add("unexpected frontmatter key '$k'") }
        }

        if (-not $s.Values.ContainsKey('name')) { $errs.Add("missing required key 'name'") }
        else {
            $n = $s.Values['name'].Trim()
            if ($n.Length -eq 0)           { $errs.Add("'name' must not be empty") }
            if ($n.Length -gt 64)          { $errs.Add("'name' is $($n.Length) chars (max 64)") }
            if ($n -notmatch $NamePattern) { $errs.Add("'name' '$n' must be lowercase letters, digits and single hyphens only") }
            if ($n -cne $name)             { $errs.Add("'name' '$n' must exactly match the directory name '$name'") }
            $segs = @($n.Split('-'))
            if ($segs.Count -lt 2) {
                $errs.Add("naming: '$n' is a single word; use <category>-<topic>")
                $namingViolations.Add("$n : single word; use <category>-<topic>")
            }
            elseif ($ApprovedPrefixes.Count -gt 0 -and ($ApprovedPrefixes -notcontains ($segs[0] + '-'))) {
                $errs.Add("naming: '$n' does not start with an approved prefix")
                $namingViolations.Add("$n : prefix '$($segs[0])-' is not on the approved list")
            }
            if ($segs.Count -gt 4) {
                $errs.Add("naming: '$n' is $($segs.Count) words (max 4)")
                $namingViolations.Add("$n : $($segs.Count) words (max 4)")
            }
        }

        if (-not $s.Values.ContainsKey('description')) { $errs.Add("missing required key 'description'") }
        else {
            $d = $s.Values['description'].Trim()
            if ($d.Length -eq 0)               { $errs.Add("'description' must not be empty") }
            elseif ($d -eq '|' -or $d -eq '>') { $errs.Add("use a single-line 'description' scalar") }
            elseif ($d.Length -gt 1024)        { $errs.Add("'description' is $($d.Length) chars (max 1024)") }
            $descWords[$name]     = Get-MeaningfulWords -Text $d
            $descTokens           = Get-TokenCount -Text $d
            $descTokensMap[$name] = $descTokens
        }

        $skillTokens = Get-TokenCount -Text $s.Body
        if ($skillTokens -gt $MaxTokens) { $errs.Add("SKILL.md is ~$skillTokens tokens; move detail into docs\") }
        $tokText       = "~$skillTokens tokens"
        $docsTokens    = Get-FolderTokens -Path (Join-Path $dir.FullName 'docs')
        $scriptsTokens = Get-FolderTokens -Path (Join-Path $dir.FullName 'scripts')

        foreach ($lm in [regex]::Matches($s.Body, '\]\((?<p>[^)]+)\)')) {
            $p = $lm.Groups['p'].Value.Trim()
            if ($p -match '^(docs|scripts)[\\/]') {
                $target = Join-Path $dir.FullName ($p -replace '/', '\')
                if (-not (Test-Path -LiteralPath $target)) { $errs.Add("link points at a missing file: $p") }
            }
        }

        $mark = [regex]::Match($s.Body, '<!--\s*duplicate-ok\s*:?\s*(?<r>[^>]*?)\s*-->')
        if ($mark.Success) { $intentional[$name] = $mark.Groups['r'].Value.Trim() }

        foreach ($ln in ($s.Body -split "`r?`n")) {
            $norm = ($ln.Trim() -replace '\s+', ' ')
            if ($norm.Length -lt $MinDupLineChars) { continue }
            if ($norm.StartsWith('#')) { continue }
            if ($norm.StartsWith('`')) { continue }
            if ($norm -match '^\|[\s\-:|]+\|$') { continue }
            if (-not $lineIndex.ContainsKey($norm)) { $lineIndex[$norm] = New-Object System.Collections.Generic.List[string] }
            if (-not $lineIndex[$norm].Contains($name)) { $lineIndex[$norm].Add($name) }
        }
    }

    $budget.Add([pscustomobject]@{ Name = $name; Desc = $descTokens; Skill = $skillTokens; Docs = $docsTokens; Scripts = $scriptsTokens })

    if ($errs.Count -eq 0) {
        Write-Output ('OK    {0,-26} {1}' -f $name, $tokText)
    }
    else {
        $failed++
        Write-Output ('FAIL  {0,-26} {1} error(s)' -f $name, $errs.Count)
        foreach ($e in $errs) { Write-Output "        - $e" }
    }
}

$names = @($descWords.Keys | Sort-Object)
$overlapRows = New-Object System.Collections.Generic.List[object]
$dupTotal    = 0

for ($i = 0; $i -lt $names.Count; $i++) {
    for ($j = $i + 1; $j -lt $names.Count; $j++) {
        $a   = $descWords[$names[$i]]
        $b   = $descWords[$names[$j]]
        $min = [math]::Min($a.Count, $b.Count)
        if ($min -eq 0) { continue }
        $shared = @($a | Where-Object { $b -contains $_ })
        $score  = [math]::Round($shared.Count / $min, 2)
        if ($score -ge $OverlapThreshold) {
            $n1 = $names[$i]
            $n2 = $names[$j]
            $wasted = [math]::Min($descTokensMap[$n1], $descTokensMap[$n2])
            $overlapRows.Add([pscustomobject]@{
                A = $n1; B = $n2; Score = $score; Wasted = $wasted
                Shared = @($shared | Select-Object -First 6)
            })
            $dupTotal += $wasted
        }
    }
}

$dupRows = New-Object System.Collections.Generic.List[object]
foreach ($k in ($lineIndex.Keys | Sort-Object)) {
    $owners = $lineIndex[$k]
    if ($owners.Count -lt 2) { continue }
    $wasted = ($owners.Count - 1) * (Get-TokenCount -Text $k)
    $dupRows.Add([pscustomobject]@{ Line = $k; Owners = @($owners); Wasted = $wasted })
    $dupTotal += $wasted
}
$dupRows = @($dupRows | Sort-Object -Property Wasted -Descending)

function Get-IntentNote {
    param([string[]]$Owners)
    foreach ($o in $Owners) {
        if ($intentional.ContainsKey($o)) { return '  [intentional: ' + $intentional[$o] + ']' }
    }
    return ''
}

$alwaysOn = 0
foreach ($b in $budget) { $alwaysOn += $b.Desc }

Write-Output ''
Write-Output '=== Token budget (est. chars / 4) ==='
Write-Output ('{0,-26}{1,7}{2,10}{3,7}{4,9}' -f 'skill', 'desc', 'skill.md', 'docs', 'scripts')
foreach ($b in ($budget | Sort-Object -Property Desc -Descending)) {
    Write-Output ('{0,-26}{1,7}{2,10}{3,7}{4,9}' -f $b.Name, $b.Desc, $b.Skill, $b.Docs, $b.Scripts)
}
Write-Output ('{0,-26}{1,7}' -f 'TOTAL always-on', $alwaysOn)

Write-Output ''
Write-Output 'Largest SKILL.md (on-trigger):'
$rank = 0
foreach ($b in ($budget | Sort-Object -Property Skill -Descending | Select-Object -First 5)) {
    $rank++
    Write-Output ('  {0}. {1,-24} ~{2} tokens' -f $rank, $b.Name, $b.Skill)
}

$warn = New-Object System.Collections.Generic.List[string]
foreach ($b in $budget) {
    if ($b.Desc -gt $DescTokenLimit) { $warn.Add(('{0}: description ~{1} tokens (limit {2})' -f $b.Name, $b.Desc, $DescTokenLimit)) }
    if ($b.Skill -gt $MaxTokens)     { $warn.Add(('{0}: SKILL.md ~{1} tokens (limit {2})' -f $b.Name, $b.Skill, $MaxTokens)) }
}
if ($alwaysOn -gt $AlwaysOnLimit) { $warn.Add(('TOTAL always-on ~{0} tokens (limit {1})' -f $alwaysOn, $AlwaysOnLimit)) }

Write-Output ''
Write-Output 'Warnings:'
if ($warn.Count -eq 0) { Write-Output '  none' } else { foreach ($w in $warn) { Write-Output "  - $w" } }

Write-Output ''
Write-Output '=== Duplicates ==='
Write-Output ('Description overlap (near, threshold {0}):' -f $OverlapThreshold)
if ($overlapRows.Count -eq 0) {
    Write-Output '  none'
}
else {
    foreach ($o in $overlapRows) {
        Write-Output ('  {0} <-> {1}   near   overlap {2}   wasted ~{3} tokens   shared: {4}{5}' -f $o.A, $o.B, $o.Score, $o.Wasted, ($o.Shared -join ', '), (Get-IntentNote -Owners @($o.A, $o.B)))
    }
}
Write-Output ('Content duplicates (exact, lines >= {0} chars):' -f $MinDupLineChars)
if ($dupRows.Count -eq 0) {
    Write-Output '  none'
}
else {
    foreach ($d in $dupRows) {
        $preview = $d.Line
        if ($preview.Length -gt 72) { $preview = $preview.Substring(0, 69) + '...' }
        Write-Output ('  x{0}   {1}   exact   wasted ~{2} tokens   {3}{4}' -f $d.Owners.Count, ($d.Owners -join ' + '), $d.Wasted, $preview, (Get-IntentNote -Owners $d.Owners))
    }
}
Write-Output ''
Write-Output ('Est. removable duplicate tokens: ~{0}  (always-on + on-trigger)' -f $dupTotal)

Write-Output ''
Write-Output '=== Naming ==='
if ($ApprovedPrefixes.Count -eq 0) {
    Write-Output '  WARNING: prefix list not read; expected docs\naming.md'
}
else {
    Write-Output ('  approved prefixes: ' + ($ApprovedPrefixes -join ', '))
}
if ($namingViolations.Count -eq 0) {
    Write-Output ('  none - all {0} name(s) conform to <category>-<topic>' -f $skillDirs.Count)
}
else {
    foreach ($v in $namingViolations) { Write-Output ('  - ' + $v) }
}

Write-Output ''
Write-Output ''
Write-Output '=== Registry ==='
if ($RegistryRules.Count -eq 0) {
    Write-Output '  WARNING: no rules read; expected docs\registry.md'
}
else {
    Write-Output ('  rules listed: ' + $RegistryRules.Count)
    foreach ($r in $RegistryRules) {
        $found  = $false
        $target = Join-Path (Join-Path $SkillsDir $r.Owner) $r.File
        if (Test-Path -LiteralPath $target) {
            if ([IO.File]::ReadAllText($target).Contains($r.Rule)) { $found = $true }
        }
        if ($found) {
            Write-Output ('  ok       {0,-34} {1}' -f $r.Rule, $r.Owner)
        }
        else {
            Write-Output ('  MISSING  {0,-34} {1}  (not found in {2}/{3})' -f $r.Rule, $r.Owner, $r.Owner, $r.File)
            $registryBad++
        }
    }
    if ($registryBad -eq 0) { Write-Output '  every rule anchor was found in its owner file' }
}

Write-Output ''
if ($failed -eq 0 -and $registryBad -eq 0) {
    Write-Output "PASS  $($skillDirs.Count) skill(s) checked under $SkillsDir"
    exit 0
}
Write-Output "FAIL  $failed of $($skillDirs.Count) skill(s) need attention; $registryBad registry anchor(s) missing"
exit 1