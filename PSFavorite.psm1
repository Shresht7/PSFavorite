$DLLPath = "$HOME\Projects\PSFavoritePredictor\bin\Debug\net7.0\PSFavoritePredictor.dll"

Import-Module $DLLPath

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

<#
.SYNOPSIS
    Optimize the favorites list.
.DESCRIPTION
    Optimize the favorites list. This will sort the list and remove duplicates.
.EXAMPLE
    Optimize-Favorite
#>
function Optimize-Favorite {
    begin {
        $Favorites = Get-Content -Path "$PSScriptRoot\Favorites.txt"
    }
    process {
        $Favorites = $Favorites | Sort-Object -Unique
    }

    end {
        $Favorites | Out-File -FilePath "$PSScriptRoot\Favorites.txt"
    }
}

<#
.SYNOPSIS
    Remove the current command from the favorites list.
.DESCRIPTION
    Remove the current command from the favorites list. This will remove all instances of the command.
.EXAMPLE
    Remove-Favorite -Command "Get-Date"
.EXAMPLE
    "Get-Date" | Remove-Favorite
#>
function Remove-Favorite(
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string] $Command
) {
    begin {
        $Favorites = Get-Content -Path "$PSScriptRoot\Favorites.txt"
    }

    process {
        $Favorites | Where-Object { $_ -ne $Command }
    }

    end {
        $Favorites | Out-File -FilePath "$PSScriptRoot\Favorites.txt"
    }
}

# Add the current command to the favorites list when Ctrl+Shift+* is pressed.
Set-PSReadLineKeyHandler -Key "Ctrl+Shift+*" `
    -BriefDescription "AddFavorite" `
    -LongDescription "Add the current command to the favorites list" `
    -ScriptBlock {
    param($key, $arg)

    $line = ""
    $cursor = ""
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor);

    
    $line | Add-Favorite
    Optimize-Favorite
}
