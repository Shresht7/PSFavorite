# * ============= * 
# * CONFIGURATION * 
# * ============= * 

# Create the PSFavorite directory if it doesn't already exist
$local = if ($IsWindows) { $Env:LOCALAPPDATA } else { "~/.local/share" }
$folder = Join-Path $local "PSFavorite"
if (!(Test-Path -Path $folder)) {
    New-Item -ItemType Directory -Path $folder
}

# Path to the Favorites file
$Script:FavoritesPath = Join-Path $folder "Favorites.txt"

# If the file doesn't exist, create an empty file
if (!(Test-Path -Path $Script:FavoritesPath)) {
    New-Item -ItemType File -Path $Script:FavoritesPath
}

# * ============= * 
# * IMPORT MODULE * 
# * ============= * 

# Import Private Functions
Get-ChildItem -Path "$PSScriptRoot\Private" -Filter "*.ps1" | ForEach-Object {
    . $_.FullName
}

# Import Public Functions
Get-ChildItem -Path "$PSScriptRoot\Public" -Filter "*.ps1" | ForEach-Object {
    . $_.FullName
    Export-ModuleMember -Function $_.BaseName
}

# * ============== *
# * INITIALIZATION *
# * ============== *

# Register the Add-Favorite KeyHandler
Register-KeyHandler -Key "Ctrl+Shift+*"
