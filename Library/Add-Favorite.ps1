<#
.SYNOPSIS
    Add the current command to the favorites list
.DESCRIPTION
    Add the current command to the favorites list.
.EXAMPLE
    Add-Favorite -Command "Get-Date"
.EXAMPLE
    "Get-Date" | Add-Favorite
#>
function Add-Favorite(
    # The command to add to the favorites list.
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string] $Command
) {
    $Command | Out-File -FilePath "$PSScriptRoot\Favorites.txt" -Append
}
