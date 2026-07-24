[CmdletBinding()]
param([string]$OutputPath)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($OutputPath)) { $OutputPath = Join-Path $PSScriptRoot '..\assets\bootstrap-placeholders\DATA\xmb-app-options-panel.png' }
if (Test-Path -LiteralPath $OutputPath) { throw "Refusing to overwrite existing texture: $OutputPath" }

Add-Type -AssemblyName System.Drawing
$width = 322
$height = 544
$bitmap = [System.Drawing.Bitmap]::new($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
try {
    for ($y = 0; $y -lt $height; $y++) {
        $vertical = 0.86 + 0.14 * [Math]::Exp(-[Math]::Pow(($y - ($height - 1) / 2) / 220, 2))
        for ($x = 0; $x -lt $width; $x++) {
            $fade = [Math]::Pow(1 - $x / ($width - 1), 1.2)
            $alpha = [Math]::Floor(224 * $fade * $vertical)
            $blue = [Math]::Floor(76 + 28 * $fade)
            $bitmap.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($alpha, 13, 35, $blue))
        }
    }
    $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
} finally { $bitmap.Dispose() }

Write-Host "Created original XMBFlow app-options panel texture: $OutputPath"
