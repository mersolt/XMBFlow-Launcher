[CmdletBinding()]
param(
    [string]$InventoryPath,
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($InventoryPath)) { $InventoryPath = Join-Path $PSScriptRoot '..\packaging\data-asset-inventory.json' }
if ([string]::IsNullOrWhiteSpace($OutputPath)) { $OutputPath = Join-Path $PSScriptRoot '..\packaging\full-app-data-manifest.json' }
$inventory = Get-Content -Raw -LiteralPath $InventoryPath | ConvertFrom-Json

# These assets are loaded unconditionally by the normal, English/default
# startup path before the library renderer can reach the XMB overlay.
$defaultBootPaths = @(
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
$conditionalFontPaths = @(
    'DATA/font-NotoSansCJKkr-Regular-Slim.otf',
    'DATA/font-NotoSansCJKsc-Regular-Slim.otf',
    'DATA/font-NotoSansCJKtc-Regular.otf'
)

$inventoryPaths = @($inventory.assets.path)
foreach ($path in $defaultBootPaths + $conditionalFontPaths) {
    if ($inventoryPaths -notcontains $path) { throw "Boot profile path is absent from the DATA inventory: $path" }
}

$files = foreach ($asset in $inventory.assets | Sort-Object path) {
    $bootClass = if ($defaultBootPaths -contains $asset.path) {
        'boot-required-default-profile'
    } elseif ($conditionalFontPaths -contains $asset.path) {
        'boot-required-language-conditional'
    } else {
        'deferred-lazy-or-view-dependent'
    }

    [ordered]@{
        package_path = $asset.path
        kind = $asset.kind
        source_references = @($asset.source_references)
        boot_class = $bootClass
        source = $null
        license = $null
        sha256 = $null
        transformation = $null
        status = 'unresolved-source-and-license'
    }
}

[ordered]@{
    schema = 1
    status = 'blocked'
    purpose = 'Closed source, licence, and checksum manifest seed for the full XMBFlow DATA package. It is not approval to package or distribute any asset.'
    boot_profile = [ordered]@{
        name = 'normal-startup-english-default'
        asset_count = $defaultBootPaths.Count
        notes = @(
            'These assets are loaded before the normal library renderer reaches the integrated XMB overlay.',
            'A non-default CJK language requires its matching conditional font before the renderer starts.',
            'No asset becomes package-eligible until source, SPDX-compatible licence, SHA-256, and transformation fields are complete.'
        )
    }
    files = @($files)
} | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $OutputPath -Encoding UTF8

Write-Host "Wrote $($files.Count) full-app DATA manifest entries to $OutputPath"
