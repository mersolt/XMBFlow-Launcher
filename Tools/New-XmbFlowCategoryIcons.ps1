[CmdletBinding()]
param([string]$OutputDirectory)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) { $OutputDirectory = Join-Path $PSScriptRoot '..\assets\bootstrap-placeholders\DATA' }
if (-not (Test-Path -LiteralPath $OutputDirectory -PathType Container)) { throw "Missing output directory: $OutputDirectory" }

Add-Type -AssemblyName System.Drawing
$cyan = [System.Drawing.Color]::FromArgb(225, 128, 232, 255)

function New-Icon([string]$Name, [scriptblock]$Draw) {
    $path = Join-Path $OutputDirectory $Name
    if (Test-Path -LiteralPath $path) { throw "Refusing to overwrite existing icon: $path" }
    $bitmap = [System.Drawing.Bitmap]::new(96, 96)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.Clear([System.Drawing.Color]::Transparent)
        & $Draw $graphics
        $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally { $graphics.Dispose(); $bitmap.Dispose() }
}

New-Icon 'xmb-icon-settings.png' { param($g) $p=[System.Drawing.Pen]::new($cyan,5); try { foreach($y in @(24,48,72)) {$g.DrawLine($p,16,$y,80,$y)}; $g.DrawEllipse($p,28,16,16,16); $g.DrawEllipse($p,54,40,16,16); $g.DrawEllipse($p,38,64,16,16) } finally {$p.Dispose()} }
New-Icon 'xmb-icon-photo.png' { param($g) $p=[System.Drawing.Pen]::new($cyan,5); try {$g.DrawRectangle($p,12,16,72,64);$g.DrawEllipse($p,25,27,13,13);$g.DrawLine($p,19,71,42,48);$g.DrawLine($p,42,48,56,61);$g.DrawLine($p,56,61,76,39)} finally {$p.Dispose()} }
New-Icon 'xmb-icon-music.png' { param($g) $p=[System.Drawing.Pen]::new($cyan,5); try {$g.DrawLine($p,57,18,57,66);$g.DrawLine($p,57,18,78,13);$g.DrawEllipse($p,21,60,20,16);$g.DrawEllipse($p,47,66,20,16);$g.DrawLine($p,41,68,57,62)} finally {$p.Dispose()} }
New-Icon 'xmb-icon-video.png' { param($g) $p=[System.Drawing.Pen]::new($cyan,5); try {$g.DrawRectangle($p,16,18,64,60);foreach($y in @(29,48,67)){$g.DrawLine($p,16,$y,28,$y);$g.DrawLine($p,68,$y,80,$y)}} finally {$p.Dispose()} }
New-Icon 'xmb-icon-games.png' { param($g) $p=[System.Drawing.Pen]::new($cyan,5); try {$g.DrawArc($p,15,35,66,38,190,160);$g.DrawLine($p,31,56,45,56);$g.DrawLine($p,38,49,38,63);$g.DrawEllipse($p,60,50,7,7);$g.DrawEllipse($p,71,59,7,7)} finally {$p.Dispose()} }
New-Icon 'xmb-icon-apps.png' { param($g) $p=[System.Drawing.Pen]::new($cyan,5); try {foreach($x in @(18,53)){foreach($y in @(18,53)){$g.DrawRectangle($p,$x,$y,25,25)}}} finally {$p.Dispose()} }

Write-Host 'Created six original XMBFlow category icons.'
