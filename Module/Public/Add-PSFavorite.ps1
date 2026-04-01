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
    "Get-Date" | Add-PSFavorite    
    Add the "Get-Date" command to the favorites list.
.NOTES
    The PSFavorites module ships with a keybinding (`ctrl+shift+*`) to mark
    the current command to the favorites list. So you don't have to use this cmdlet.
#>
function Add-PSFavorite {

    [CmdletBinding()]
    param (
        # The command to add to the favorites list.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrWhiteSpace()]
        [Alias("Cmd", "Name", "FullName")]
        [string[]] $Command,

        # The path to the favorites list file.
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [string] $FavoritesPath = $Script:FavoritesPath
    )

    begin {
        $ToWrite = @()
    }

    process {
        $ToWrite += $Command
    }

    end {
        $ToWrite | Out-File -FilePath $FavoritesPath -Append
        [PSFavorite.PSFavoritePredictor]::Reload()
        $ToWrite
    }
}
