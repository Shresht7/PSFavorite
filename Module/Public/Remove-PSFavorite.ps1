<#
.SYNOPSIS
    Remove the current command from the favorites list
.DESCRIPTION
    Remove the current command from the favorites list. This will remove all instances of the command.
.EXAMPLE
    Remove-PSFavorite -Command "Get-Date"
.EXAMPLE
    "Get-Date" | Remove-PSFavorite
#>
function Remove-PSFavorite(
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string] $Command
) {
    begin {
        $Favorites = Get-Content -Path $Script:FavoritesPath
    }

    process {
        $Favorites | Where-Object { $_ -ne $Command }
    }

    end {
        $Favorites | Out-File -FilePath $Script:FavoritesPath
    }
}
