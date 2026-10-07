<#
.SYNOPSIS
  Validates every skills/<name>/SKILL.md in this repository.

.DESCRIPTION
  Enforces the strictest subset of the rules shared by Cline 4.1.x and
  AgentSkills.io (the portable SKILL.md standard), the two runtimes this
  library targets. Checks mirror Cline's own parser:

    * no UTF-8 BOM; first bytes are "---"
    * a frontmatter block followed by a non-empty body
    * name: present, <=64 chars, lowercase/digits/single-hyphens, equals dir name
    * description: present, single-line, <=1024 chars
    * frontmatter keys limited to Cline's allow-list

  Windows PowerShell 5.1+ / PowerShell 7+. No external modules.
  Exits 0 when everything passes, 1 when any error is reported.

.EXAMPLE
  powershell -NoProfile -File tools\validate-skills.ps1
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$SkillsDir
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($SkillsDir)) {
    $SkillsDir = Join-Path (Split-Path -Parent $PSScriptRoot) 'skills'
}
$SkillsDir = [System.IO.Path]::GetFullPath($SkillsDir)

if (-not (Test-Path -LiteralPath $SkillsDir)) {
    Write-Error "Skills directory not found: $SkillsDir"
    exit 1
}

# Cline's allow-list, which is also the full portable (AgentSkills.io) field set.
$AllowedKeys = @('name', 'description', 'license', 'compatibility', 'metadata', 'allowed-tools')
# Claude Code-only keys deliberately retired for Cline compatibility.
$RetiredKeys = @('when_to_use', 'argument-hint')
$NamePattern = '^[a-z0-9]+(?:-[a-z0-9]+)*$'

$errors = New-Object System.Collections.Generic.List[string]

function Read-SkillFile {
    param([string]$Path)

    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    if ($hasBom) { $text = $text.Substring(1) }

    # Mirrors Cline's Fmn(): ^---\n (non-greedy) \n--- optional-newline rest
    $m = [regex]::Match($text, '\A---\r?\n(?<fm>[\s\S]*?)\r?\n---(?:\r?\n|$)(?<body>[\s\S]*)\z')

    $out = [pscustomobject]@{
        HasBom         = $hasBom
        HasFrontmatter = $m.Success
        Body           = ''
        Lines          = @()
        Values         = @{}
    }
    if (-not $m.Success) { return $out }

    $out.Body = $m.Groups['body'].Value

    $lines = New-Object System.Collections.Generic.List[string]
    $values = @{}
    foreach ($line in ($m.Groups['fm'].Value -split "`r?`n")) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        # Indented lines are content nested under a mapping key; their sub-keys
        # are not validated, but they must not look like top-level keys.
        if ($line -match '^[ \t]+') { continue }

        $lines.Add($line)
        $km = [regex]::Match($line, '^(?<k>[A-Za-z0-9_-]+):[ \t]*(?<v>.*)$')
        if (-not $km.Success) { continue }

        $v = $km.Groups['v'].Value
        if ($v.Length -ge 2) {
            $first = $v[0]
            if (($first -eq '"' -or $first -eq "'") -and $v[$v.Length - 1] -eq $first) {
                $v = $v.Substring(1, $v.Length - 2)
            }
        }
        $values[$km.Groups['k'].Value] = $v
    }

    $out.Lines = $lines
    $out.Values = $values
    return $out
}

$skillDirs = @(Get-ChildItem -LiteralPath $SkillsDir -Directory | Sort-Object Name)
if ($skillDirs.Count -eq 0) {
    $errors.Add("No skill directories found under $SkillsDir")
}

foreach ($dir in $skillDirs) {
    $name = $dir.Name
    $file = Join-Path $dir.FullName 'SKILL.md'

    if (-not (Test-Path -LiteralPath $file)) {
        $errors.Add("${name}: missing SKILL.md")
        continue
    }

    $s = Read-SkillFile -Path $file

    if ($s.HasBom) {
        $errors.Add("${name}: starts with a UTF-8 BOM; Cline requires '---' at byte 0")
    }
    if (-not $s.HasFrontmatter) {
        $errors.Add("${name}: must start with a YAML frontmatter block delimited by '---'")
        continue
    }
    if ([string]::IsNullOrWhiteSpace($s.Body)) {
        $errors.Add("${name}: empty body (instructions are required)")
    }

    foreach ($line in $s.Lines) {
        if ($line -notmatch '^[A-Za-z0-9_-]+:[ \t]*') {
            $errors.Add("${name}: unrecognised frontmatter line -> $line")
        }
    }

    foreach ($k in $s.Values.Keys) {
        if ($RetiredKeys -contains $k) {
            $errors.Add("${name}: '$k' is Claude Code-only and invisible to Cline; fold it into 'description'")
        }
        elseif (-not ($AllowedKeys -contains $k)) {
            $errors.Add("${name}: unexpected frontmatter key '$k' (allowed: $($AllowedKeys -join ', '))")
        }
    }

    if (-not $s.Values.ContainsKey('name')) {
        $errors.Add("${name}: missing required frontmatter key 'name'")
    }
    else {
        $n = $s.Values['name'].Trim()
        if ($n.Length -eq 0) { $errors.Add("${name}: 'name' must not be empty") }
        if ($n.Length -gt 64) { $errors.Add("${name}: 'name' is $($n.Length) chars (max 64)") }
        if ($n -notmatch $NamePattern) {
            $errors.Add("${name}: 'name' '$n' must be lowercase letters, digits and single hyphens only")
        }
        if ($n -cne $name) { $errors.Add("${name}: 'name' '$n' must exactly match the directory name '$name'") }
    }

    if (-not $s.Values.ContainsKey('description')) {
        $errors.Add("${name}: missing required frontmatter key 'description'")
    }
    else {
        $d = $s.Values['description'].Trim()
        if ($d.Length -eq 0) { $errors.Add("${name}: 'description' must not be empty") }
        elseif ($d -eq '|' -or $d -eq '>') { $errors.Add("${name}: use a single-line 'description' scalar") }
        elseif ($d.Length -gt 1024) { $errors.Add("${name}: 'description' is $($d.Length) chars (max 1024)") }
    }
}

if ($errors.Count -eq 0) {
    Write-Output "OK  $($skillDirs.Count) skill(s) validated under $SkillsDir"
}
else {
    Write-Output "FAILED  $($errors.Count) error(s) across $($skillDirs.Count) skill(s):"
    foreach ($e in $errors) { Write-Output "  - $e" }
    exit 1
}

exit 0
