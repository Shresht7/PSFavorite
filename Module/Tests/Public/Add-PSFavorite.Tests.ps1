Describe "Add-PSFavorite" {
    
    # Before all, import the module and initialize the favorites list
    BeforeAll {
        # Path to the test favorite file
        $FavoritesPath = Join-Path $PSScriptRoot ".." "Favorites.txt"
        Import-Module (Join-Path $PSScriptRoot ".." ".." "PSFavorite.psm1")
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

        It "Should handle UTF-8 characters" {
            $command = "Write-Host 'Hello 🌎'"
            Add-PSFavorite -Command $command
            $Favorites = Get-Content -Path $FavoritesPath -Encoding UTF8
            $Favorites | Should -Contain $command
        }

        It "Should parse comments from the command string if description is empty" {
            $testCmd = "Get-Service # Get list of services"
            Add-PSFavorite -Command $testCmd
            $Favorites = Get-PSFavorite -FavoritesPath $FavoritesPath
            $match = $Favorites | Where-Object { $_.Command -eq "Get-Service" }
            $match | Should -Not -BeNull
            $match.Description | Should -Be "Get list of services"
        }
    }

    Context "When the favorites file does not exist" {
        
        It "Should create the favorites file" {
            $NonExistantPath = Join-Path $PSScriptRoot ".." "DoesNotExist.txt"
            $NonExistantPath | Should -Not -Exist
            try {
                Add-PSFavorite -Command "Get-Date" -FavoritesPath $NonExistantPath
            }
            catch {
                $_ | Should -Not -Exist
            }
        }
    
    }

    # After all, remove the favorites file
    AfterAll {
        Remove-Item -Path $FavoritesPath -Force
    }

}
