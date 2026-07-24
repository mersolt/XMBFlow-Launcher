param([string]$AssetDirectory)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($AssetDirectory)) { $AssetDirectory = Join-Path $PSScriptRoot '..\assets\bootstrap-placeholders' }
$data = Join-Path $AssetDirectory 'DATA'
$manifest = Get-Content -Raw -LiteralPath (Join-Path $AssetDirectory 'manifest.json') | ConvertFrom-Json
$expected = @(
    'BG_Default.png', 'loading.png', 'floor.png', 'noimg.png', 'footer_gradient.png',
    'x.png', 'o.png', 's.png', 't.png', 'wifi.png', 'bat.png', 'bat_ch.png',
    'fav-small-on.png', 'fav-large-on.png', 'fav-large-off.png',
    'hidden-small-on.png', 'hidden-large-on.png', 'icon-cart.png',
    'icon-cart-inserted.png', 'planebg.obj', 'planefloor.obj'
)
$actual = @(Get-ChildItem -LiteralPath $data -File | ForEach-Object Name | Sort-Object)
$generated = @($manifest.generated_files | ForEach-Object { Split-Path $_.path -Leaf } | Sort-Object)
if (($generated -join "`n") -ne (@($expected | Sort-Object) -join "`n")) { throw 'Bootstrap generator manifest differs from the reviewed placeholder profile.' }
foreach ($name in $expected) { if ($actual -notcontains $name) { throw "Generated placeholder is absent: $name" } }
if ($manifest.source.provenance -notmatch '^Original project artwork generated') { throw 'Wave source provenance is missing.' }
foreach ($file in $manifest.generated_files) {
    $path = Join-Path $AssetDirectory ($file.path.Replace('/', '\\'))
    if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() -ne $file.sha256) { throw "Placeholder hash mismatch: $($file.path)" }
}
Add-Type -AssemblyName System.Drawing
foreach ($name in @('BG_Default.png', 'loading.png', 'floor.png')) {
    $image = [System.Drawing.Image]::FromFile((Join-Path $data $name))
    try { if ($image.Width -ne 960 -or $image.Height -ne 544) { throw "Unexpected canvas size for $name" } }
    finally { $image.Dispose() }
}
Write-Host "Bootstrap generator checks passed: $($generated.Count) generated placeholders; output contains $($actual.Count) boot inputs."
