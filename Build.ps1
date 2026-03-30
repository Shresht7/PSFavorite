<#
.SYNOPSIS
    Build the project
.DESCRIPTION
    Build the project and copy the DLL to the Module directory.
.PARAMETER Configuration
    The configuration of the build (`Debug` or `Release`) [Default: `Debug`]
.PARAMETER TargetFramework
    The target framework of the build (`net7.0` or `net8.0`) [Default: `net8.0`]
.PARAMETER Clean
    If specified, cleans the project before building.
.EXAMPLE
    ./Build.ps1
    Run the build script to build the project (in debug configuration) and copy the DLL to the Module directory.
.EXAMPLE
    ./Build.ps1 -Configuration Release -Clean
    Clean and build the project in release configuration.
#>

[CmdletBinding(DefaultParameterSetName = 'Build')]
param(
    # The configuration of the build (`Debug` or `Release`) [Default: `Debug`]
    [Parameter(ParameterSetName = 'Build')]
    [ValidateSet('Debug', 'Release')]
    [string] $Configuration = 'Debug',

    # The target framework of the build (`net7.0` or `net8.0`) [Default: `net8.0`]
    [ValidateSet("net7.0", "net8.0")]
    [ValidateNotNullOrEmpty()]
    [string] $TargetFramework = "net8.0",

    # Clean the project before building
    [switch] $Clean
)

# Path to the Predictor project
$Project = "$PSScriptRoot\Predictor\PSFavoritePredictor.csproj"

# Clean the project if the -Clean switch is specified
if ($Clean) {
    Write-Host "Cleaning project ($Configuration)..."
    dotnet clean $Project -c $Configuration -f $TargetFramework
}

# Build the Predictor DLL
Write-Host "Building project ($Configuration)..."
dotnet build $Project -c $Configuration -f $TargetFramework

# Fail fast: If dotnet build failed, do not attempt to copy files
if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed. Please check the output above."
    exit $LASTEXITCODE
}

# Items to copy to the Module directory
$Items = @(
    @{
        Source      = "$PSScriptRoot\Predictor\bin\$Configuration\$TargetFramework\PSFavoritePredictor.dll"
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
)

# Copy items with Error Handling for Locks
foreach ($item in $Items) {
    try {
        if (Test-Path -Path $item.Destination) {
            Remove-Item -Path $item.Destination -Force
        }
        Copy-Item -Path $item.Source -Destination $item.Destination -Force
        Write-Output "Copied $($item.Source) to $($item.Destination)"
    }
    catch {
        # Specific handling for the locked DLL issue
        if ($item.Destination -like "*PSFavoritePredictor.dll") {
            Write-Host ""
            Write-Host "CRITICAL ERROR: Access Denied to PSFavoritePredictor.dll" -ForegroundColor Red
            Write-Host "The DLL is likely locked because the module is loaded in an active PowerShell session." -ForegroundColor Yellow
            Write-Host "To fix this, please close all PowerShell windows and try again." -ForegroundColor Yellow
            Write-Host ""
        }
        else {
            Write-Error "Failed to copy $($item.Source) to $($item.Destination): $($_.Exception.Message)"
        }
        exit 1
    }
}

Write-Host "Build and Copy completed successfully!" -ForegroundColor Green
