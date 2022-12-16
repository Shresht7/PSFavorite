<#
.SYNOPSIS
    Build the project
.DESCRIPTION
    Build the project and copy the DLL to the Module directory.
#>

# Build the Predictor DLL
dotnet build "$PSScriptRoot\Predictor\PSFavoritePredictor.csproj"

# Copy the DLL to the Module directory
Copy-Item -Path "$PSScriptRoot\Predictor\bin\Debug\net7.0\PSFavoritePredictor.dll" -Destination "$PSScriptRoot\Module\Library\PSFavoritePredictor.dll" -Force
