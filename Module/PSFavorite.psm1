# Path to the Predictor DLL
$DLLPath = "$HOME\Projects\PSFavorite\bin\Debug\net7.0\PSFavoritePredictor.dll"

# Path to the Favorites file
$Script:FavoritesPath = "$HOME\Projects\PSFavorite\Module\Favorites.txt"

# Import Library
Get-ChildItem -Path "$PSScriptRoot\Public" -Filter "*.ps1" | ForEach-Object {
    . $_.FullName
}

# TODO: Add validation checks for the Predictor. It needs PowerShell 7.2.0 and PSReadLine 2.2.0+.
# Import the Predictor DLL
Import-Module $DLLPath

# Register the Add-Favorite KeyHandler
# Add the current command to the favorites list when Ctrl+Shift+* is pressed.
Set-PSReadLineKeyHandler -Key "Ctrl+Shift+*" `
    -BriefDescription "AddFavorite" `
    -LongDescription "Add the current command to the favorites list" `
    -ScriptBlock {
    param($key, $arg)

    # Get the current command
    $line = ""
    $cursor = ""
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor);

    # Add the current command to the favorites list
    $line | Add-Favorite

    # Optimize the favorites list
    Optimize-Favorite
}
