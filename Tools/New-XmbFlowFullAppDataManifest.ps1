[CmdletBinding()]
param(
    [string]$InventoryPath,
    [string]$OutputPath,
    [string]$BootstrapAssetDirectory
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($InventoryPath)) { $InventoryPath = Join-Path $PSScriptRoot '..\packaging\data-asset-inventory.json' }
if ([string]::IsNullOrWhiteSpace($OutputPath)) { $OutputPath = Join-Path $PSScriptRoot '..\packaging\full-app-data-manifest.json' }
if ([string]::IsNullOrWhiteSpace($BootstrapAssetDirectory)) { $BootstrapAssetDirectory = Join-Path $PSScriptRoot '..\assets\bootstrap-placeholders' }
$inventory = Get-Content -Raw -LiteralPath $InventoryPath | ConvertFrom-Json
$bootstrapManifestPath = Join-Path $BootstrapAssetDirectory 'manifest.json'
$bootstrapAssets = @{}
if (Test-Path -LiteralPath $bootstrapManifestPath -PathType Leaf) {
    $bootstrapManifest = Get-Content -Raw -LiteralPath $bootstrapManifestPath | ConvertFrom-Json
    foreach ($file in $bootstrapManifest.generated_files) { $bootstrapAssets[$file.path] = $file }
}
$clickPath = Join-Path $BootstrapAssetDirectory 'DATA\click2.ogg'
$thirdPartyFonts = @{
    'DATA/font-SawarabiGothic-Regular.ttf' = @{ source = 'https://raw.githubusercontent.com/google/fonts/9fab8b6cc7b2f20376914fd765d918c698c66d75/ofl/sawarabigothic/SawarabiGothic-Regular.ttf'; copyright = 'Copyright 2016 The Sawarabi Gothic Project Authors'; notice = 'assets/third-party-notices/SawarabiGothic-OFL.txt'; transformation = 'Downloaded unchanged from pinned Google Fonts revision.' }
    'DATA/font-NotoSansCJKkr-Regular-Slim.otf' = @{ source = 'https://raw.githubusercontent.com/notofonts/noto-cjk/f8d157532fbfaeda587e826d4cd5b21a49186f7c/Sans/OTF/Korean/NotoSansCJKkr-Regular.otf'; copyright = 'Copyright 2014-2021 Adobe (http://www.adobe.com/). Noto is a trademark of Google Inc.'; notice = 'assets/third-party-notices/NotoSansCJK-OFL.txt'; transformation = 'Downloaded unchanged from pinned Noto CJK revision; renamed only to the legacy package filename.' }
    'DATA/font-NotoSansCJKsc-Regular-Slim.otf' = @{ source = 'https://raw.githubusercontent.com/notofonts/noto-cjk/f8d157532fbfaeda587e826d4cd5b21a49186f7c/Sans/OTF/SimplifiedChinese/NotoSansCJKsc-Regular.otf'; copyright = 'Copyright 2014-2021 Adobe (http://www.adobe.com/). Noto is a trademark of Google Inc.'; notice = 'assets/third-party-notices/NotoSansCJK-OFL.txt'; transformation = 'Downloaded unchanged from pinned Noto CJK revision; renamed only to the legacy package filename.' }
    'DATA/font-NotoSansCJKtc-Regular.otf' = @{ source = 'https://raw.githubusercontent.com/notofonts/noto-cjk/f8d157532fbfaeda587e826d4cd5b21a49186f7c/Sans/OTF/TraditionalChinese/NotoSansCJKtc-Regular.otf'; copyright = 'Copyright 2014-2021 Adobe (http://www.adobe.com/). Noto is a trademark of Google Inc.'; notice = 'assets/third-party-notices/NotoSansCJK-OFL.txt'; transformation = 'Downloaded unchanged from pinned Noto CJK revision.' }
}

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
    'DATA/font-SawarabiGothic-Regular.ttf'
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

    $bootstrap = $bootstrapAssets[$asset.path]
    $isOriginalPlaceholder = $null -ne $bootstrap
    $isOriginalClick = $asset.path -eq 'DATA/click2.ogg' -and (Test-Path -LiteralPath $clickPath -PathType Leaf)
    $thirdPartyFont = $thirdPartyFonts[$asset.path]
    $thirdPartyFontPath = if ($null -ne $thirdPartyFont) { Join-Path $BootstrapAssetDirectory $asset.path } else { $null }
    $isThirdPartyFont = $null -ne $thirdPartyFont -and (Test-Path -LiteralPath $thirdPartyFontPath -PathType Leaf)
    $resolvedHash = if ($isOriginalPlaceholder) { $bootstrap.sha256 } elseif ($isOriginalClick) { (Get-FileHash -LiteralPath $clickPath -Algorithm SHA256).Hash.ToLowerInvariant() } elseif ($isThirdPartyFont) { (Get-FileHash -LiteralPath $thirdPartyFontPath -Algorithm SHA256).Hash.ToLowerInvariant() } else { $null }
    [ordered]@{
        package_path = $asset.path
        kind = $asset.kind
        source_references = @($asset.source_references)
        boot_class = $bootClass
        source = if ($isOriginalPlaceholder) { "assets/bootstrap-placeholders/$($asset.path)" } elseif ($isOriginalClick) { 'Original XMBFlow synthesized audio.' } elseif ($isThirdPartyFont) { $thirdPartyFont.source } else { $null }
        copyright = if ($isOriginalPlaceholder -or $isOriginalClick) { 'Copyright XMBFlow contributors' } elseif ($isThirdPartyFont) { $thirdPartyFont.copyright } else { $null }
        license = if ($isOriginalPlaceholder -or $isOriginalClick) { 'LicenseRef-XMBFlow-Original' } elseif ($isThirdPartyFont) { 'OFL-1.1' } else { $null }
        sha256 = $resolvedHash
        transformation = if ($isOriginalPlaceholder) { 'Tools/New-XmbFlowBootstrapPlaceholders.ps1' } elseif ($isOriginalClick) { 'FFmpeg lavfi sine generator: 880 Hz, 0.06 s, fade-out, Vorbis.' } elseif ($isThirdPartyFont) { "$($thirdPartyFont.transformation) Notice at $($thirdPartyFont.notice)" } else { $null }
        status = if ($isOriginalPlaceholder -or $isOriginalClick) { 'original-placeholder-traced' } elseif ($isThirdPartyFont) { 'third-party-traced' } else { 'unresolved-source-and-license' }
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
            'No asset becomes package-eligible until source, SPDX-compatible licence, SHA-256, and transformation fields are complete.',
            'Original project placeholders may be traced without making the full package eligible; unresolved entries keep this manifest blocked.'
        )
    }
    files = @($files)
} | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $OutputPath -Encoding UTF8

Write-Host "Wrote $($files.Count) full-app DATA manifest entries to $OutputPath"
