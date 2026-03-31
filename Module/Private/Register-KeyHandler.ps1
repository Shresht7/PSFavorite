# Register the Add-PSFavorite KeyHandler
# Add the current command to the favorites list when the
# keybinding (default: `Ctrl+Shift+*`) is pressed.
function Register-KeyHandler(
    # The keybinding to register the Add-PSFavorite KeyHandler
    [string] $Key = "Ctrl+Shift+*"
) {
    Set-PSReadLineKeyHandler -Key $Key `
        -BriefDescription "AddFavorite" `
        -LongDescription "Add the current command to the favorites list" `
        -ScriptBlock {
        param($key, $arg)

        # Get the current command
        $line = ""
        $cursor = ""
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor);

        # If the current command is empty, show a warning and return
        if ($line -eq "") {
            Write-Host ($PSStyle.Foreground.Yellow + "⚠️ No command to add to favorites" + $PSStyle.Reset)
            return
        }

        # Check for duplicate
        $command = ($line -split "#")[0].Trim()
        $existing = Get-PSFavorites | Where-Object { $_.Command -eq $command }
        if ($existing) {
            Write-Host ($PSStyle.Foreground.Yellow + "Already in Favorites:" + $PSStyle.Reset + " $command")
            return
        }

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
}
