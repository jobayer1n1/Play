# installNodeJS.ps1 - Installs Node.js by downloading the official MSI installer.
# This script is intended to be run with administrator privileges and does NOT require winget.

Write-Host "============================================="
Write-Host "Node.js Installation Script (No-Winget Method)"
Write-Host "This requires administrator privileges."
Write-Host "============================================="
Write-Host ""

# --- Configuration ---
# This URL points to a recent LTS (Long Term Support) 64-bit version of Node.js.
# NOTE: The Node.js project occasionally changes its URL structure. If this script fails with a (404) error,
# you may need to visit https://nodejs.org/en/download/ to find the new URL for the "Windows Installer (.msi)"
# and update the line below.
$nodeMsiUrl = "https://nodejs.org/dist/v20.12.2/node-v20.12.2-x64.msi"
# We will download the installer to the user's temporary folder.
$tempPath = $env:TEMP
$msiFileName = "node-lts.x64.msi"
$destinationPath = Join-Path $tempPath $msiFileName

# --- Download the Installer ---
Write-Host "Downloading Node.js LTS installer from $nodeMsiUrl..."
Write-Host "Destination: $destinationPath"

try {
    # Use Invoke-WebRequest to download the file.
    # -UseBasicParsing is a good practice for compatibility.
    Invoke-WebRequest -Uri $nodeMsiUrl -OutFile $destinationPath -UseBasicParsing
    Write-Host "Download complete."
}
catch {
    Write-Error "Failed to download the Node.js installer."
    Write-Error $_.Exception.Message
    pause
    exit 1
}

# --- Run the Installer ---
Write-Host "Starting Node.js installation... This may take a few moments."
Write-Host "An installer window with a progress bar will appear."

try {
    # Use msiexec to run the MSI installer.
    # /i: Specifies the installer file.
    # /qb: Sets the UI to 'quiet, basic UI' (shows a progress bar). This helps debug errors like 1603.
    # /norestart: Prevents the machine from restarting automatically.
    # ADDLOCAL=ALL: A parameter that can help resolve issues where some features fail to install.
    $msiArgs = @(
        "/i"
        "`"$destinationPath`""
        "/qb"
        "/norestart"
        "ADDLOCAL=ALL"
    )

    # Start the process and wait for it to complete.
    $process = Start-Process "msiexec.exe" -ArgumentList $msiArgs -Wait -PassThru

    # Check the exit code of the installer. 0 means success.
    if ($process.ExitCode -eq 0) {
        Write-Host "Node.js LTS has been installed successfully."
        Write-Host "The new path will be available in new terminal windows."
    } else {
        Write-Error "The MSI installer failed with exit code $($process.ExitCode)."
        Write-Error "Common exit codes: 1603 (Fatal error), 3010 (Restart required)."
        Write-Error "Please check for any error messages that appeared in the installer window."
        Write-Error "You can also try running the downloaded installer manually from '$destinationPath'."
        pause
        exit $process.ExitCode
    }
}
catch {
    Write-Error "An unexpected error occurred while trying to run the Node.js installer."
    Write-Error $_.Exception.Message
    pause
    exit 1
}
finally {
    # Clean up by deleting the downloaded MSI file.
    if (Test-Path $destinationPath) {
        Write-Host "Cleaning up downloaded installer file..."
        Remove-Item $destinationPath -Force
    }
}

Write-Host "Node.js installation process finished. This window will now close."
# A short delay to allow the user to read the final message
Start-Sleep -Seconds 5

# Exit with code 0 to indicate success to the parent process
exit 0
