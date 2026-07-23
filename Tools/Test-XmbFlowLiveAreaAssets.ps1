[CmdletBinding()]
param([string]$SourceImage)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($SourceImage)) {
    $SourceImage = Join-Path $PSScriptRoot '..\packaging\livearea-source\xmbflow-wave-source.png'
}
Add-Type -AssemblyName System.Drawing

$expectedSourceHash = '4828FA8466DC81D85CBCA437827C986DCC933A49D6DB4F6D8B171095569A93DD'
$actualSourceHash = (Get-FileHash -LiteralPath $SourceImage -Algorithm SHA256).Hash
if ($actualSourceHash -ne $expectedSourceHash) {
    throw "Unexpected LiveArea source image hash: $actualSourceHash"
}

$output = Join-Path $env:TEMP ("xmbflow-livearea-test-" + $PID)
try {
    & (Join-Path $PSScriptRoot 'New-XmbFlowLiveAreaAssets.ps1') -OutputDirectory $output -BackgroundSource $SourceImage

    $expected = @{
        'sce_sys/icon0.png' = @(128, 128)
        'sce_sys/livearea/contents/bg.png' = @(840, 500)
        'sce_sys/livearea/contents/startup.png' = @(280, 158)
    }
    foreach ($entry in $expected.GetEnumerator()) {
        $path = Join-Path $output $entry.Key
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Missing generated asset: $($entry.Key)"
        }
        $image = [System.Drawing.Image]::FromFile($path)
        try {
            if ($image.Width -ne $entry.Value[0] -or $image.Height -ne $entry.Value[1]) {
                throw "Unexpected dimensions for $($entry.Key): $($image.Width)x$($image.Height)"
            }
        }
        finally {
            $image.Dispose()
        }
    }

    [xml]$template = Get-Content -Raw (Join-Path $output 'sce_sys/livearea/contents/template.xml')
    if ($template.livearea.liveitem.frame.liveitem.background -ne 'bg.png' -or
        $template.livearea.liveitem.frame.liveitem.image -ne 'startup.png') {
        throw 'Generated LiveArea template does not reference the expected original assets.'
    }

    Write-Host 'XMBFlow LiveArea asset checks passed.'
}
finally {
    Remove-Item -LiteralPath $output -Recurse -Force -ErrorAction SilentlyContinue
}
