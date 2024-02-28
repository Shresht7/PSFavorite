<#
.SYNOPSIS
    Optimize the favorites list
.DESCRIPTION
    Optimize the favorites list. This will sort the list and remove duplicates.
    The favorites list is stored in the Favorites.txt file in the PSFavorite module directory.
    The changes will be loaded in the next time the module is imported.
.EXAMPLE
    Optimize-PSFavorites
    Sorts and removes duplicates from the favorites list.
#>
function Optimize-PSFavorites {
    begin {
        $Favorites = Get-Content -Path $Script:FavoritesPath
    }

    process {
        $Favorites = $Favorites | Sort-Object -Unique
    }

    end {
        $Favorites | Out-File -FilePath $Script:FavoritesPath
    }
}
