[CmdletBinding()]
param(
    [string]$WaveSource,
    [string]$OutputDirectory
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($WaveSource)) { $WaveSource = Join-Path $PSScriptRoot '..\packaging\bootstrap-source\xmbflow-wave-v1.png' }
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) { $OutputDirectory = Join-Path $PSScriptRoot '..\assets\bootstrap-placeholders' }
if (-not (Test-Path -LiteralPath $WaveSource -PathType Leaf)) { throw "Original wave source is missing: $WaveSource" }
if (Test-Path -LiteralPath $OutputDirectory) { throw "Refusing to overwrite existing placeholder output: $OutputDirectory" }

Add-Type -AssemblyName System.Drawing
$data = Join-Path $OutputDirectory 'DATA'
New-Item -ItemType Directory -Path $data | Out-Null

function Save-Png([System.Drawing.Bitmap]$Image, [string]$Name) {
    try { $Image.Save((Join-Path $data $Name), [System.Drawing.Imaging.ImageFormat]::Png) }
    finally { $Image.Dispose() }
}

function New-Canvas([int]$Width, [int]$Height, [System.Drawing.Color]$Color) {
    $bitmap = [System.Drawing.Bitmap]::new($Width, $Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try { $graphics.Clear($Color) } finally { $graphics.Dispose() }
    return $bitmap
}

function Draw-LineIcon([string]$Name, [scriptblock]$Draw, [int]$Size = 24) {
    $bitmap = New-Canvas $Size $Size ([System.Drawing.Color]::Transparent)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        & $Draw $graphics $Size
    } finally { $graphics.Dispose() }
    Save-Png $bitmap $Name
}

$wave = [System.Drawing.Image]::FromFile((Resolve-Path -LiteralPath $WaveSource))
try {
    foreach ($name in @('BG_Default.png', 'loading.png')) {
        $bitmap = New-Canvas 960 544 ([System.Drawing.Color]::FromArgb(5, 14, 42))
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        try {
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.DrawImage($wave, 0, 0, 960, 544)
        } finally { $graphics.Dispose() }
        Save-Png $bitmap $name
    }
} finally { $wave.Dispose() }

$floor = New-Canvas 960 544 ([System.Drawing.Color]::FromArgb(5, 16, 38))
$g = [System.Drawing.Graphics]::FromImage($floor)
try {
    $pen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(35, 72, 196, 255), 1)
    try {
        for ($x = -120; $x -lt 1080; $x += 60) { $g.DrawLine($pen, $x, 544, 480, 275) }
        for ($y = 315; $y -lt 545; $y += 26) { $g.DrawLine($pen, 0, $y, 960, $y) }
    } finally { $pen.Dispose() }
} finally { $g.Dispose() }
Save-Png $floor 'floor.png'

$noimg = New-Canvas 256 256 ([System.Drawing.Color]::FromArgb(12, 29, 61))
$g = [System.Drawing.Graphics]::FromImage($noimg)
try {
    $pen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(100, 210, 255), 5)
    try {
        $g.DrawRectangle($pen, 26, 26, 204, 204)
        $g.DrawLine($pen, 52, 194, 110, 130)
        $g.DrawLine($pen, 110, 130, 150, 164)
        $g.DrawLine($pen, 150, 164, 202, 96)
    } finally { $pen.Dispose() }
} finally { $g.Dispose() }
Save-Png $noimg 'noimg.png'

$gradient = [System.Drawing.Bitmap]::new(320, 48)
for ($x = 0; $x -lt 320; $x++) {
    $alpha = [int](255 * (1 - ($x / 319)))
    for ($y = 0; $y -lt 48; $y++) { $gradient.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($alpha, 10, 26, 48)) }
}
Save-Png $gradient 'footer_gradient.png'

