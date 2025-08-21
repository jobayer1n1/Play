param(
    [string]$magnet
)

if (-not $magnet) {
    Write-Host "Usage: play <magnet-link>"
    exit 1
}

# Run WebTorrent with VLC
webtorrent $magnet --vlc --playlist
