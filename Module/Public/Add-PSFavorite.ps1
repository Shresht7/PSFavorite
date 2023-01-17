<#
.SYNOPSIS
    Add the current command to the favorites list
.DESCRIPTION
    Add the current command to the favorites list.
.EXAMPLE
    Add-PSFavorite -Command "Get-Date"
.EXAMPLE
    "Get-Date" | Add-PSFavorite
#>
function Add-PSFavorite(
    # The command to add to the favorites list.
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string] $Command
) {
    $Command | Out-File -FilePath $Script:FavoritesPath -Append
}
