[CmdletBinding()]
param([string]$OutputPath)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($OutputPath)) { $OutputPath = Join-Path $PSScriptRoot '..\assets\bootstrap-placeholders\DATA\xmb-glow.png' }
if (Test-Path -LiteralPath $OutputPath) { throw "Refusing to overwrite existing glow texture: $OutputPath" }

Add-Type -AssemblyName System.Drawing
$bitmap = [System.Drawing.Bitmap]::new(96, 96)
try {
    for ($y = 0; $y -lt 96; $y++) {
        for ($x = 0; $x -lt 96; $x++) {
            $dx = ($x - 47.5) / 47.5
            $dy = ($y - 47.5) / 47.5
            $distance = [Math]::Sqrt($dx * $dx + $dy * $dy)
            $falloff = [Math]::Max(0, 1 - $distance)
            $alpha = [Math]::Floor(120 * [Math]::Pow($falloff, 2.2))
            $bitmap.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($alpha, 255, 255, 255))
        }
    }
    $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
} finally { $bitmap.Dispose() }

Write-Host "Created original XMBFlow radial glow texture: $OutputPath"
