<#
.SYNOPSIS
    Add the current command to the favorites list
.DESCRIPTION
    Add the current command to the favorites list. The favorites list is stored in the Favorites.txt file in
    the PSFavorite module directory. The Favorites.txt file is automatically loaded in when the module is imported.
.EXAMPLE
    Add-PSFavorite -Command "Get-Date"
    Add the "Get-Date" command to the favorites list.
.EXAMPLE
    "Get-Date" | Add-PSFavorite    
    Add the "Get-Date" command to the favorites list.
#>
function Add-PSFavorite(
    # The command to add to the favorites list.
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string] $Command
) {
    $Command | Out-File -FilePath $Script:FavoritesPath -Append
}
