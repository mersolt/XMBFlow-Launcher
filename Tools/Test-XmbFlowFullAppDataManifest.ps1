param(
    [string]$InventoryPath,
    [string]$ManifestPath
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($InventoryPath)) { $InventoryPath = Join-Path $PSScriptRoot '..\packaging\data-asset-inventory.json' }
if ([string]::IsNullOrWhiteSpace($ManifestPath)) { $ManifestPath = Join-Path $PSScriptRoot '..\packaging\full-app-data-manifest.json' }
$inventory = Get-Content -Raw -LiteralPath $InventoryPath | ConvertFrom-Json
$manifest = Get-Content -Raw -LiteralPath $ManifestPath | ConvertFrom-Json
if ($manifest.status -ne 'blocked') { throw 'Full-app DATA manifest must remain blocked until every source and licence is resolved.' }

$inventorySet = @($inventory.assets.path | Sort-Object) -join "`n"
$manifestSet = @($manifest.files.package_path | Sort-Object) -join "`n"
if ($inventorySet -ne $manifestSet) { throw 'Full-app DATA manifest path set differs from the source inventory.' }

$requiredDefault = @(
    'DATA/loading.png', 'DATA/click2.ogg', 'DATA/noimg.png',
    'DATA/t.png', 'DATA/s.png', 'DATA/x.png', 'DATA/o.png',
    'DATA/wifi.png', 'DATA/bat.png', 'DATA/bat_ch.png',
    'DATA/BG_Default.png', 'DATA/floor.png', 'DATA/footer_gradient.png',
    'DATA/fav-small-on.png', 'DATA/fav-large-on.png', 'DATA/fav-large-off.png',
    'DATA/hidden-small-on.png', 'DATA/hidden-large-on.png',
    'DATA/icon-cart.png', 'DATA/icon-cart-inserted.png',
    'DATA/planebg.obj', 'DATA/planefloor.obj',
    'DATA/font-SawarabiGothic-Regular.woff'
)
$actualDefault = @($manifest.files | Where-Object boot_class -eq 'boot-required-default-profile' | ForEach-Object package_path | Sort-Object) -join "`n"
if ($actualDefault -ne (@($requiredDefault | Sort-Object) -join "`n")) { throw 'Unexpected default boot profile DATA set.' }

foreach ($file in $manifest.files) {
    if ($file.status -eq 'unresolved-source-and-license') {
        if ($null -ne $file.source -or $null -ne $file.license -or $null -ne $file.sha256) {
            throw "Untraced asset has source, licence, or hash evidence: $($file.package_path)"
        }
    } elseif ($file.status -eq 'original-placeholder-traced') {
        if ($file.source -notmatch '^assets/bootstrap-placeholders/DATA/' -or $file.license -ne 'LicenseRef-XMBFlow-Original' -or $file.sha256 -notmatch '^[a-f0-9]{64}$') {
            throw "Original placeholder record is incomplete: $($file.package_path)"
        }
    } else {
        throw "Unexpected manifest status: $($file.package_path)"
    }
}

Write-Host "Full-app DATA manifest checks passed: $($manifest.files.Count) tracked assets; $($requiredDefault.Count) default boot assets."
