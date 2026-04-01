Describe "Predictor initialization on first import" {
    Context "When initializing module with a custom favorites path" {
        It "Creates the favorites file when given a temp path" {
            $testRoot = Join-Path $PSScriptRoot '..\Temp' + ([guid]::NewGuid().ToString())
            New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

            $favoritesFile = Join-Path $testRoot 'PSFavorite\Favorites.txt'

            try {
                # Import the module (should not throw)
                $manifest = Join-Path (Join-Path $PSScriptRoot '..\..') 'PSFavorite.psd1'
                Import-Module $manifest -Force -ErrorAction Stop

                # Initialize using a custom favorites path under our temp folder
                Initialize-PSFavorite -FavoritesPath $favoritesFile -ErrorAction Stop

                # Assert the favorites file exists
                Test-Path $favoritesFile | Should -BeTrue
            }
            finally {
                # Cleanup: unregister predictor, remove module and temp folder
                Unregister-PSFavoritePredictor -ErrorAction SilentlyContinue
                Remove-Module PSFavorite -ErrorAction SilentlyContinue
                Remove-Item -Path $testRoot -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
}
