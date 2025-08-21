# installWebtorrent.ps1 - Installs webtorrent-cli globally using npm
# This script is intended to be run with administrator privileges.

# Define parameters that can be passed to the script
param(
    [Parameter(Mandatory=$true)]
    [string]$npmFullPath
)

Write-Host "============================================="
Write-Host "WebTorrent CLI Installation Script"
Write-Host "This requires administrator privileges."
Write-Host "============================================="
Write-Host ""

# Pre-requisite check for npm using the provided path
Write-Host "Checking for npm at the provided path: $npmFullPath"
if (-not (Test-Path $npmFullPath)) {
    Write-Error "The provided path to npm.cmd is invalid: '$npmFullPath'."
    Write-Error "Cannot proceed with installation."
    pause
    exit 1
}

Write-Host "Found npm. Attempting to install webtorrent-cli globally..."
Write-Host "This may take a minute..."

try {
    # Execute npm install command using the full path. The '&' is the call operator.
    # It's needed to execute commands from a path stored in a variable, especially if it contains spaces.
    & $npmFullPath install webtorrent-cli -g

    # Check the exit code of the last command
    if ($LASTEXITCODE -eq 0) {
        Write-Host "webtorrent-cli has been installed globally with npm."
    } else {
        Write-Error "npm failed to install webtorrent-cli. Exit code: $LASTEXITCODE"
        Write-Error "Please try running 'npm install webtorrent-cli -g' manually in an administrator terminal."
        pause
        exit $LASTEXITCODE
    }
}
catch {
    Write-Error "An unexpected error occurred during the webtorrent-cli installation."
    Write-Error $_.Exception.Message
    pause
    exit 1
}

Write-Host "WebTorrent CLI installation process finished. This window will now close."
# A short delay to allow the user to read the final message
Start-Sleep -Seconds 5

# Exit with code 0 to indicate success to the parent process
exit 0
