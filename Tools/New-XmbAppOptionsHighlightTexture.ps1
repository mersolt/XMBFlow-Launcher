[CmdletBinding()]
param([string]$OutputPath)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($OutputPath)) { $OutputPath = Join-Path $PSScriptRoot '..\assets\bootstrap-placeholders\DATA\xmb-app-options-highlight.png' }
if (Test-Path -LiteralPath $OutputPath) { throw "Refusing to overwrite existing texture: $OutputPath" }

Add-Type -AssemblyName System.Drawing
$width = 322
$height = 58
$bitmap = [System.Drawing.Bitmap]::new($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
try {
    for ($y = 0; $y -lt $height; $y++) {
        $vertical = 0.76 + 0.24 * [Math]::Exp(-[Math]::Pow(($y - ($height - 1) / 2) / 18, 2))
        $edge = [Math]::Exp(-[Math]::Pow($y / 2.4, 2)) + [Math]::Exp(-[Math]::Pow(($height - 1 - $y) / 2.4, 2))
        for ($x = 0; $x -lt $width; $x++) {
            $horizontal = [Math]::Pow(1 - $x / ($width - 1), 1.35)
            $alpha = [Math]::Min(255, [Math]::Floor($horizontal * (182 * $vertical + 52 * $edge)))
            $bitmap.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($alpha, 118, 211, 255))
        }
    }
    $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
} finally { $bitmap.Dispose() }

Write-Host "Created original XMBFlow app-options highlight texture: $OutputPath"
