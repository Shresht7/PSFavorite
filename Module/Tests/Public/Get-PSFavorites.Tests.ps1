# Path to the favorites file
$FavoritesPath = "$PSScriptRoot\..\Favorites.txt"

Describe "Get-PSFavorites" {

    # Before all, import the module and initialize the favorites list
    BeforeAll {
        Import-Module "$PSScriptRoot\..\..\PSFavorite.psm1"
        Initialize-PSFavorite -FavoritesPath $FavoritesPath
        $Contents = @(
            "Get-Date",
            "Get-Process"
        )
        $Contents | Set-Content -Path $FavoritesPath
    }

    Context "When getting the favorites list" {
        It "Should return the list of commands in the favorites list" {
            $Favorites = Get-PSFavorites -FavoritesPath $FavoritesPath
            $Favorites | Should -HaveCount 2
            $Favorites[0].Command | Should -Be "Get-Date"
            $Favorites[0].Description | Should -Be "Get-Date"
            $Favorites[1].Command | Should -Be "Get-Process"
            $Favorites[1].Description | Should -Be "Get-Process"
        }
    }

    # After all, remove the favorites file
    AfterAll {
        Remove-Item -Path $FavoritesPath -Force
    }

}