Draw-LineIcon 'x.png' { param($g, $s) $p=[System.Drawing.Pen]::new([System.Drawing.Color]::White,3); try{$g.DrawLine($p,6,6,18,18);$g.DrawLine($p,18,6,6,18)}finally{$p.Dispose()} }
Draw-LineIcon 'o.png' { param($g, $s) $p=[System.Drawing.Pen]::new([System.Drawing.Color]::White,3); try{$g.DrawEllipse($p,5,5,14,14)}finally{$p.Dispose()} }
Draw-LineIcon 't.png' { param($g, $s) $p=[System.Drawing.Pen]::new([System.Drawing.Color]::White,3); try{$g.DrawPolygon($p,[System.Drawing.Point[]]@([System.Drawing.Point]::new(12,4),[System.Drawing.Point]::new(21,19),[System.Drawing.Point]::new(3,19)))}finally{$p.Dispose()} }
Draw-LineIcon 's.png' { param($g, $s) $p=[System.Drawing.Pen]::new([System.Drawing.Color]::White,3); try{$g.DrawRectangle($p,5,5,14,14)}finally{$p.Dispose()} }
Draw-LineIcon 'wifi.png' { param($g, $s) $p=[System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(100,220,255),2); try{$g.DrawArc($p,2,2,20,20,215,110);$g.DrawArc($p,6,6,12,12,215,110);$g.FillEllipse([System.Drawing.Brushes]::White,10,17,4,4)}finally{$p.Dispose()} }
Draw-LineIcon 'bat.png' { param($g, $s) $p=[System.Drawing.Pen]::new([System.Drawing.Color]::White,2); try{$g.DrawRectangle($p,3,7,17,10);$g.DrawRectangle($p,20,10,2,4)}finally{$p.Dispose()} }
Draw-LineIcon 'bat_ch.png' { param($g, $s) $p=[System.Drawing.Pen]::new([System.Drawing.Color]::White,2); try{$g.DrawRectangle($p,3,7,17,10);$g.DrawRectangle($p,20,10,2,4);$g.DrawLine($p,13,5,9,13);$g.DrawLine($p,9,13,14,13);$g.DrawLine($p,14,13,11,20)}finally{$p.Dispose()} }
Draw-LineIcon 'fav-small-on.png' { param($g, $s) $g.FillEllipse([System.Drawing.Brushes]::White,4,4,8,8);$g.FillEllipse([System.Drawing.Brushes]::White,12,4,8,8);$g.FillPolygon([System.Drawing.Brushes]::White,[System.Drawing.Point[]]@([System.Drawing.Point]::new(4,8),[System.Drawing.Point]::new(20,8),[System.Drawing.Point]::new(12,21))) }
Draw-LineIcon 'fav-large-on.png' { param($g, $s) $g.FillEllipse([System.Drawing.Brushes]::White,4,4,8,8);$g.FillEllipse([System.Drawing.Brushes]::White,12,4,8,8);$g.FillPolygon([System.Drawing.Brushes]::White,[System.Drawing.Point[]]@([System.Drawing.Point]::new(4,8),[System.Drawing.Point]::new(20,8),[System.Drawing.Point]::new(12,21))) }
Draw-LineIcon 'fav-large-off.png' { param($g, $s) $p=[System.Drawing.Pen]::new([System.Drawing.Color]::White,2);try{$g.DrawEllipse($p,4,4,8,8);$g.DrawEllipse($p,12,4,8,8);$g.DrawLine($p,4,8,12,20);$g.DrawLine($p,12,20,20,8)}finally{$p.Dispose()} }
Draw-LineIcon 'hidden-small-on.png' { param($g, $s) $p=[System.Drawing.Pen]::new([System.Drawing.Color]::White,2);try{$g.DrawEllipse($p,4,8,16,8);$g.DrawLine($p,4,4,20,20)}finally{$p.Dispose()} }
Draw-LineIcon 'hidden-large-on.png' { param($g, $s) $p=[System.Drawing.Pen]::new([System.Drawing.Color]::White,2);try{$g.DrawEllipse($p,4,8,16,8);$g.DrawLine($p,4,4,20,20)}finally{$p.Dispose()} }
Draw-LineIcon 'icon-cart.png' { param($g, $s) $p=[System.Drawing.Pen]::new([System.Drawing.Color]::White,2);try{$g.DrawRectangle($p,7,3,10,18);$g.DrawLine($p,10,8,14,8)}finally{$p.Dispose()} }
Draw-LineIcon 'icon-cart-inserted.png' { param($g, $s) $p=[System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(100,220,255),2);try{$g.DrawRectangle($p,7,3,10,18);$g.DrawLine($p,10,8,14,8);$g.DrawLine($p,3,12,7,12);$g.DrawLine($p,5,10,7,12);$g.DrawLine($p,5,14,7,12)}finally{$p.Dispose()} }

@'
# Original XMBFlow placeholder plane.  Four vertices, full texture UVs.
v -1.0 -1.0 0.0
v 1.0 -1.0 0.0
v 1.0 1.0 0.0
v -1.0 1.0 0.0
vt 0.0 1.0
vt 1.0 1.0
vt 1.0 0.0
vt 0.0 0.0
f 1/1 2/2 3/3
f 1/1 3/3 4/4
'@ | Set-Content -LiteralPath (Join-Path $data 'planebg.obj') -Encoding ASCII

@'
# Original XMBFlow placeholder floor plane.  Four vertices, full texture UVs.
v -1.0 0.0 -1.0
v 1.0 0.0 -1.0
v 1.0 0.0 1.0
v -1.0 0.0 1.0
vt 0.0 1.0
vt 1.0 1.0
vt 1.0 0.0
vt 0.0 0.0
f 1/1 2/2 3/3
f 1/1 3/3 4/4
'@ | Set-Content -LiteralPath (Join-Path $data 'planefloor.obj') -Encoding ASCII

$files = Get-ChildItem -LiteralPath $data -File | Sort-Object Name | ForEach-Object {
    [ordered]@{ path = "DATA/$($_.Name)"; sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant(); bytes = $_.Length }
}
[ordered]@{
    schema = 1
    source = [ordered]@{
        path = 'packaging/bootstrap-source/xmbflow-wave-v1.png'
        sha256 = (Get-FileHash -LiteralPath $WaveSource -Algorithm SHA256).Hash.ToLowerInvariant()
        provenance = 'Original project artwork generated with OpenAI image generation for XMBFlow; no reference image was used.'
    }
    generated_files = @($files)
} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $OutputDirectory 'manifest.json') -Encoding UTF8

Write-Host "Created $($files.Count) original XMBFlow placeholder assets in $data"
