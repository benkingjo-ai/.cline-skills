<#
.SYNOPSIS
  Installs the skills in this repository into Cline's skill roots as junctions.

.DESCRIPTION
  Cline 4.1.x scans exactly these skill directories:
      project: .clinerules/skills, .cline/skills, .claude/skills, .agents/skills
      global:  ~/.cline/skills, ~/.agents/skills
  It does NOT scan ~/.claude/skills, so that location (the old install) is retired
  by -PruneClaude.

  Junctions are used rather than copies so this repository stays the single source
  of truth: edit a SKILL.md here and every target picks it up.

  Safety: nothing here ever deletes a real directory. Junction removal goes through
  Win32 RemoveDirectory(), which deletes only the reparse point and never the
  contents of the folder it points at. Every removal is guarded so it only fires on
  an entry that is a reparse point resolving into this repository's skills/ folder.

.PARAMETER Targets
  Skill roots to install into. Defaults to ~/.cline/skills and ~/.agents/skills.

.PARAMETER Remove
  Remove this repository's junctions from the targets (the repository is untouched).

.PARAMETER PruneClaude
  Additionally remove this repository's junctions from ~/.claude/skills, retiring
  the old Claude Code install.

.EXAMPLE
  powershell -NoProfile -File tools\install-skills.ps1
  powershell -NoProfile -File tools\install-skills.ps1 -PruneClaude
  powershell -NoProfile -File tools\install-skills.ps1 -Remove
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter()]
    [string[]]$Targets,

    [Parameter()]
    [switch]$Remove,

    [Parameter()]
    [switch]$PruneClaude
)

$ErrorActionPreference = 'Stop'

# --- Win32 primitive: deletes a reparse point, never its target's contents -------
if (-not ('AccessLib.Win32' -as [type])) {
    Add-Type -Namespace AccessLib -Name Win32 -MemberDefinition @'
[System.Runtime.InteropServices.DllImport("kernel32.dll", CharSet = System.Runtime.InteropServices.CharSet.Unicode, SetLastError = true)]
public static extern bool RemoveDirectory(string lpPathName);
'@
}

# --- Locate the repository -------------------------------------------------------
$RepoRoot = Split-Path -Parent $PSScriptRoot
$SkillsRoot = Join-Path $RepoRoot 'skills'

if (-not (Test-Path -LiteralPath $SkillsRoot)) {
    Write-Error "skills directory not found: $SkillsRoot"
    exit 1
}

if (-not $Targets -or $Targets.Count -eq 0) {
    $Targets = @(
        (Join-Path $env:USERPROFILE '.cline\skills'),
        (Join-Path $env:USERPROFILE '.agents\skills')
    )
}

# --- Helpers ---------------------------------------------------------------------
function Normalize-PathString {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return '' }
    try { $Path = [System.IO.Path]::GetFullPath($Path) } catch { }
    return $Path.TrimEnd('\')
}

function Get-ReparseInfo {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) { return $null }

    $item = Get-Item -LiteralPath $Path -Force
    $isReparse = ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0

    $target = ''
    if ($isReparse) {
        $tProp = $item.PSObject.Properties['Target']
        if ($tProp -and $tProp.Value) {
            $arr = @($tProp.Value)
            if ($arr.Count -gt 0) { $target = [string]$arr[0] }
        }
    }

    return [pscustomobject]@{
        Path       = $Path
        IsReparse  = $isReparse
        Target     = $target
        TargetPath = Normalize-PathString $target
    }
}

function Remove-Link {
    param([string]$Path)

    $ok = [AccessLib.Win32]::RemoveDirectory($Path)
    if (-not $ok) {
        $code = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
        throw "RemoveDirectory failed for '$Path' (Win32 error $code)"
    }
}

function Test-IsOurs {
    param([string]$TargetPath)
    $norm = Normalize-PathString $TargetPath
    if ($norm.Length -eq 0) { return $false }
    $prefix = $SkillsRoot + '\'
    return $norm.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)
}

# --- Install ---------------------------------------------------------------------
$skills = @(Get-ChildItem -LiteralPath $SkillsRoot -Directory | Sort-Object Name)
if ($skills.Count -eq 0) {
    Write-Error "No skill directories found under $SkillsRoot"
    exit 1
}

