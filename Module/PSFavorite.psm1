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

# Auto-Initialize Configuration and KeyHandler
# This ensures the module is ready to use immediately upon import

Initialize-Configuration
Register-KeyHandler
