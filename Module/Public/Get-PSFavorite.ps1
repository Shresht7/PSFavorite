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
.EXAMPLE
    Get-PSFavorite -Property Command
    Get only the commands in the favorites list.
.EXAMPLE
    Get-PSFavorite -Filter "git"
    Get the commands in the favorites list that contain the string "git" in either the command or the description.
.EXAMPLE
    Get-PSFavorite -Property Description -Filter "git"
    Get only the descriptions in the favorites list that contain the string "git".
.NOTES
    The output of this cmdlet can be used with the `Remove-PSFavorite` cmdlet to remove items from the favorites list.
    For example: `Get-PSFavorite -Filter "git" | Remove-PSFavorite` will remove all favorites that contain the string "git".
#>
function Get-PSFavorite {

    [CmdletBinding()]
    param(
        # The property to select from the favorites list. This can be either "Command" or "Description".
        [ValidateSet("Command", "Description", "All")]
        [Alias("Select")]
        [string] $Property = "All",

        # Filter the favorites list by a string.
        # This will return only the favorites that contain the given string in either the command or the description.
        [Alias("Like", "Match", "Where")]
        [string] $Filter,

        # The path to the favorites list file.
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [Alias("Path", "Name", "FullName", "FullPath")]
        [string] $FavoritesPath = $Script:FavoritesPath
    )

    # Get the favorites from the file
    $Favorites = Get-Content -Path $FavoritesPath -Encoding UTF8

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
    
    if ($Filter) {
        $Results = $Results | Where-Object { $_.Command -like "*$Filter*" -or $_.Description -like "*$Filter*" }
    }

    if ($Property -and $Property -ne "All") {
        return $Results | Select-Object -Property $Property
    }

    return $Results
}
