<#
.SYNOPSIS
    Optimize the favorites list.
.DESCRIPTION
    Optimize the favorites list. This will sort the list and remove duplicates.
.EXAMPLE
    Optimize-Favorite
#>
function Optimize-Favorite {
    begin {
        $Favorites = Get-Content -Path "$PSScriptRoot\Favorites.txt"
    }
    process {
        $Favorites = $Favorites | Sort-Object -Unique
    }

    end {
        $Favorites | Out-File -FilePath "$PSScriptRoot\Favorites.txt"
    }
}
