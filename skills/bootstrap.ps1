<#
.SYNOPSIS
  Finishes skills setup on a PC where link-cline-skills.bat has already run.

.DESCRIPTION
  Verifies that the junction $env:USERPROFILE\.cline\skills points at this skills folder,
  installs the pre-commit hook, runs check.bat, and prints the Cline settings that still
  have to be set by hand.

  The junction is created by link-cline-skills.bat in the .cline folder. This script never
  creates, moves or edits it - it only verifies it.

  No username is hard-coded: every path is derived from $env:USERPROFILE or from -SkillsPath.

.PARAMETER SkillsPath
  The folder the junction is expected to point at. Defaults to the folder this script lives
  in. The office PC junction points at:
    "$env:USERPROFILE\OneDrive - <tenant>\Documents\VS Code\.cline\skills"

.PARAMETER DryRun
  Print every action without changing anything.

.EXAMPLE
  powershell -NoProfile -File bootstrap.ps1 -DryRun
#>
[CmdletBinding()]
param(
    [Parameter()][string]$SkillsPath,
    [Parameter()][switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$RepoRoot    = $PSScriptRoot
$LinkPath    = Join-Path $env:USERPROFILE '.cline\skills'
$CheckBat    = Join-Path $RepoRoot 'check.bat'
$InstallHook = Join-Path $RepoRoot 'skill-authoring\scripts\install-hook.ps1'
$RulePath    = Join-Path $RepoRoot 'skill-authoring\docs\skills-governance-rule.md'

if ([string]::IsNullOrWhiteSpace($SkillsPath)) { $SkillsPath = $RepoRoot }
$SkillsPath = [System.IO.Path]::GetFullPath($SkillsPath)

Write-Output '== skills bootstrap (run after link-cline-skills.bat) =='
Write-Output "this folder : $RepoRoot"
Write-Output "junction    : $LinkPath"
Write-Output "expected at : $SkillsPath"
Write-Output "dry run     : $([bool]$DryRun)"
Write-Output ''

Write-Output '== 1. verify the link(s) to this skills folder =='
if (-not (Test-Path -LiteralPath (Join-Path $SkillsPath 'skill-authoring\SKILL.md'))) {
    throw "not a skills folder (no skill-authoring\SKILL.md): $SkillsPath"
}

$link = Get-Item -LiteralPath $LinkPath -Force -ErrorAction SilentlyContinue
if (-not $link) {
    throw "no skills folder at $LinkPath - run link-cline-skills.bat (single junction) or tools\install-skills.ps1 (per-skill junctions) first"
}
$isLink = ($link.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0

# Resolve a path through any reparse points so a junction alias and its real target
# compare equal. Without this, running the script via the junction reports a false mismatch.
function Get-RealPath {
    param([string]$Path)
    $p = $Path
    for ($i = 0; $i -lt 8; $i++) {
        $it = Get-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue
        if (-not $it) { return $p }
        $isRp = ($it.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0
        $tgt  = [string]@($it.Target)[0]
        if ($isRp -and $tgt) { $p = $tgt; continue }
        return $it.FullName
    }
    return $p
}

$normWant = (Get-RealPath $SkillsPath).TrimEnd('\')

if ($isLink) {
    # Layout A - one junction whose target is this skills folder (link-cline-skills.bat)
    $target = [string]@($link.Target)[0]
    Write-Output "single junction -> $target"
    $normTarget = (Get-RealPath $LinkPath).TrimEnd('\')
    if ($normTarget -ne $normWant) {
        Write-Output "MISMATCH - the junction points at: $normTarget"
        Write-Output "but this repo is:                    $normWant"
        throw 'junction points at a different folder'
    }
    Write-Output 'single junction points at this skills folder - OK'
}
else {
    # Layout B - a real folder holding one junction per skill (tools\install-skills.ps1)
    $entries = @(Get-ChildItem -LiteralPath $LinkPath -Directory -Force -ErrorAction SilentlyContinue)
    if ($entries.Count -eq 0) {
        throw "$LinkPath is a real folder with no per-skill junctions - run link-cline-skills.bat or tools\install-skills.ps1"
    }
    $bad = @()
    foreach ($e in $entries) {
        $eIsLink = ($e.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0
        $eWant   = (Get-RealPath (Join-Path $SkillsPath $e.Name)).TrimEnd('\')
        $eHave   = ''
        if ($eIsLink) { $eHave = (Get-RealPath $e.FullName).TrimEnd('\') }
        if (-not $eIsLink -or $eHave -ne $eWant) { $bad += $e.Name }
    }
    if ($bad.Count -gt 0) {
        Write-Output ("MISMATCH - entries not tracking this repo: " + ($bad -join ', '))
        throw 'not every per-skill entry is a junction into this repo'
    }
    Write-Output ("per-skill junctions - all {0} entries track this skills folder - OK" -f $entries.Count)
}

Write-Output ''
Write-Output '== 2. pre-commit hook =='
if ($DryRun) {
    & powershell -NoProfile -ExecutionPolicy Bypass -File $InstallHook -DryRun
}
else {
    & powershell -NoProfile -ExecutionPolicy Bypass -File $InstallHook
}

Write-Output ''
Write-Output '== 3. skills check =='
if ($DryRun) {
    Write-Output "[dry-run] would run $CheckBat"
}
else {
    cmd /c ('"' + $CheckBat + '" < nul')
    Write-Output "check exit = $LASTEXITCODE"
}

Write-Output ''
Write-Output '== 4. Cline settings to set by hand =='
Write-Output '  [ ] Global rules: ON  (so skills-governance applies to every task)'
Write-Output '  [ ] Auto-approve: OFF for the skills folder'
Write-Output '  [ ] Global rule: copy'
Write-Output "        $RulePath"
Write-Output '      into Cline -> Settings -> Global rules, then reload'
Write-Output '  [ ] Start a new chat and confirm Cline sees the skills'
Write-Output ''
Write-Output 'done'