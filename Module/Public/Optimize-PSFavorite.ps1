<#
.SYNOPSIS
    Optimize the favorites list
.DESCRIPTION
    Optimize the favorites list. This will sort the list and remove duplicates.
    The favorites list is stored in the `AppData\Local\PSFavorite\Favorites.txt` file in the PSFavorite module directory.
.EXAMPLE
    Optimize-PSFavorite
    Sorts and removes duplicates from the favorites list.
#>
function Optimize-PSFavorite {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The path to the favorites list file.
        [Alias("Path", "Name", "FullName", "FullPath", "Config", "ConfigPath", "ConfigFile", "FavoritesFile")]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [string] $FavoritesPath = $Script:FavoritesPath
    )
    
    $Favorites = Get-Content -Path $FavoritesPath | Sort-Object -Unique

    if ($PSCmdlet.ShouldProcess("Optimizing favorites list at path '$FavoritesPath' by sorting and removing duplicates")) {
        $Favorites | Out-File -FilePath $FavoritesPath -Encoding UTF8 -Force
    }

    [PSFavorite.PSFavoritePredictor]::Reload()
}
