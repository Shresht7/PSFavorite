<#
.SYNOPSIS
    Initializes the configuration for the PSFavorite module.
.DESCRIPTION
    This function initializes the configuration for the PSFavorite module.
    It creates the PSFavorite directory and file if it doesn't already exist.
.PARAMETER FavoritesPath
    Path to the configuration file. If not specified, the default value is used.
    `$Env:LOCALAPPDATA\PSFavorite\Favorites.txt` on Windows and
    `~/.local/share/PSFavorite/Favorites.txt` on Linux and macOS.
.EXAMPLE
    Initialize-Configuration
    This example initializes the configuration using the default FavoritesPath value.
.EXAMPLE
    Initialize-Configuration -FavoritesPath "C:\MyFavorites\Favorites.txt"
    This example initializes the configuration using a custom FavoritesPath value.
#>
function Initialize-Configuration(
    # Name of the parent folder
    [string] $ModuleName = "PSFavorite",

    # Path to the configuration file
    [string] $FavoritesPath
) {

    # If the FavoritesPath parameter is specified, use it ...
    if ($FavoritesPath) {
        $Script:FavoritesPath = $FavoritesPath
    }
    # ... otherwise, 
    else {
        # Create the PSFavorite directory if it doesn't already exist
        $local = if ($IsWindows) { $Env:LOCALAPPDATA } else { "$HOME/.local/share" }
        $folder = Join-Path $local $ModuleName
        if (!(Test-Path -Path $folder)) {
            New-Item -ItemType Directory -Path $folder -Force
        }
    
        # Path to the Favorites file
        $Script:FavoritesPath = Join-Path $folder "Favorites.txt"
    
        # If the file doesn't exist, create an empty file
        if (!(Test-Path -Path $Script:FavoritesPath)) {
            New-Item -ItemType File -Path $Script:FavoritesPath -Force
        }
    }

}
