<#
.SYNOPSIS
    Build the project
.DESCRIPTION
    Build the project and copy the DLL to the Module directory.
.EXAMPLE
    . ./Build.ps1
    Run the build script to build the project (in debug configuration) and copy the DLL to the Module directory.
.EXAMPLE
    . ./Build.ps1 -Configuration Release
    Run the build script to build the project (in release configuration) and copy the DLL to the Module directory.
#>

[CmdletBinding(DefaultParameterSetName = 'Build')]
param(
    # The configuration of the build (`Debug` or `Release`) [Default: `Debug`]
    [Parameter(ParameterSetName = 'Build')]
    [ValidateSet('Debug', 'Release')]
    [string] $Configuration = 'Debug'
)

# Path to the Predictor project
$Project = "$PSScriptRoot\Predictor\PSFavoritePredictor.csproj"

# Build the Predictor DLL
dotnet build $Project -c $Configuration -f net7.0

# Items to copy to the Module directory
@(
    @{
        Source      = "$PSScriptRoot\Predictor\bin\$Configuration\net7.0\PSFavoritePredictor.dll"
        Destination = "$PSScriptRoot\Module\Library\PSFavoritePredictor.dll"
    },
    @{
        Source      = "$PSScriptRoot\README.md"
        Destination = "$PSScriptRoot\Module\README.md"
    },
    @{
        Source      = "$PSScriptRoot\LICENSE"
        Destination = "$PSScriptRoot\Module\LICENSE"
    }
) | ForEach-Object {
    Copy-Item -Path $_.Source -Destination $_.Destination -Force -ErrorAction SilentlyContinue
    Write-Output "Copied $($_.Source) to $($_.Destination)"
}
