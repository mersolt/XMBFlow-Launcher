[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$OutputDirectory,

    [string]$VitaMksfoex,

    [string]$TitleId,

    [string]$Title,

    [string]$AppVersion
)

$ErrorActionPreference = 'Stop'
$metadata = Get-Content -Raw (Join-Path $PSScriptRoot '..\packaging\metadata.json') | ConvertFrom-Json
if ([string]::IsNullOrWhiteSpace($TitleId)) { $TitleId = $metadata.title_id }
if ([string]::IsNullOrWhiteSpace($Title)) { $Title = $metadata.title }
if ([string]::IsNullOrWhiteSpace($AppVersion)) { $AppVersion = $metadata.app_version }

if ($TitleId -notmatch '^[A-Z0-9]{9}$') {
    throw 'TitleId must contain exactly nine uppercase letters or digits.'
}
if ($AppVersion -notmatch '^\d\d\.\d\d$') {
    throw 'AppVersion must use the form 00.01.'
}

if ([string]::IsNullOrWhiteSpace($VitaMksfoex)) {
    $command = Get-Command vita-mksfoex -ErrorAction SilentlyContinue
    if ($command) {
        $VitaMksfoex = $command.Source
    }
}
if ([string]::IsNullOrWhiteSpace($VitaMksfoex) -or -not (Test-Path -LiteralPath $VitaMksfoex -PathType Leaf)) {
    throw 'vita-mksfoex was not found. Install or expose VitaSDK, then pass -VitaMksfoex with its local executable path.'
}

$background = Join-Path $PSScriptRoot '..\packaging\livearea-source\xmbflow-wave-source.png'
& (Join-Path $PSScriptRoot 'New-XmbFlowLiveAreaAssets.ps1') -OutputDirectory $OutputDirectory -BackgroundSource $background

$paramSfo = Join-Path $OutputDirectory 'sce_sys\param.sfo'
& $VitaMksfoex -d 'ATTRIBUTE=0' -d 'PARENTAL_LEVEL=1' -s "APP_VER=$AppVersion" -s "TITLE_ID=$TitleId" $Title $paramSfo
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $paramSfo -PathType Leaf)) {
    throw 'vita-mksfoex did not produce sce_sys/param.sfo.'
}

Write-Host "Created candidate sce_sys metadata for $TitleId in $OutputDirectory"
