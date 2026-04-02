Describe "Get-PSFavorite" {

    # Before all, import the module and initialize the favorites list
    BeforeAll {
        # Path to the favorites file
        $FavoritesPath = Join-Path $PSScriptRoot ".." "Favorites.txt"
        Import-Module (Join-Path $PSScriptRoot ".." ".." "PSFavorite.psm1")
        Initialize-PSFavorite -FavoritesPath $FavoritesPath
        $Contents = @(
            "Get-Date",
            "Get-Process"
        )
        $Contents | Set-Content -Path $FavoritesPath
    }

    Context "When getting the favorites list" {
        It "Should return the list of commands in the favorites list" {
            $Favorites = Get-PSFavorite -FavoritesPath $FavoritesPath
            $Favorites | Should -HaveCount 2
            $Favorites[0].Command | Should -Be "Get-Date"
            $Favorites[0].Description | Should -Be "Get-Date"
            $Favorites[1].Command | Should -Be "Get-Process"
            $Favorites[1].Description | Should -Be "Get-Process"
        }

        It "Should handle UTF-8 characters" {
            $command = "Write-Host 'Hello 🌎'"
            $command | Out-File -FilePath $FavoritesPath -Append -Encoding UTF8
            $Favorites = Get-PSFavorite -FavoritesPath $FavoritesPath
            $match = $Favorites | Where-Object { $_.Command -eq $command }
            $match | Should -Not -BeNull
        }
    }

    # After all, remove the favorites file
    AfterAll {
        Remove-Item -Path $FavoritesPath -Force
    }

}
