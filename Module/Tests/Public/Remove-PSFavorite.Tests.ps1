Describe "Remove-PSFavorite" {

    # Before all, import the module and initialize the favorites list
    BeforeAll {
        # Path to the favorites file
        $FavoritesPath = "$PSScriptRoot\..\Favorites.txt"
        Import-Module "$PSScriptRoot\..\..\PSFavorite.psm1"
        Initialize-PSFavorite -FavoritesPath $FavoritesPath
        $Contents = @(
            "Get-Date",
            "Get-Process",
            "Get-Process"
        )
        $Contents | Set-Content -Path $FavoritesPath
    }

    Context "When removing a single command from the favorites list" {
        It "Should remove the command from the list" {
            Remove-PSFavorite -Command "Get-Date" -FavoritesPath $FavoritesPath
            $Favorites = Get-Content -Path $FavoritesPath
            $Favorites | Should -Be @("Get-Process", "Get-Process")
        }
    }

    Context "When removing multiple commands from the favorites list" {
        It "Should remove all instances of the commands from the list" {
            Remove-PSFavorite -Command "Get-Process" -FavoritesPath $FavoritesPath
            $Favorites = Get-Content -Path $FavoritesPath
            $Favorites | Should -Be @()
        }
    }

    # After all, remove the favorites file
    AfterAll {
        Remove-Item -Path $FavoritesPath -Force
    }

}
