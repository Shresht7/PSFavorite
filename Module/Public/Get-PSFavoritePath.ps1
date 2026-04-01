<#
.SYNOPSIS
    Get the path to the favorites list file.
.DESCRIPTION
    Get the path to the favorites list file.
.EXAMPLE
    Get-PSFavoritePath
    This example returns the path to the favorites list file.
#>
function Get-PSFavoritePath([switch] $Default) {
    if ($Default) {
        # Determine the local application data directory based on the operating system
        $Local = if ($IsWindows) { $Env:LOCALAPPDATA } else { "$HOME/.local/share" }
        return Join-Path $Local "PSFavorite" "Favorites.txt"
    }
    else {
        # Otherwise, return the current path being used by the module 
        return $Script:FavoritesPath
    }
}
