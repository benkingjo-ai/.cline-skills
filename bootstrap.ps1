<#
.SYNOPSIS
  Sets up the skills library on a new PC.

.DESCRIPTION
  Links $env:USERPROFILE\.cline\skills to the skills folder kept in OneDrive, installs the
  pre-commit hook, runs the skills check, and prints the Cline settings that still have to
  be set by hand.

  No username is hard-coded: every path is derived from $env:USERPROFILE or from -SkillsPath.

  The junction is REFUSED when $env:USERPROFILE\.cline\skills already exists as a real
  folder, because linking over it would hide the skills Cline is already using.

.PARAMETER SkillsPath
  The skills folder to link to. The office PC path is:
    "$env:USERPROFILE\OneDrive - <tenant>\01 Documents\Github Projects\.cline\skills"

.PARAMETER DryRun
  Print every action without changing anything.

.EXAMPLE
  powershell -NoProfile -File bootstrap.ps1 -DryRun -SkillsPath "$env:USERPROFILE\OneDrive - <tenant>\01 Documents\Github Projects\.cline\skills"
#>
[CmdletBinding()]
param(
    [Parameter()][string]$SkillsPath,
    [Parameter()][switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$RepoRoot    = $PSScriptRoot
$LinkPath    = Join-Path $env:USERPROFILE '.cline\skills'
$LinkParent  = Join-Path $env:USERPROFILE '.cline'
$CheckBat    = Join-Path $RepoRoot 'check.bat'
$InstallHook = Join-Path $RepoRoot 'skill-authoring\scripts\install-hook.ps1'
$RulePath    = Join-Path $RepoRoot 'skill-authoring\docs\skills-governance-rule.md'

Write-Output '== skills bootstrap =='
Write-Output "repo root : $RepoRoot"
Write-Output "link path : $LinkPath"
Write-Output "target    : $(if ($SkillsPath) { $SkillsPath } else { '<not given>' })"
Write-Output "dry run   : $([bool]$DryRun)"
Write-Output ''

if ([string]::IsNullOrWhiteSpace($SkillsPath)) {
    Write-Output 'ERROR: -SkillsPath is required.'
    Write-Output ''
    Write-Output 'Pass the skills folder kept in OneDrive. Office PC example:'
    Write-Output '  -SkillsPath "$env:USERPROFILE\OneDrive - <tenant>\01 Documents\Github Projects\.cline\skills"'
    throw 'missing -SkillsPath'
}

$SkillsPath = [System.IO.Path]::GetFullPath($SkillsPath)
if (-not (Test-Path -LiteralPath $SkillsPath)) { throw "skills folder not found: $SkillsPath" }
if (-not (Test-Path -LiteralPath (Join-Path $SkillsPath 'skill-authoring\SKILL.md'))) {
    throw "does not look like a skills folder (no skill-authoring\SKILL.md): $SkillsPath"
}

Write-Output '== 1. junction =='
$existing = Get-Item -LiteralPath $LinkPath -Force -ErrorAction SilentlyContinue
if ($existing) {
    $isLink = ($existing.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0
    if (-not $isLink) {
        Write-Output "REFUSING: $LinkPath exists and is a REAL folder, not a link."
        Write-Output 'Move or rename it first - linking over it would hide the skills Cline is using.'
        throw 'real folder in the way'
    }
    $current = @($existing.Target)[0]
    Write-Output "link already exists -> $current"
    if ($current -ne $SkillsPath) { throw "link points elsewhere: $current" }
    Write-Output 'link target matches - left alone'
}
elseif ($DryRun) {
    Write-Output "[dry-run] would create $LinkParent if missing"
    Write-Output "[dry-run] would create the junction $LinkPath -> $SkillsPath"
}
else {
    if (-not (Test-Path -LiteralPath $LinkParent)) { New-Item -ItemType Directory -Force -Path $LinkParent | Out-Null }
    New-Item -ItemType Junction -Path $LinkPath -Target $SkillsPath | Out-Null
    Write-Output "junction created -> $SkillsPath"
}

Write-Output ''
Write-Output '== 2. pre-commit hook =='
if ($DryRun) {
    & powershell -NoProfile -ExecutionPolicy Bypass -File $InstallHook -RepoRoot $RepoRoot -DryRun
}
else {
    & powershell -NoProfile -ExecutionPolicy Bypass -File $InstallHook -RepoRoot $RepoRoot
}

Write-Output ''
Write-Output '== 3. skills check =='
if ($DryRun) {
    Write-Output "[dry-run] would run $CheckBat"
}
else {
    $null | & $CheckBat
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