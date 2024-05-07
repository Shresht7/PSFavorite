# Path to the test favorite file
$FavoritesPath = "$PSScriptRoot\..\Favorites.txt"

Describe "Add-PSFavorite" {

    # Before all, import the module and initialize the favorites list
    BeforeAll {
        Import-Module "$PSScriptRoot\..\..\PSFavorite.psm1"
        Initialize-PSFavorite -FavoritesPath $FavoritesPath
    }

    Context "When adding a command to the favorites list" {
        It "Should add the command to the favorites list file" {
            $command = "Get-Date"
            Add-PSFavorite -Command $command
            $Favorites = Get-Content -Path $FavoritesPath
            $Favorites | Should -Contain $command
        }

        It "Should accept pipeline input" {
            "Get-Date" | Add-PSFavorite
            $Favorites = Get-Content -Path $FavoritesPath
            $Favorites | Should -Contain "Get-Date"
        }
        
        It "Should increase the count by 1" {
            $Favorites = Get-Content -Path $FavoritesPath
            $count = $Favorites.Count
            $command = "Get-Date"
            Add-PSFavorite -Command $command
            $Favorites = Get-Content -Path $FavoritesPath
            $Favorites.Count | Should -Be ($count + 1)
        
        }
    }

    Context "When the favorites file does not exist" {
        It "Should create the favorites file" {
            $NonExistantPath = "$PSScriptRoot\..\DoesNotExist.txt"
            
            $NonExistantPath | Should -Not -Exist
            Add-PSFavorite -Command "Get-Date" -FavoritesPath $NonExistantPath
            $NonExistantPath | Should -Exist
            
            $Content = Get-Content -Path $NonExistantPath
            $Content | Should -Contain "Get-Date"

            $Content.Count | Should -Be 1
        }
        AfterAll {
            Remove-Item -Path "$PSScriptRoot\..\DoesNotExist.txt" -Force
        }
    }

    # After all, remove the favorites file
    AfterAll {
        Remove-Item -Path $FavoritesPath -Force
    }

}
