[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$InputDirectory,
    [string]$OutputDirectory,
    [string]$ProvenancePath
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) { $OutputDirectory = Join-Path $PSScriptRoot '..\assets\bootstrap-placeholders\DATA' }
if ([string]::IsNullOrWhiteSpace($ProvenancePath)) { $ProvenancePath = Join-Path $PSScriptRoot '..\assets\user-provided-object-icons.json' }
if (-not (Test-Path -LiteralPath $InputDirectory -PathType Container)) { throw "Missing input directory: $InputDirectory" }
if (Test-Path -LiteralPath $ProvenancePath) { throw "Refusing to overwrite existing provenance record: $ProvenancePath" }

Add-Type -AssemblyName System.Drawing
$files = @(@{ input = 'display-settings.png'; output = 'xmb-setting-display.png' }, @{ input = 'system-settings.png'; output = 'xmb-setting-system.png' }, @{ input = 'time-settings.png'; output = 'xmb-setting-time.png' }, @{ input = 'photoviewer.png'; output = 'xmb-object-photoviewer.png' })
$records = @()
foreach ($file in $files) {
    $inputPath = Join-Path $InputDirectory $file.input
    $outputPath = Join-Path $OutputDirectory $file.output
    if (-not (Test-Path -LiteralPath $inputPath -PathType Leaf)) { throw "Missing supplied icon: $inputPath" }
    if (Test-Path -LiteralPath $outputPath) { throw "Refusing to overwrite existing icon: $outputPath" }
    $source = [System.Drawing.Image]::FromFile($inputPath)
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
        $canvas.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally { $graphics.Dispose(); $canvas.Dispose(); $source.Dispose() }
    $records += [ordered]@{ input_name = $file.input; input_sha256 = (Get-FileHash -LiteralPath $inputPath -Algorithm SHA256).Hash.ToLowerInvariant(); output_path = "assets/bootstrap-placeholders/DATA/$($file.output)"; output_sha256 = (Get-FileHash -LiteralPath $outputPath -Algorithm SHA256).Hash.ToLowerInvariant(); canvas = '96x96 transparent PNG; centred aspect-fit to 76px maximum content extent.' }
}

[ordered]@{ schema = 1; provenance = 'User-provided original XMBFlow object artwork; author asserted original work in project discussion on 2026-07-24.'; license = 'LicenseRef-XMBFlow-Original'; transformation = 'Tools/Import-XmbFlowOriginalObjectIcons.ps1'; files = $records } | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $ProvenancePath -Encoding UTF8
Write-Host "Imported $($records.Count) user-provided original object icons."
