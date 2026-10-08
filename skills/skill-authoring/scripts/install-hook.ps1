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

$hooks = @('pre-commit', 'pre-push')
$gitDir = Join-Path $RepoRoot '.git'
$hookDir = Join-Path $gitDir 'hooks'

Write-Output "repo root : $RepoRoot"
Write-Output "hook dir  : $hookDir"
Write-Output ("hooks     : " + ($hooks -join ', '))
Write-Output ''

if (-not (Test-Path -LiteralPath $gitDir)) { throw "not a git repository (no .git at $RepoRoot) - run 'git init' first" }

foreach ($name in $hooks) {
    $src = Join-Path $PSScriptRoot $name
    if (-not (Test-Path -LiteralPath $src)) { throw "hook source not found: $src" }
}

if ($DryRun) {
    Write-Output '[dry-run] would create the hooks folder if missing'
    foreach ($name in $hooks) {
        Write-Output ("[dry-run] would move a changed {0} aside as {0}.bak" -f $name)
        Write-Output ("[dry-run] would copy {0} into the hooks folder" -f $name)
    }
    Write-Output '[dry-run] no changes made'
    return
}

if (-not (Test-Path -LiteralPath $hookDir)) { New-Item -ItemType Directory -Force -Path $hookDir | Out-Null }

foreach ($name in $hooks) {
    $src  = Join-Path $PSScriptRoot $name
    $dest = Join-Path $hookDir $name

    if (Test-Path -LiteralPath $dest) {
        $same = ((Get-Content -LiteralPath $dest -Raw) -eq (Get-Content -LiteralPath $src -Raw))
        if ($same) {
            Write-Output "hook unchanged: $name"
            continue
        }
        $bak = "$dest.bak"
        Move-Item -LiteralPath $dest -Destination $bak -Force
        Write-Output "existing $name moved aside -> $bak"
    }
    Copy-Item -LiteralPath $src -Destination $dest -Force
    Write-Output "hook installed: $name"
}