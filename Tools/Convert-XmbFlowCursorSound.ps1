[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$InputPath,
    [Parameter(Mandatory = $true)][string]$FfmpegPath,
    [string]$OutputPath,
    [string]$ProvenancePath
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($OutputPath)) { $OutputPath = Join-Path $PSScriptRoot '..\assets\bootstrap-placeholders\DATA\xmb-cursor.ogg' }
if ([string]::IsNullOrWhiteSpace($ProvenancePath)) { $ProvenancePath = Join-Path $PSScriptRoot '..\assets\user-provided-cursor-sound.json' }
if (-not (Test-Path -LiteralPath $InputPath -PathType Leaf)) { throw "Missing supplied cursor sound: $InputPath" }
if (-not (Test-Path -LiteralPath $FfmpegPath -PathType Leaf)) { throw "Missing FFmpeg executable: $FfmpegPath" }
if (Test-Path -LiteralPath $OutputPath) { throw "Refusing to overwrite existing cursor sound: $OutputPath" }
if (Test-Path -LiteralPath $ProvenancePath) { throw "Refusing to overwrite existing provenance record: $ProvenancePath" }

& $FfmpegPath -hide_banner -loglevel error -i $InputPath -c:a libvorbis -q:a 5 $OutputPath
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $OutputPath -PathType Leaf)) { throw 'FFmpeg failed to create the cursor OGG.' }

[ordered]@{
    schema = 1
    provenance = 'User-provided original XMBFlow cursor audio; author asserted original work in project discussion on 2026-07-24.'
    license = 'LicenseRef-XMBFlow-Original'
    transformation = 'FFmpeg libvorbis transcode, quality 5, via Tools/Convert-XmbFlowCursorSound.ps1.'
    input_sha256 = (Get-FileHash -LiteralPath $InputPath -Algorithm SHA256).Hash.ToLowerInvariant()
    output_path = 'assets/bootstrap-placeholders/DATA/xmb-cursor.ogg'
    output_sha256 = (Get-FileHash -LiteralPath $OutputPath -Algorithm SHA256).Hash.ToLowerInvariant()
} | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath $ProvenancePath -Encoding UTF8

Write-Host "Converted original cursor audio: $OutputPath"
