<#
.SYNOPSIS
    Build the project
.DESCRIPTION
    Build the project and copy the DLL to the Module directory.
#>

[CmdletBinding(DefaultParameterSetName = 'Build')]
param(
    # The configuration of the build
    [Parameter(ParameterSetName = 'Build')]
    [ValidateSet('Debug', 'Release')]
    [string] $Configuration = 'Debug'
)

# Path to the Predictor project
$Project = "$PSScriptRoot\Predictor\PSFavoritePredictor.csproj"

# Build the Predictor DLL
dotnet build $Project -c $Configuration -f net7.0

$DLLSource = "$PSScriptRoot\Predictor\bin\$Configuration\net7.0\PSFavoritePredictor.dll"
$DLLTarget = "$PSScriptRoot\Module\Library\PSFavoritePredictor.dll"

# Copy the DLL to the Module directory
Copy-Item -Path $DLLSource -Destination $DLLTarget -Force
