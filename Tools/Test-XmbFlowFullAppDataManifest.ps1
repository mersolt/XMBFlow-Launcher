param(
    [string]$InventoryPath,
    [string]$ManifestPath,
    [string]$ProjectRoot
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($InventoryPath)) { $InventoryPath = Join-Path $PSScriptRoot '..\packaging\data-asset-inventory.json' }
if ([string]::IsNullOrWhiteSpace($ManifestPath)) { $ManifestPath = Join-Path $PSScriptRoot '..\packaging\full-app-data-manifest.json' }
if ([string]::IsNullOrWhiteSpace($ProjectRoot)) { $ProjectRoot = Join-Path $PSScriptRoot '..' }
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
    'DATA/font-SawarabiGothic-Regular.ttf'
)
$actualDefault = @($manifest.files | Where-Object boot_class -eq 'boot-required-default-profile' | ForEach-Object package_path | Sort-Object) -join "`n"
if ($actualDefault -ne (@($requiredDefault | Sort-Object) -join "`n")) { throw 'Unexpected default boot profile DATA set.' }

foreach ($file in $manifest.files) {
    if ($file.status -eq 'unresolved-source-and-license') {
        if ($null -ne $file.source -or $null -ne $file.license -or $null -ne $file.sha256) {
            throw "Untraced asset has source, licence, or hash evidence: $($file.package_path)"
        }
    } elseif ($file.status -eq 'original-placeholder-traced') {
        if (($file.source -notmatch '^assets/bootstrap-placeholders/DATA/' -and $file.source -ne 'Original XMBFlow synthesized audio.') -or $file.license -ne 'LicenseRef-XMBFlow-Original' -or $file.sha256 -notmatch '^[a-f0-9]{64}$') {
            throw "Original placeholder record is incomplete: $($file.package_path)"
        }
        if ($file.source -eq 'Original XMBFlow synthesized audio.') {
            $localPath = Join-Path $ProjectRoot ('assets\\bootstrap-placeholders\\' + $file.package_path.Replace('/', '\\'))
        } else {
            $localPath = Join-Path $ProjectRoot ($file.source.Replace('/', '\\'))
        }
        if (-not (Test-Path -LiteralPath $localPath -PathType Leaf)) { throw "Original placeholder is absent: $($file.package_path)" }
        if ((Get-FileHash -LiteralPath $localPath -Algorithm SHA256).Hash.ToLowerInvariant() -ne $file.sha256) { throw "Original placeholder hash mismatch: $($file.package_path)" }
    } elseif ($file.status -eq 'third-party-traced') {
        if ($file.source -notmatch '^https://raw.githubusercontent.com/(google/fonts|notofonts/noto-cjk)/[a-f0-9]{40}/' -or $file.license -ne 'OFL-1.1' -or $file.sha256 -notmatch '^[a-f0-9]{64}$') {
            throw "Third-party record is incomplete: $($file.package_path)"
        }
        $localPath = Join-Path $ProjectRoot ('assets\\bootstrap-placeholders\\' + $file.package_path.Replace('/', '\\'))
        if (-not (Test-Path -LiteralPath $localPath -PathType Leaf)) { throw "Third-party boot input is absent: $($file.package_path)" }
        if ((Get-FileHash -LiteralPath $localPath -Algorithm SHA256).Hash.ToLowerInvariant() -ne $file.sha256) { throw "Third-party boot input hash mismatch: $($file.package_path)" }
        $notice = if ($file.package_path -match '^DATA/font-NotoSansCJK') { 'assets/third-party-notices/NotoSansCJK-OFL.txt' } else { 'assets/third-party-notices/SawarabiGothic-OFL.txt' }
        if ($file.transformation -notmatch [regex]::Escape($notice)) { throw "Third-party notice record is incomplete: $($file.package_path)" }
        $fontHeader = [IO.File]::ReadAllBytes($localPath)[0..3]
        $expectedHeader = if ($file.package_path -match '\.otf$') { '4F-54-54-4F' } else { '00-01-00-00' }
        if (([BitConverter]::ToString($fontHeader)) -ne $expectedHeader) { throw "Third-party font header is invalid: $($file.package_path)" }
    } else {
        throw "Unexpected manifest status: $($file.package_path)"
    }
}

Write-Host "Full-app DATA manifest checks passed: $($manifest.files.Count) tracked assets; $($requiredDefault.Count) default boot assets."
