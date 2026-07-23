[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$OutputDirectory,

    [string]$BackgroundSource
)

$ErrorActionPreference = 'Stop'

if (-not $BackgroundSource) {
    throw 'Provide -BackgroundSource with the reviewed, original XMBFlow background PNG.'
}
if (-not (Test-Path -LiteralPath $BackgroundSource -PathType Leaf)) {
    throw "Background source does not exist: $BackgroundSource"
}

Add-Type -AssemblyName System.Drawing

$contents = Join-Path $OutputDirectory 'sce_sys/livearea/contents'
New-Item -ItemType Directory -Path $contents -Force | Out-Null

function Save-ScaledImage {
    param(
        [System.Drawing.Image]$Source,
        [int]$Width,
        [int]$Height,
        [string]$Path
    )

    $image = [System.Drawing.Bitmap]::new($Width, $Height)
    $graphics = [System.Drawing.Graphics]::FromImage($image)
    try {
        $graphics.Clear([System.Drawing.Color]::FromArgb(5, 12, 31))
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

        $scale = [Math]::Max($Width / $Source.Width, $Height / $Source.Height)
        $drawWidth = [int][Math]::Ceiling($Source.Width * $scale)
        $drawHeight = [int][Math]::Ceiling($Source.Height * $scale)
        $x = [int](($Width - $drawWidth) / 2)
        $y = [int](($Height - $drawHeight) / 2)
        $graphics.DrawImage($Source, $x, $y, $drawWidth, $drawHeight)
        $image.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $graphics.Dispose()
        $image.Dispose()
    }
}

$background = [System.Drawing.Image]::FromFile((Resolve-Path -LiteralPath $BackgroundSource))
try {
    Save-ScaledImage $background 840 500 (Join-Path $contents 'bg.png')
    Save-ScaledImage $background 280 158 (Join-Path $contents 'startup.png')

    $icon = [System.Drawing.Bitmap]::new(128, 128)
    $graphics = [System.Drawing.Graphics]::FromImage($icon)
    try {
        $graphics.Clear([System.Drawing.Color]::FromArgb(5, 12, 31))
        $pen1 = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(0, 219, 255), 7)
        $pen2 = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(55, 137, 255), 5)
        try {
            $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
            $graphics.DrawBezier($pen1, 12, 87, 37, 23, 70, 115, 116, 36)
            $graphics.DrawBezier($pen2, 9, 101, 46, 42, 80, 109, 120, 50)
        }
        finally {
            $pen1.Dispose()
            $pen2.Dispose()
        }
        $icon.Save((Join-Path $OutputDirectory 'sce_sys/icon0.png'), [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $graphics.Dispose()
        $icon.Dispose()
    }
}
finally {
    $background.Dispose()
}

@'
<?xml version="1.0" encoding="utf-8"?>
<livearea style="a1">
  <liveitem name="frame1">
    <frame id="frame1">
      <liveitem>
        <background>bg.png</background>
        <image>startup.png</image>
      </liveitem>
    </frame>
  </liveitem>
</livearea>
'@ | Set-Content -LiteralPath (Join-Path $contents 'template.xml') -Encoding UTF8

Write-Host "Created original sce_sys visual assets in $OutputDirectory"
