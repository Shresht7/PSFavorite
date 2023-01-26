<#
.SYNOPSIS
    Get the PSFavorites list
.DESCRIPTION
    Get the PSFavorites list. This will return the list of commands in the favorites list.
.EXAMPLE
    Get-PSFavorites
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
