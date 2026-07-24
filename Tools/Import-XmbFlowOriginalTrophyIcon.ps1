[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$InputPath,
    [string]$OutputPath,
    [string]$ProvenancePath
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($OutputPath)) { $OutputPath = Join-Path $PSScriptRoot '..\assets\bootstrap-placeholders\DATA\xmb-object-trophy.png' }
if ([string]::IsNullOrWhiteSpace($ProvenancePath)) { $ProvenancePath = Join-Path $PSScriptRoot '..\assets\user-provided-trophy-icon.json' }
if (-not (Test-Path -LiteralPath $InputPath -PathType Leaf)) { throw "Missing supplied trophy icon: $InputPath" }
if (Test-Path -LiteralPath $OutputPath) { throw "Refusing to overwrite existing trophy icon: $OutputPath" }
if (Test-Path -LiteralPath $ProvenancePath) { throw "Refusing to overwrite existing provenance record: $ProvenancePath" }

Add-Type -AssemblyName System.Drawing
$source = [System.Drawing.Image]::FromFile($InputPath)
$canvas = [System.Drawing.Bitmap]::new(96, 96)
$graphics = [System.Drawing.Graphics]::FromImage($canvas)
try {
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $scale = [Math]::Min(76.0 / $source.Width, 76.0 / $source.Height)
    $targetWidth = [Math]::Round($source.Width * $scale)
    $targetHeight = [Math]::Round($source.Height * $scale)
    $graphics.DrawImage($source, [Math]::Floor((96 - $targetWidth) / 2), [Math]::Floor((96 - $targetHeight) / 2), $targetWidth, $targetHeight)
    $canvas.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
} finally { $graphics.Dispose(); $canvas.Dispose(); $source.Dispose() }

[ordered]@{ schema = 1; provenance = 'User-provided original XMBFlow trophy artwork; author asserted original work in project discussion on 2026-07-24.'; license = 'LicenseRef-XMBFlow-Original'; transformation = 'Tools/Import-XmbFlowOriginalTrophyIcon.ps1'; input_sha256 = (Get-FileHash -LiteralPath $InputPath -Algorithm SHA256).Hash.ToLowerInvariant(); output_path = 'assets/bootstrap-placeholders/DATA/xmb-object-trophy.png'; output_sha256 = (Get-FileHash -LiteralPath $OutputPath -Algorithm SHA256).Hash.ToLowerInvariant(); canvas = '96x96 transparent PNG; centred aspect-fit to 76px maximum content extent.' } | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath $ProvenancePath -Encoding UTF8
Write-Host "Imported original trophy icon: $OutputPath"