$created = 0; $unchanged = 0; $retargeted = 0; $removed = 0; $kept = 0; $skipped = 0
$failures = New-Object System.Collections.Generic.List[string]

$mode = 'install'
if ($Remove) { $mode = 'remove' }
Write-Host "Access Lib skills  ($mode)  source: $SkillsRoot" -ForegroundColor Cyan

if (-not $Remove) {
    foreach ($t in $Targets) {
        $targetRoot = Normalize-PathString $t

        if (-not (Test-Path -LiteralPath $targetRoot)) {
            if ($PSCmdlet.ShouldProcess($targetRoot, 'Create skill directory')) {
                New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null
                Write-Host "  + dir     $targetRoot"
            }
        }

        foreach ($s in $skills) {
            $link = Join-Path $targetRoot $s.Name
            $want = Normalize-PathString $s.FullName

            try {
                $info = Get-ReparseInfo -Path $link

                if ($null -eq $info) {
                    if ($PSCmdlet.ShouldProcess($link, 'Create junction')) {
                        New-Item -ItemType Junction -Path $link -Target $s.FullName | Out-Null
                        $created++
                    }
                    continue
                }

                if (-not $info.IsReparse) {
                    $skipped++
                    Write-Warning "SKIPPED '$link' exists but is not a junction; not touching it."
                    continue
                }

                if ($info.TargetPath -eq $want) {
                    $unchanged++
                    continue
                }

                if ($PSCmdlet.ShouldProcess($link, "Retarget junction -> $($s.FullName)")) {
                    Remove-Link -Path $link
                    New-Item -ItemType Junction -Path $link -Target $s.FullName | Out-Null
                    $retargeted++
                }
            }
            catch {
                $failures.Add("$link : $($_.Exception.Message)")
            }
        }
    }

    # --- Retire the old Claude Code root -----------------------------------------
    if ($PruneClaude) {
        $claudeRoot = Normalize-PathString (Join-Path $env:USERPROFILE '.claude\skills')
        if (Test-Path -LiteralPath $claudeRoot) {
            foreach ($entry in @(Get-ChildItem -LiteralPath $claudeRoot -Force)) {
                try {
                    $info = Get-ReparseInfo -Path $entry.FullName
                    if ($null -eq $info -or -not $info.IsReparse) {
                        $kept++
                        Write-Warning "KEPT '$($entry.FullName)' (not a junction)."
                        continue
                    }
                    if (-not (Test-IsOurs -TargetPath $info.Target)) {
                        $kept++
                        continue
                    }
                    if ($PSCmdlet.ShouldProcess($entry.FullName, 'Remove junction (reparse point only)')) {
                        Remove-Link -Path $entry.FullName
                        $removed++
                    }
                }
                catch {
                    $failures.Add("$($entry.FullName) : $($_.Exception.Message)")
                }
            }
        }
        else {
            Write-Host "  - nothing to prune: $claudeRoot does not exist"
        }
    }
}
else {
    # --- Remove our junctions from the targets ------------------------------------
    foreach ($t in $Targets) {
        $targetRoot = Normalize-PathString $t
        if (-not (Test-Path -LiteralPath $targetRoot)) { continue }

        foreach ($s in $skills) {
            $link = Join-Path $targetRoot $s.Name
            try {
                $info = Get-ReparseInfo -Path $link
                if ($null -eq $info -or -not $info.IsReparse) { continue }
                if ($info.TargetPath -ne (Normalize-PathString $s.FullName)) { continue }

                if ($PSCmdlet.ShouldProcess($link, 'Remove junction (reparse point only)')) {
                    Remove-Link -Path $link
                    $removed++
                }
            }
            catch {
                $failures.Add("$link : $($_.Exception.Message)")
            }
        }
    }
}

# --- Report ---------------------------------------------------------------------
Write-Host ''
if ($Remove) {
    Write-Host "removed $removed junction(s), kept $kept entry(ies) that were not ours" -ForegroundColor Green
}
else {
    Write-Host "created $created, unchanged $unchanged, retargeted $retargeted, skipped $skipped, pruned $removed, kept $kept" -ForegroundColor Green
}

if ($failures.Count -gt 0) {
    Write-Host "$($failures.Count) failure(s):" -ForegroundColor Red
    foreach ($f in $failures) { Write-Host "  - $f" -ForegroundColor Red }
    exit 1
}

exit 0

