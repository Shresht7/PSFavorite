<#
.SYNOPSIS
    Get the PSFavorites list
.DESCRIPTION
    Get the PSFavorites list. This will return the list of commands in the favorites list.
    The favorites list is stored in the Favorites.txt file in the PSFavorite module directory.
.EXAMPLE
    Get-PSFavorites
    Get the list of commands in the favorites list.
.EXAMPLE
    Get-PSFavorites | Out-GridView
    Get the list of commands in the favorites list and display it in a GridView.
#>
function Get-PSFavorites {
    begin {
        $Favorites = Get-Content -Path $Script:FavoritesPath
    }

    process {
        # Convert the favorites to a PSCustomObject
        foreach ($Favorite in $Favorites) {
            $Command, $Description = $Favorite -split "\s*#\s*"
            [PSCustomObject]@{
                Command     = $Command.Trim()
                Description = $Description.Trim()
            }
        }
    }

    end { }
}
