# Requires -Version 5.1

# Enable strict error handling. The script will terminate if an unhandled error occurs.
$ErrorActionPreference = "Stop"

# Verification: Ensure the directory is a Git repository
if (-not (Test-Path -Path ".git")) {
    Write-Error "The current directory is not a Git repository. Please initialize Git before running this script."
    Exit 1
}

# Verification: Ensure the 'origin' remote exists
$remotes = git remote
if ($remotes -notcontains "origin") {
    Write-Error "The remote 'origin' is not configured in this repository."
    Exit 1
}

Write-Output "Checking for modifications and untracked files..."

# Fetch porcelain status to programmatically check for any changes
$gitStatus = git status --porcelain

if (-not $gitStatus) {
    Write-Output "No changes detected. The repository is already up to date."
    Exit 0
}

# Display a summarized view of modified or untracked files to the user
Write-Output "`nThe following changes will be processed:"
git status --short

# Solicit a commit message from the user
Write-Output ""
$inputMessage = Read-Host "Enter a commit message (Leave blank to use the default auto-generated message)"

# Determine the final commit message string
if ([string]::IsNullOrWhitespace($inputMessage)) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $commitMessage = "Automated deployment update - $timestamp"
} else {
    $commitMessage = $inputMessage.Trim()
}

# Execute deployment phase within a try/catch block to intercept exceptions
try {
    # Fetch and merge latest changes from remote to stay in sync
    Write-Output "`nFetching and merging latest changes from GitHub..."
    git pull origin main --no-rebase

    Write-Output "`nStaging files..."
    git add .

    Write-Output "Committing changes..."
    git commit -m "$commitMessage"

    Write-Output "Pushing changes to origin main..."
    git push origin main

    Write-Output "`nDeployment completed successfully. Changes have been pushed to GitHub."
}
catch {
    Write-Error "Deployment failed during execution. Details: $_"
    Exit 1
}