param([string]$Manifest = (Join-Path $PSScriptRoot '..\packaging\package-inputs.json'))

# This deliberately runs before any staging directory is created.
& (Join-Path $PSScriptRoot 'Test-PackageInputs.ps1') -Manifest $Manifest
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

throw 'Staging is not implemented until the approved manifest lists every file and checksum.'
