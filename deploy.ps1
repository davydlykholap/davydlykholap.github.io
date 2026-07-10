<#
  Publishes this portfolio to https://github.com/davydlykholap/davyd.github.io

  First use:
    .\deploy.ps1

  Later:
    .\deploy.ps1 -Message "Describe your update"
#>
[CmdletBinding()]
param(
    [string]$Message
)

$ErrorActionPreference = "Stop"

function Write-Status([string]$Text) {
    Write-Host "`n==> $Text" -ForegroundColor Cyan
}

function Test-Command([string]$Name) {
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

if (-not (Test-Command git)) {
    throw "Git is not installed or is not on PATH. Install it from https://git-scm.com/download/win, then run this script again."
}

$projectRoot = Split-Path -Parent $PSCommandPath
Set-Location -LiteralPath $projectRoot
$remoteUrl = "https://github.com/davydlykholap/davyd.github.io.git"

if (-not (Test-Path -LiteralPath (Join-Path $projectRoot ".git"))) {
    Write-Status "Initializing Git repository"
    git init
    git branch -M main
}

$remotes = @(git remote)
if ($remotes -notcontains "origin") {
    Write-Status "Adding GitHub remote"
    git remote add origin $remoteUrl
}
else {
    $currentRemote = git remote get-url origin
    if ($currentRemote -eq $remoteUrl) {
        # The correct destination is already configured.
    }
    else {
    Write-Warning "The existing 'origin' remote is: $currentRemote"
    $replaceRemote = Read-Host "Replace it with $remoteUrl ? (y/N)"
    if ($replaceRemote -match '^[Yy]$') {
        git remote set-url origin $remoteUrl
    }
    else {
        throw "Publishing stopped. The origin remote needs to be https://github.com/davydlykholap/davyd.github.io.git."
    }
    }
}

Write-Status "Staging site files"
git branch -M main

# Bring the local repository in sync before creating a new commit. This keeps
# edits made from GitHub's web UI from being accidentally overwritten.
Write-Status "Syncing with GitHub"
git pull origin main --no-rebase

git add --all

git diff --cached --quiet
$hasStagedChanges = $LASTEXITCODE -ne 0

if ($hasStagedChanges) {
    if ([string]::IsNullOrWhiteSpace($Message)) {
        $Message = Read-Host "Commit message (leave blank for an automatic message)"
    }
    if ([string]::IsNullOrWhiteSpace($Message)) {
        $Message = "Portfolio update - " + (Get-Date -Format "yyyy-MM-dd HH:mm")
    }
    Write-Status "Creating commit"
    git commit -m $Message
}
else {
    Write-Host "No uncommitted changes found; pushing the current main branch." -ForegroundColor Yellow
}

Write-Status "Pushing to davydlykholap/davyd.github.io"
git push --set-upstream origin main

Write-Host "`nPublished successfully." -ForegroundColor Green
Write-Host "Enable GitHub Pages in the repository settings if this is the first publish." -ForegroundColor Green
Write-Host "Repository: https://github.com/davydlykholap/davyd.github.io" -ForegroundColor Green
