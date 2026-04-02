<#
.SYNOPSIS
    Get the path to the favorites list file.
.DESCRIPTION
    Get the path to the favorites list file.
.EXAMPLE
    Get-PSFavoritePath
    This example returns the path to the favorites list file.
#>
function Get-PSFavoritePath {

    [CmdletBinding()]
    param(
        # Return the default path instead of the current active path
        [switch] $Default
    )

    if ($Default) {
        # Determine the local application data directory based on the operating system
        $Local = if ($IsWindows) { $Env:LOCALAPPDATA } else { "$HOME/.local/share" }
        return Join-Path $Local "PSFavorite" "Favorites.txt"
    }

    # Use the script-scoped variable if available, otherwise fallback to default
    if ($Script:FavoritesPath) {
        return $Script:FavoritesPath
    }

    return Get-PSFavoritePath -Default
}
