<#
.SYNOPSIS
    Get the PSFavorites list
.DESCRIPTION
    Get the PSFavorites list. This will return the list of commands in the favorites list.
    The favorites list is stored in the `AppData\Local\PSFavorite\Favorites.txt` file.
.EXAMPLE
    Get-PSFavorite
    Get the list of commands in the favorites list.
.EXAMPLE
    Get-PSFavorite | Out-GridView
    Get the list of commands in the favorites list and display it in a GridView.
#>
function Get-PSFavorite {

    [CmdletBinding()]
    param(
        # The path to the favorites list file.
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [string] $FavoritesPath = $Script:FavoritesPath
    )

    # Get the favorites from the file
    $Favorites = Get-Content -Path $FavoritesPath

    $Results = @()

    # Convert the favorites to a PSCustomObject
    foreach ($Favorite in $Favorites) {
        # C# `PSFavoritePredictor::ParseFavoriteLine` returns a `System.ValueTuple<string,string>`.
        # PowerShell does not automatically deconstruct a `ValueTuple` into two variables,
        # so we have to access Item1/Item2 explicitly.
        $tuple = [PSFavorite.PSFavoritePredictor]::ParseFavoriteLine($Favorite)
        $Command = $tuple.Item1
        $Description = $tuple.Item2

        # If the favorite lacks a description, use the command itself as its description
        if ([string]::IsNullOrEmpty($Description)) {
            $Description = $Command
        }

        # Output the favorite as a PSCustomObject
        $Results += [PSCustomObject]@{
            Command     = $Command
            Description = $Description
        }
    }

    return $Results
}
