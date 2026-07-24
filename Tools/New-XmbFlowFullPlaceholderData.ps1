[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$OutputDirectory,
    [string]$InventoryPath,
    [string]$TemplateDirectory
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($InventoryPath)) { $InventoryPath = Join-Path $PSScriptRoot '..\packaging\data-asset-inventory.json' }
if ([string]::IsNullOrWhiteSpace($TemplateDirectory)) { $TemplateDirectory = Join-Path $PSScriptRoot '..\assets\bootstrap-placeholders\DATA' }
if (Test-Path -LiteralPath $OutputDirectory) { throw "Refusing to overwrite: $OutputDirectory" }
if (-not (Test-Path -LiteralPath $InventoryPath -PathType Leaf)) { throw "Missing inventory: $InventoryPath" }
if (-not (Test-Path -LiteralPath $TemplateDirectory -PathType Container)) { throw "Missing placeholder templates: $TemplateDirectory" }

$inventory = Get-Content -Raw -LiteralPath $InventoryPath | ConvertFrom-Json
$pngFallback = Join-Path $TemplateDirectory 'noimg.png'
$objFallback = Join-Path $TemplateDirectory 'planebg.obj'
$oggFallback = Join-Path $TemplateDirectory 'click2.ogg'
foreach ($path in @($pngFallback, $objFallback, $oggFallback)) { if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing required placeholder: $path" } }

New-Item -ItemType Directory -Path $OutputDirectory | Out-Null
$records = @()
foreach ($asset in $inventory.assets) {
    $name = $asset.path -replace '^DATA/', ''
    $destination = Join-Path $OutputDirectory $name
    $existing = Join-Path $TemplateDirectory $name
    $extension = [IO.Path]::GetExtension($name).ToLowerInvariant()
    $source = $null
    if (Test-Path -LiteralPath $existing -PathType Leaf) {
        $source = $existing
        Copy-Item -LiteralPath $source -Destination $destination
    } elseif ($extension -eq '.png') {
        $source = $pngFallback
        Copy-Item -LiteralPath $source -Destination $destination
    } elseif ($extension -eq '.jpg') {
        $source = $pngFallback
        Add-Type -AssemblyName System.Drawing
        $image = [System.Drawing.Image]::FromFile($source)
        try { $image.Save($destination, [System.Drawing.Imaging.ImageFormat]::Jpeg) } finally { $image.Dispose() }
    } elseif ($extension -eq '.obj') {
        $source = $objFallback
        Copy-Item -LiteralPath $source -Destination $destination
    } elseif ($extension -eq '.ogg') {
        $source = $oggFallback
        Copy-Item -LiteralPath $source -Destination $destination
    } elseif ($extension -eq '.ttf' -or $extension -eq '.otf') {
        throw "No licensed font template is available for: $name"
    } else {
        throw "No type-correct placeholder rule for: $name"
    }
    $records += [ordered]@{ path = "DATA/$name"; kind = $asset.kind; sha256 = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash.ToLowerInvariant() }
}

[ordered]@{
    schema = 1
    purpose = 'Generated original placeholder DATA pack for the read-only XMB test package only.'
    source = 'Tracked original placeholders plus deterministic JPEG conversion.'
    files = $records
} | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $OutputDirectory '..\placeholder-data-manifest.json') -Encoding UTF8
Write-Host "Generated $($records.Count) type-correct placeholder DATA files in $OutputDirectory"
