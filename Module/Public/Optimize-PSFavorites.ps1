<#
.SYNOPSIS
    Optimize the favorites list
.DESCRIPTION
    Optimize the favorites list. This will sort the list and remove duplicates.
    The favorites list is stored in the `AppData\Local\PSFavorite\Favorites.txt` file in the PSFavorite module directory.
    The changes will be loaded in the next time the module is imported.
.EXAMPLE
    Optimize-PSFavorites
    Sorts and removes duplicates from the favorites list.
#>
function Optimize-PSFavorites(
    # The path to the favorites list file.
    [string] $FavoritesPath = $Script:FavoritesPath
) {
    begin {
        $Favorites = Get-Content -Path $FavoritesPath
    }

    process {
        $Favorites = $Favorites | Sort-Object -Unique
    }

    end {
        $Favorites | Out-File -FilePath $FavoritesPath
    }
}
