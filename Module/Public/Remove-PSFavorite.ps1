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

    begin {
        # Initialize a list to collect commands from the pipeline
        $CommandsToRemove = [System.Collections.Generic.List[string]]::new()
    }

    process {
        foreach ($Cmd in $Command) {
            # Extract the command name from the PSObject or use the provided string
            $CmdName = $Cmd
            if ($Cmd -is [PSObject] -and $Cmd.PSObject.Properties.Name -contains 'Command') {
                $CmdName = $Cmd.Command
            }

            # Normalize the requested command string
            if ($null -ne $CmdName) {
                $CmdName = ([string]$CmdName).Trim()
                if ($CmdName.Length -gt 0) {
                    $CommandsToRemove.Add($CmdName)
                }
            }
        }
    }

    end {
        if ($CommandsToRemove.Count -eq 0) {
            return
        }

        # Create a case-insensitive HashSet for O(1) lookups
        $RemoveSet = [System.Collections.Generic.HashSet[string]]::new($CommandsToRemove, [System.StringComparer]::OrdinalIgnoreCase)

        # Read the Favorites.txt content
        $Favorites = Get-Content -Path $FavoritesPath -Encoding UTF8

        # Filter the favorites list in a single pass
        $Filtered = $Favorites | Where-Object {
            $tuple = [PSFavorite.PSFavoritePredictor]::ParseFavoriteLine($_)
            $favCmd = $tuple.Item1
            -not $RemoveSet.Contains($favCmd)
        }

        $removedCount = $Favorites.Count - $Filtered.Count
        if ($removedCount -gt 0) {
            $description = "Remove $removedCount command(s) from the favorites list at '$FavoritesPath'"
            if ($PSCmdlet.ShouldProcess($description)) {
                $Filtered | Out-File -FilePath $FavoritesPath -Encoding UTF8 -Force 
                Write-Verbose "Removed $removedCount command(s) and saved changes."
                [PSFavorite.PSFavoritePredictor]::Reload()
            }
        }
        else {
            Write-Verbose "No matching commands found to remove."
        }
    }
}
