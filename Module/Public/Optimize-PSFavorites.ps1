<#
.SYNOPSIS
    Optimize the favorites list
.DESCRIPTION
    Optimize the favorites list. This will sort the list and remove duplicates.
    The favorites list is stored in the `AppData\Local\PSFavorite\Favorites.txt` file.
    The changes will be loaded in the next time the module is imported.
.EXAMPLE
    Optimize-PSFavorites
    Sorts and removes duplicates from the favorites list.
#>
function Optimize-PSFavorites {
    Get-Content -Path $Script:FavoritesPath
    | Sort-Object -Unique
    | Out-File -FilePath $Script:FavoritesPath
}
