<#
.SYNOPSIS
    Unregister the PSFavorite predictor from PSReadLine.
.DESCRIPTION
    Explicitly removes the PSFavorite predictor from the PSReadLine subsystem.
    This is safe to call multiple times and is useful for testing or when you
    want to cleanly unload the predictor before re-importing the module.
.EXAMPLE
    Unregister-PSFavoritePredictor
    Unregisters the predictor from PSReadLine.
#>
function Unregister-PSFavoritePredictor {
    [PSFavorite.PSFavoritePredictor]::Unregister()
}
