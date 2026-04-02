<#
.SYNOPSIS
    Add the current command to the favorites list
.DESCRIPTION
    Add the current command to the favorites list. The favorites list is stored in
    the `AppData\Local\PSFavorite\Favorites.txt` file.
    The Favorites.txt file is automatically loaded in when the module is imported.
.EXAMPLE
    Add-PSFavorite -Command "Get-Date"
    Add the "Get-Date" command to the favorites list.
.EXAMPLE
    "Get-Date # Current Date and Time" | Add-PSFavorite    
    Add the "Get-Date" command to the favorites list with the given comment description.
.NOTES
    The PSFavorites module ships with a keybinding (`ctrl+shift+*`) to mark
    the current command to the favorites list. So you don't have to use this cmdlet.
#>
function Add-PSFavorite {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The command to add to the favorites list.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrWhiteSpace()]
        [Alias("Cmd", "Name", "FullName", "InputObject", "Input")]
        [string[]] $Command,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias("Desc", "Info", "Comment")]
        [string[]] $Description,

        # The path to the favorites list file.
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [string] $FavoritesPath = $Script:FavoritesPath
    )

    begin {
        $ToWrite = @()
    }

    process {
        Write-Verbose "Processing command '$Command' with description '$Description' to add to favorites list at path '$FavoritesPath'."
        if ($Description -eq "" -and $Command -contains "#") {
            $tuple = [PSFavorite.PSFavoritePredictor]::ParseFavoriteLine($Command)
            $Command = $tuple.Item1
            $Description = $tuple.Item2
        }

        if ([string]::IsNullOrWhiteSpace($Description)) {
            Write-Verbose "Adding command '$Command' to the favorites list without a description."
            $ToWrite += $Command
        }
        else {
            Write-Verbose "Adding command '$Command' with description '$Description' to the favorites list."
            $ToWrite += "$Command # $Description"
        }

        return [PSCustomObject]@{
            Command     = $Command
            Description = $Description
        }
    }

    end {
        $count = $ToWrite.Count
        if ($count -gt 0 && $PSCmdlet.ShouldProcess("Add $count command(s) to the favorites list?")) {
            $ToWrite | Out-File -FilePath $FavoritesPath -Append -Encoding UTF8 -Force
            Write-Verbose "$count command(s) added to the favorites list."
        }

        
        [PSFavorite.PSFavoritePredictor]::Reload()
        Write-Verbose "Favorites list reloaded."
    }
}
