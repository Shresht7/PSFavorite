# * ============= * 
# * CONFIGURATION * 
# * ============= * 

# Create the PSFavorite directory if it doesn't already exist
$local = if ($IsWindows) { $Env:LOCALAPPDATA } else { "~/.local/share" }
$folder = Join-Path $local "PSFavorite"
if (!(Test-Path -Path $folder)) {
    New-Item -ItemType Directory -Path $folder
}

# Path to the Favorites file
$Script:FavoritesPath = Join-Path $folder "Favorites.txt"

# If the file doesn't exist, create an empty file
if (!(Test-Path -Path $Script:FavoritesPath)) {
    New-Item -ItemType File -Path $Script:FavoritesPath
}

# * ============= * 
# * IMPORT MODULE * 
# * ============= * 

# Import Public Functions
Get-ChildItem -Path "$PSScriptRoot\Public" -Filter "*.ps1" | ForEach-Object {
    . $_.FullName
    Export-ModuleMember -Function $_.BaseName
}

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
