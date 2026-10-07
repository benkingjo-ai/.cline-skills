<#
.SYNOPSIS
  Installs the skills pre-commit hook into this repository.

.DESCRIPTION
  Copies skill-authoring\scripts\pre-commit to .git\hooks\pre-commit so every commit runs
  the skills check and is blocked when it fails. The installed hook lives in .git and is
  never committed.

  Refuses to run when there is no .git, and moves an existing hook aside as
  pre-commit.bak rather than overwriting it. Use -DryRun to see the actions first.

.EXAMPLE
  powershell -NoProfile -File skills\skill-authoring\scripts\install-hook.ps1 -DryRun
#>
[CmdletBinding()]
param(
    [Parameter()][string]$RepoRoot,
    [Parameter()][switch]$DryRun
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    # skills\skill-authoring\scripts\ -> skill-authoring -> skills -> repo root (.cline)
    $RepoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
}
$RepoRoot = [System.IO.Path]::GetFullPath($RepoRoot)

$source = Join-Path $PSScriptRoot 'pre-commit'
$gitDir = Join-Path $RepoRoot '.git'
$hooks  = Join-Path $gitDir 'hooks'
$dest   = Join-Path $hooks 'pre-commit'

Write-Output "repo root : $RepoRoot"
Write-Output "source    : $source"
Write-Output "target    : $dest"
Write-Output ''

if (-not (Test-Path -LiteralPath $source)) { throw "hook source not found: $source" }
if (-not (Test-Path -LiteralPath $gitDir)) { throw "not a git repository (no .git at $RepoRoot) - run 'git init' first" }

if ($DryRun) {
    Write-Output '[dry-run] would create the hooks folder if missing'
    Write-Output '[dry-run] would move an existing hook to pre-commit.bak'
    Write-Output '[dry-run] would copy the hook source to the target'
    Write-Output '[dry-run] no changes made'
    return
}

if (-not (Test-Path -LiteralPath $hooks)) { New-Item -ItemType Directory -Force -Path $hooks | Out-Null }
if (Test-Path -LiteralPath $dest) {
    $bak = Join-Path $hooks 'pre-commit.bak'
    Move-Item -LiteralPath $dest -Destination $bak -Force
    Write-Output "existing hook moved aside -> $bak"
}
Copy-Item -LiteralPath $source -Destination $dest -Force
Write-Output 'hook installed'