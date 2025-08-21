# setup.ps1 - Main setup script
# This script checks for Node.js and webtorrent-cli, and adds its own directory to the user's PATH.

# Get the directory where this script is located
$scriptPath = $PSScriptRoot

Write-Host "-------------------------------------"
Write-Host "Starting environment setup..."
Write-Host "Script location: $scriptPath"
Write-Host "-------------------------------------"

# --- 1. Check for Node.js ---
Write-Host "Step 1: Checking for Node.js..."
$node = Get-Command node.exe -ErrorAction SilentlyContinue
if ($null -eq $node) {
    Write-Host "Node.js is not found. Launching Node.js installer..."
    try {
        # Define the path to the installer script
        $nodeInstaller = Join-Path $scriptPath "installNodeJS.ps1"
        
        if (-not (Test-Path $nodeInstaller)) {
            Write-Error "CRITICAL: installNodeJS.ps1 not found in the same directory."
            pause
            exit
        }

        # Launch the installer script with administrator privileges and wait for it to complete
        $process = Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$nodeInstaller`"" -Verb RunAs -Wait -PassThru
        
        # Check the exit code of the installer script
        if ($process.ExitCode -ne 0) {
            Write-Error "Node.js installation script failed with exit code $($process.ExitCode). Aborting."
            pause
            exit
        } else {
            Write-Host "Node.js installation script completed. Continuing setup..."
        }
    }
    catch {
        Write-Error "Failed to start the Node.js installation process. Please run installNodeJS.ps1 manually as an administrator."
        Write-Error $_.Exception.Message
        pause
        exit
    }
}
else {
    Write-Host "Node.js is already installed at: $($node.Source)"
}

# Reload Machine + User PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + `
            [System.Environment]::GetEnvironmentVariable("Path", "User")


# --- 2. Check for WebTorrent CLI (Robust Method) ---
Write-Host "`nStep 2: Checking for webtorrent-cli..."
$webtorrentCmd = $null

# Method 1: Check the PATH using Get-Command (the standard way)
$webtorrentCmd = Get-Command webtorrent -ErrorAction SilentlyContinue

# Method 2: If not found, check the npm global prefix folder directly (the robust way)
if ($null -eq $webtorrentCmd) {
    Write-Host "Info: 'webtorrent' command not found in PATH. Checking npm's global install location directly..."
    
    # Ensure npm exists before trying to use it
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        $npmPrefix = npm config get prefix
        if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($npmPrefix)) {
            $webtorrentPath = Join-Path $npmPrefix.Trim() "webtorrent.cmd"
            Write-Host "Info: Checking for executable at '$webtorrentPath'..."
            if (Test-Path $webtorrentPath) {
                Write-Host "Found webtorrent executable via npm prefix. Treating as installed."
                $webtorrentCmd = $webtorrentPath # Set to a non-null value to signify it's found
            }
        } else {
            Write-Warning "Could not determine npm's global prefix directory."
        }
    } else {
        Write-Warning "npm command not found. Cannot perform deep check for webtorrent-cli."
    }
}

# Now, based on the findings, decide whether to install
if ($null -eq $webtorrentCmd) {
    Write-Host "webtorrent-cli is not found. Launching installer..."
    try {
        # Define the path to the installer script
        $webtorrentInstaller = Join-Path $scriptPath "installWebtorrent.ps1"

        if (-not (Test-Path $webtorrentInstaller)) {
            Write-Error "CRITICAL: installWebtorrent.ps1 not found in the same directory."
            pause
            exit
        }
        
        # Find the full path to npm.cmd to pass to the elevated script.
        $npmFullPath = (Get-Command npm -ErrorAction Stop).Source
        Write-Host "Found npm at $npmFullPath. Passing this path to the administrator script."

        # Launch the installer script with administrator privileges, passing the npm path as an argument.
        $argumentList = "-NoProfile -ExecutionPolicy Bypass -File `"$webtorrentInstaller`" -npmFullPath `"$npmFullPath`""
        $process = Start-Process powershell -ArgumentList $argumentList -Verb RunAs -Wait -PassThru

        if ($process.ExitCode -ne 0) {
            Write-Error "WebTorrent installation script failed with exit code $($process.ExitCode). Aborting."
            pause
            exit
        } else {
            Write-Host "WebTorrent installation script completed. Continuing setup..."
        }
    }
    catch {
        Write-Error "Failed to start the WebTorrent CLI installation process. This can happen if the 'npm' command is not found."
        Write-Error $_.Exception.Message
        pause
        exit
    }
}
else {
    Write-Host "webtorrent-cli is already installed."
}


# --- 3. Check and Set User Environment Variable ---
Write-Host "`nStep 3: Checking user Path environment variable..."

# Get the current user's Path variable
$userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")

# Check if the script's directory is already in the user's Path
if (($userPath -split ';') -contains $scriptPath) {
    Write-Host "The script directory is already in the user's Path environment variable."
}
else {
    Write-Host "Adding script directory to user's Path environment variable..."
    
    # Create the new path string, avoiding a leading semicolon if the path is currently empty
    $newPath = if ([string]::IsNullOrEmpty($userPath)) {
        $scriptPath
    } else {
        "$userPath;$scriptPath"
    }
    
    # Set the environment variable for the current user
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    
    # Inform the user that the change requires a new terminal session
    Write-Host "Successfully added '$scriptPath' to the user Path."
    Write-Host "IMPORTANT: You will need to open a new PowerShell/Command Prompt window for this change to take effect."
}

Write-Host "`n-------------------------------------"
Write-Host "Setup complete!"
Write-Host "-------------------------------------"
# Pause at the end to allow the user to see the output
pause
