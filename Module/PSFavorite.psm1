# * ============= * 
# * IMPORT MODULE * 
# * ============= * 

# Import Private Functions
Get-ChildItem -Path "$PSScriptRoot\Private" -Filter "*.ps1" | ForEach-Object {
    . $_.FullName
}

# Import Public Functions
Get-ChildItem -Path "$PSScriptRoot\Public" -Filter "*.ps1" | ForEach-Object {
    . $_.FullName
}

# * ============== *
# * INITIALIZATION *
# * ============== *

# Initialize the PSFavorite module with the default configuration
Initialize-PSFavorite
