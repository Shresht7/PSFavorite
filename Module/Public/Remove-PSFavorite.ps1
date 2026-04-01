<#
.SYNOPSIS
    Remove the given command(s) from the favorites list
.DESCRIPTION
    Remove the given command(s) from the favorites list. This will remove all instances of the command(s).
    The favorites list is stored in the `AppData\Local\PSFavorite\Favorites.txt` file.
.EXAMPLE
    Remove-PSFavorite -Command "Get-Date"
    Remove the "Get-Date" command from the favorites list.
.EXAMPLE
    "Get-Date" | Remove-PSFavorite
    Remove the "Get-Date" command from the favorites list.
.EXAMPLE
    Get-PSFavorite | Invoke-Fzf -Multi | Remove-PSFavorite
    Use fuzzy-finder to interactively select one or more favorites to remove
#>
function Remove-PSFavorite {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The command(s) to remove from the favorites list
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias("Cmd", "Name", "FullName", "InputObject", "Input")]
        [PSObject[]] $Command,

        # The path to the favorites list file
        [string] $FavoritesPath = $Script:FavoritesPath
    )

    # Read the Favorites.txt content
    $Favorites = Get-Content -Path $FavoritesPath

    foreach ($Cmd in $Command) {
        # Extract the command name from the PSObject or use the provided string
        $CmdName = $Cmd
        if ($Cmd -is [PSObject] -and $Cmd.PSObject.Properties.Name -contains 'Command') {
            $CmdName = $Cmd.Command
        }

        # Normalize the requested command string
        if ($CmdName -ne $null) { $CmdName = [string]$CmdName; $CmdName = $CmdName.Trim() }

        # Check if the user wants to remove the command
        if ($PSCmdlet.ShouldProcess("Remove command '$CmdName' from the favorites list?")) {
            # Compare against the parsed command portion (text before '#') so entries with comments are matched.
            $Favorites = $Favorites | Where-Object {
                $tuple = [PSFavorite.PSFavoritePredictor]::ParseFavoriteLine($_)
                $favCmd = $tuple.Item1
                -not ($favCmd -ieq $CmdName)
            }

            Write-Verbose "Command '$CmdName' removed from the favorites list."
        }
    }

    # Write the filtered Favorites out to the Favorites.txt file
    if ($PSCmdlet.ShouldProcess("Save changes to the favorites list?")) {
        $Favorites | Out-File -FilePath $FavoritesPath -Encoding UTF8 -Force 

        Write-Verbose "Changes saved to the favorites list."
        [PSFavorite.PSFavoritePredictor]::Reload()
    }
}
