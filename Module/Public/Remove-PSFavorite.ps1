<#
.SYNOPSIS
    Remove the given command(s) from the favorites list
.DESCRIPTION
    Remove the given command(s) from the favorites list. This will remove all instances of the command(s).
    The favorites list is stored in the Favorites.txt file in the PSFavorite module directory.
    The changes will be reflected the next time the module is imported.
.EXAMPLE
    Remove-PSFavorite -Command "Get-Date"
    Remove the "Get-Date" command from the favorites list.
.EXAMPLE
    "Get-Date" | Remove-PSFavorite
    Remove the "Get-Date" command from the favorites list.
.EXAMPLE
    Get-PSFavorites | fzf | Remove-PSFavorite
    Use fuzzy-finder to interactively select a favorite to remove
#>
function Remove-PSFavorite {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The command(s) to remove from the favorites list
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [PSObject[]] $Command
    )

    begin {
        # Read the Favorites.txt content
        $Favorites = Get-Content -Path $Script:FavoritesPath
    }

    process {
        foreach ($Cmd in $Command) {
            # Extract the command name from the PSObject or use the provided string
            $CmdName = $Cmd
            if ($Cmd -is [PSObject] -and $Cmd.PSObject.Properties.Name -contains 'Command') {
                $CmdName = $Cmd.Command
            }
        
            # Check if the user wants to remove the command
            if ($PSCmdlet.ShouldProcess("Remove command '$CmdName' from the favorites list?")) {
                $Favorites = $Favorites | Where-Object { $_ -ne $CmdName }
                Write-Verbose "Command '$CmdName' removed from the favorites list."
            }
        }
    }

    end {
        # Write the filtered Favorites out to the Favorites.txt file
        if ($PSCmdlet.ShouldProcess("Save changes to the favorites list?")) {
            $Favorites | Out-File -FilePath $Script:FavoritesPath
            Write-Verbose "Changes saved to the favorites list."
        }
    }
}
