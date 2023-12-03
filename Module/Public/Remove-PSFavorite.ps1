<#
.SYNOPSIS
    Remove the given command from the favorites list
.DESCRIPTION
    Remove the given command from the favorites list. This will remove all instances of the command.
    The favorites list is stored in the Favorites.txt file in the PSFavorite module directory.
    The changes will be reflected the next time the module is imported.
.EXAMPLE
    Remove-PSFavorite -Command "Get-Date"
    Remove the "Get-Date" command from the favorites list.
.EXAMPLE
    "Get-Date" | Remove-PSFavorite
    Remove the "Get-Date" command from the favorites list.
.EXAMPLE
    Get-PSFavorites | fzf | Remove-PSFavorite
    Use fuzzy-finder to interactively select a favorite to remove
#>
function Remove-PSFavorite(
    # The command to remove from the favorites list
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string] $Command
) {
    begin {
        $Favorites = Get-Content -Path $Script:FavoritesPath
    }

    process {
        $Favorites = $Favorites | Where-Object { $_ -ne $Command }
    }

    end {
        $Favorites | Out-File -FilePath $Script:FavoritesPath
    }
}
