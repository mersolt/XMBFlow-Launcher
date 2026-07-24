[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$InputDirectory,
    [string]$OutputDirectory,
    [string]$ProvenancePath,
    [switch]$Replace
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) { $OutputDirectory = Join-Path $PSScriptRoot '..\assets\bootstrap-placeholders\DATA' }
if ([string]::IsNullOrWhiteSpace($ProvenancePath)) { $ProvenancePath = Join-Path $PSScriptRoot '..\assets\user-provided-category-icons.json' }
if (-not $Replace) { throw 'Pass -Replace to intentionally replace the existing generated category placeholders.' }
if (-not (Test-Path -LiteralPath $InputDirectory -PathType Container)) { throw "Missing input directory: $InputDirectory" }
if (-not (Test-Path -LiteralPath $OutputDirectory -PathType Container)) { throw "Missing output directory: $OutputDirectory" }
if (Test-Path -LiteralPath $ProvenancePath) { throw "Refusing to overwrite existing provenance record: $ProvenancePath" }

Add-Type -AssemblyName System.Drawing
$names = @('games', 'music', 'network', 'photo', 'settings', 'video')
$records = @()
foreach ($name in $names) {
    $inputPath = Join-Path $InputDirectory "icon-$name.png"
    $outputPath = Join-Path $OutputDirectory "xmb-icon-$name.png"
    if (-not (Test-Path -LiteralPath $inputPath -PathType Leaf)) { throw "Missing supplied icon: $inputPath" }
    $source = [System.Drawing.Image]::FromFile($inputPath)
    $canvas = [System.Drawing.Bitmap]::new(96, 96)
    $graphics = [System.Drawing.Graphics]::FromImage($canvas)
    try {
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $scale = [Math]::Min(76.0 / $source.Width, 76.0 / $source.Height)
        $targetWidth = [Math]::Round($source.Width * $scale)
        $targetHeight = [Math]::Round($source.Height * $scale)
        $targetX = [Math]::Floor((96 - $targetWidth) / 2)
        $targetY = [Math]::Floor((96 - $targetHeight) / 2)
        $graphics.DrawImage($source, $targetX, $targetY, $targetWidth, $targetHeight)
        $canvas.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $graphics.Dispose()
        $canvas.Dispose()
        $source.Dispose()
    }
    $records += [ordered]@{
        input_name = "icon-$name.png"
        input_sha256 = (Get-FileHash -LiteralPath $inputPath -Algorithm SHA256).Hash.ToLowerInvariant()
        output_path = "assets/bootstrap-placeholders/DATA/xmb-icon-$name.png"
        output_sha256 = (Get-FileHash -LiteralPath $outputPath -Algorithm SHA256).Hash.ToLowerInvariant()
        canvas = '96x96 transparent PNG; centred aspect-fit to 76px maximum content extent.'
    }
}

[ordered]@{
    schema = 1
    provenance = 'User-provided original XMBFlow category artwork; author asserted original work in project discussion on 2026-07-23.'
    license = 'LicenseRef-XMBFlow-Original'
    transformation = 'Tools/Import-XmbFlowOriginalCategoryIcons.ps1'
    files = $records
} | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $ProvenancePath -Encoding UTF8

Write-Host "Imported $($records.Count) user-provided original category icons."
