Describe "Optimize-PSFavorite" {

    # Before all, import the module and initialize the favorites list
    BeforeAll {
        # Path to the favorites file
        $FavoritesPath = Join-Path $PSScriptRoot ".." "Favorites.txt"
        Import-Module (Join-Path $PSScriptRoot ".." ".." "PSFavorite.psm1")
        Initialize-PSFavorite -FavoritesPath $FavoritesPath
        $Contents = @(
            "Get-Date",
            "Get-Process",
            "Get-Process"
        )
        $Contents | Set-Content -Path $FavoritesPath
    }

    Context "When optimizing the favorites list" {
        It "Should sort the list" {
            Optimize-PSFavorite -FavoritesPath $FavoritesPath
            $Favorites = Get-Content -Path $FavoritesPath
            $Favorites | Should -Be @("Get-Date", "Get-Process")
        }

        It "Should remove duplicates from the list" {
            Optimize-PSFavorite -FavoritesPath $FavoritesPath
            $Favorites = Get-Content -Path $FavoritesPath
            $Favorites | Should -Be @("Get-Date", "Get-Process")
        }
    }

    # After all, remove the favorites file
    AfterAll {
        Remove-Item -Path $FavoritesPath -Force
    }

}
