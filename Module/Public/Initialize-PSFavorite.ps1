<#
.SYNOPSIS
    Initializes the PSFavorite module
.DESCRIPTION
    The Initialize-PSFavorite function is used to initialize the PSFavorite module by providing it the 
    path to the configuration file and the key combination to add a new favorite.
    Both of these parameters are optional.

    The default location for the configuration is: 
    `$Env:LOCALAPPDATA\PSFavorite\Favorites.txt` on Windows and
    `~/.local/share/PSFavorite/Favorites.txt` on Linux and macOS.

    The default keybinding to add a favorite is "Ctrl+Shift+*".
.EXAMPLE
    Initialize-PSFavorite
    Initializes the PSFavorite module using the default configuration and keybindings.
.EXAMPLE
    Initialize-PSFavorite -FavoritesPath "C:\PSFavorite\Config.txt" -Key "Ctrl+Shift+F"
    Initializes the PSFavorite module by creating a configuration file at "C:\PSFavorite\Config.txt"
    and registers the key combination "Ctrl+Shift+F" to add a favorite.
#>
function Initialize-PSFavorite(
    # Path to the configuration file
    [Alias("ConfigPath", "ConfigFile", "FavoritesFile", "Path", "Name", "FullName", "FullPath")]
    [string] $FavoritesPath,

    # Key combination to add a favorite
    [Alias("Keybind", "Keybinding", "KeyCombo", "KeyCombination")]
    [string] $Key = "Ctrl+Shift+*"
) {
    # Parameters for the Initialize-Configuration function
    $Params = @{
        FavoritesPath = $FavoritesPath
    }

    # We use splatting here because the FavoritesPath parameter is optional
    # `Initialize-Configuration` will use the default value if it's not specified.
    # Also the configuration may grow in the future.

    # Initialize the configuration file
    Initialize-Configuration @Params

    # Register the Add-PSFavorite KeyHandler
    Register-KeyHandler -Key $Key
}
