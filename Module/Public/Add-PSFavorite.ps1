<#
.SYNOPSIS
    Add the current command to the favorites list
.DESCRIPTION
    Add the current command to the favorites list. The favorites list is stored in
    the `AppData/PSFavorite/Favorites.txt` file.
    The Favorites.txt file is automatically loaded in when the module is imported.
.EXAMPLE
    Add-PSFavorite -Command "Get-Date"
    Add the "Get-Date" command to the favorites list.
.EXAMPLE
    "Get-Date" | Add-PSFavorite    
    Add the "Get-Date" command to the favorites list.
.NOTES
    The PSFavorites module ships with a keybinding (`ctrl+shift+*`) to mark
    the current command to the favorites list. So you don't need to use this cmdlet.
#>
function Add-PSFavorite(
    # The command to add to the favorites list.
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string] $Command
) {
    $Command | Out-File -FilePath $Script:FavoritesPath -Append
}
