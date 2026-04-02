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
function Initialize-Configuration {
    [CmdletBinding()]
    param (
        # Path to the configuration file. If not specified, the default value is used.
        [string] $FavoritesPath
    )

    # Use specified path or fall back to default
    if ($FavoritesPath) {
        $Script:FavoritesPath = $FavoritesPath
        Write-Verbose "Using custom FavoritesPath: $Script:FavoritesPath"
    }
    else {
        $Script:FavoritesPath = Get-PSFavoritePath -Default
        Write-Verbose "Using default FavoritesPath: $Script:FavoritesPath"
    }

    # Ensure parent directory exists
    $folder = Split-Path $Script:FavoritesPath
    if (-not (Test-Path -Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Write-Verbose "Created directory: $folder"
    }

    # Create empty file if it doesn't exist
    if (-not (Test-Path -Path $Script:FavoritesPath)) {
        New-Item -ItemType File -Path $Script:FavoritesPath -Force | Out-Null
        Write-Verbose "Created file: $Script:FavoritesPath"
    }
}
