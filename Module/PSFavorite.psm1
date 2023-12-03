# * ============= * 
# * CONFIGURATION * 
# * ============= * 

# Path to the Predictor DLL
$DLLPath = "$PSScriptRoot\Library\PSFavoritePredictor.dll"

# Path to the Favorites file
# ? Turn this in to a environment variable that can be set in the PowerShell profile by the user
$Script:FavoritesPath = "$Env:LOCALAPPDATA\PSFavorite\Favorites.txt"

# * ============= * 
# * IMPORT MODULE * 
# * ============= * 

# Import Public Functions
Get-ChildItem -Path "$PSScriptRoot\Public" -Filter "*.ps1" | ForEach-Object {
    . $_.FullName
    Export-ModuleMember -Function $_.BaseName
}

# ? Add validation checks for the Predictor. It needs PowerShell 7.2.0 and PSReadLine 2.2.0+.
# Import the Predictor DLL
Import-Module $DLLPath

# * ===================== * 
# * REGISTER KEY BINDINGS * 
# * ===================== * 

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
    $line | Add-PSFavorite

    # Remove the item from the prompt
    [Microsoft.PowerShell.PSConsoleReadLine]::DeleteLine()

    # Accept the empty line and move the prompt forward
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()    
    
    # Show a notification that the command was added to the favorites list
    $Command, $Comment = $line -split "#"
    Write-Host ($PSStyle.Foreground.Yellow + "⭐ Marked as Favorite:" + $PSStyle.Reset + " $Command " + $PSStyle.Foreground.BrightBlack + "# $Comment" + $PSStyle.Reset)

    # Optimize the favorites list
    Optimize-PSFavorites
}
