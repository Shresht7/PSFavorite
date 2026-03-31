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
    Initialize-Configuration -FavoritesPath "C:\MyFavorites\Favorites.txt" -Verbose
    This example initializes the configuration using a custom FavoritesPath value and shows verbose output.
#>
function Initialize-Configuration(
    # Name of the parent folder
    [string] $ModuleName = "PSFavorite",

    # Name of the configuration file
    [string] $FavoritesFile = "Favorites.txt",

    # Path to the configuration file
    [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
    [string] $FavoritesPath
) {

    # Determine the local application data directory based on the operating system
    $Local = if ($IsWindows) { $Env:LOCALAPPDATA } else { "$HOME/.local/share" }

    # If the FavoritesPath parameter is specified, use it ...
    if ($FavoritesPath) {
        $Script:FavoritesPath = $FavoritesPath
        Write-Verbose "Using custom FavoritesPath: $Script:FavoritesPath"
    }
    # ... otherwise, use the default path
    else {
        $Script:FavoritesPath = Join-Path $Local $ModuleName $FavoritesFile
        Write-Verbose "Using default FavoritesPath: $Script:FavoritesPath"
    }

    # Create the directory if it doesn't exist
    $folder = Split-Path $Script:FavoritesPath
    if (-not (Test-Path -Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Write-Verbose "Created directory: $folder"
    }

    # Create the Favorites file if it doesn't exist
    if (-not (Test-Path -Path $Script:FavoritesPath)) {
        New-Item -ItemType File -Path $Script:FavoritesPath -Force | Out-Null
        Write-Verbose "Created file: $Script:FavoritesPath"
    }

}
