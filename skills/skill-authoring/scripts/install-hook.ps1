<#
.SYNOPSIS
  Activates this repository's Git hooks in place.
.DESCRIPTION
  Sets `core.hooksPath = .githooks` so Git runs `pre-commit` (skills audit) and
  `pre-push` (benkingjo-ai remote guard) directly from the tracked `.githooks/`
  folder. Hooks are versioned and reviewable; nothing is copied into `.git`.

  Refuses to run when there is no .git. Use -DryRun to print the intended action.
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

$hooks = @('pre-commit', 'pre-push')
$hookDir = Join-Path $RepoRoot '.githooks'

Write-Output "repo root : $RepoRoot"
Write-Output ("hooks     : " + ($hooks -join ', '))
Write-Output ''

if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot '.git'))) {
    throw "not a git repository (no .git at $RepoRoot) - run 'git init' first"
}

foreach ($name in $hooks) {
    $src = Join-Path $hookDir $name
    if (-not (Test-Path -LiteralPath $src)) { throw "hook source not found: $src" }
}

if ($DryRun) {
    Write-Output '[dry-run] would set git config core.hooksPath .githooks'
    Write-Output '[dry-run] no changes made'
    return
}

git -C $RepoRoot config core.hooksPath .githooks | Out-Null
Write-Output "core.hooksPath = .githooks  (hooks: $($hooks -join ', '))"
