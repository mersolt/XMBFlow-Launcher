param([string]$SceSysRoot = (Join-Path $env:TEMP 'xmbflow-scesys-indexed\sce_sys'))

$ErrorActionPreference = 'Stop'
$paths = @('icon0.png', 'livearea\contents\bg.png', 'livearea\contents\startup.png')
foreach ($relativePath in $paths) {
    $path = Join-Path $SceSysRoot $relativePath
    $bytes = [IO.File]::ReadAllBytes($path)
    if ($bytes.Length -lt 26 -or [Text.Encoding]::ASCII.GetString($bytes, 1, 3) -ne 'PNG' -or [Text.Encoding]::ASCII.GetString($bytes, 12, 4) -ne 'IHDR') {
        throw "Not a PNG with an IHDR header: $path"
    }
    $bitDepth = $bytes[24]
    $colorType = $bytes[25]
    if ($bitDepth -ne 8 -or $colorType -ne 3) {
        throw "LiveArea PNG is not indexed 8-bit: $relativePath (bit depth $bitDepth, colour type $colorType)"
    }
}
Write-Host 'XMBFlow LiveArea PNG format checks passed (indexed 8-bit).'
