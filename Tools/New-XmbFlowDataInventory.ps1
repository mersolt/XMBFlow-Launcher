[CmdletBinding()]
param(
    [string]$SourceDirectory,
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($SourceDirectory)) { $SourceDirectory = Join-Path $PSScriptRoot '..\src' }
if ([string]::IsNullOrWhiteSpace($OutputPath)) { $OutputPath = Join-Path $PSScriptRoot '..\packaging\data-asset-inventory.json' }
$pattern = 'app0:/*DATA/([A-Za-z0-9_. -]+)'
$assets = @{}

Get-ChildItem -LiteralPath $SourceDirectory -Recurse -Filter '*.lua' -File | ForEach-Object {
    $relative = $_.FullName.Substring((Resolve-Path -LiteralPath $SourceDirectory).Path.Length + 1).Replace('\', '/')
    foreach ($match in [regex]::Matches((Get-Content -Raw -LiteralPath $_.FullName), $pattern)) {
        $name = $match.Groups[1].Value
        if (-not $assets.ContainsKey($name)) {
            $assets[$name] = [System.Collections.Generic.List[string]]::new()
        }
        if (-not $assets[$name].Contains($relative)) {
            $assets[$name].Add($relative)
        }
    }
}

# SystemsToScan composes app0:/DATA/ paths from these names at runtime. They are
# package requirements even though the literal path is not present in the Lua.
$indexPath = Join-Path $SourceDirectory 'index.lua'
foreach ($match in [regex]::Matches((Get-Content -Raw -LiteralPath $indexPath), '\["(?:Missing_Cover|icon)"\]\s*=\s*"([A-Za-z0-9_. -]+)"')) {
    $name = $match.Groups[1].Value
    if (-not $assets.ContainsKey($name)) {
        $assets[$name] = [System.Collections.Generic.List[string]]::new()
    }
    if (-not $assets[$name].Contains('index.lua (SystemsToScan dynamic path)')) {
        $assets[$name].Add('index.lua (SystemsToScan dynamic path)')
    }
}

$fontNames = @(
    'font-SawarabiGothic-Regular.woff',
    'font-NotoSansCJKkr-Regular-Slim.otf',
    'font-NotoSansCJKsc-Regular-Slim.otf',
    'font-NotoSansCJKtc-Regular.otf'
)
foreach ($font in $fontNames) {
    if (-not $assets.ContainsKey($font)) {
        $assets[$font] = [System.Collections.Generic.List[string]]::new()
    }
    if (-not $assets[$font].Contains('dynamic font selection')) {
        $assets[$font].Add('dynamic font selection')
    }
}

$items = foreach ($name in ($assets.Keys | Sort-Object)) {
    $extension = [IO.Path]::GetExtension($name).ToLowerInvariant()
    $kind = switch ($extension) {
        '.png' { 'image' }
        '.jpg' { 'image' }
        '.ogg' { 'audio' }
        '.obj' { 'model' }
        '.woff' { 'font' }
        '.otf' { 'font' }
        default { 'other' }
    }
    [ordered]@{
        path = "DATA/$name"
        kind = $kind
        source_references = @($assets[$name] | Sort-Object)
        status = 'missing-replacement-required'
    }
}

[ordered]@{
    schema = 1
    purpose = 'Static inventory of DATA files directly named by the XMBFlow Lua source; it is not a package manifest.'
    known_limitations = @(
        'This inventory records source references only; it does not claim a licence or source for any replacement.'
    )
    assets = @($items)
} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $OutputPath -Encoding UTF8

Write-Host "Wrote $($items.Count) directly referenced DATA assets to $OutputPath"
