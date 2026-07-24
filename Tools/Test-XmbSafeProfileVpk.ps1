param(
    [Parameter(Mandatory = $true)][string]$Vpk,
    [Parameter(Mandatory = $true)][string]$DataDirectory
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$expected = @('eboot.bin', 'index.lua', 'legacy-index.lua', 'LICENSE', 'sce_sys/icon0.png', 'sce_sys/param.sfo')
$expected += Get-ChildItem -LiteralPath $DataDirectory -File | ForEach-Object { "DATA/$($_.Name)" }
$root = Split-Path -Parent $PSScriptRoot
$expected += Get-ChildItem -LiteralPath (Join-Path $root 'src\addons') -File | Where-Object { $_.Name -ne 'recovery.lua' } | ForEach-Object { "addons/$($_.Name)" }
$expected += Get-ChildItem -LiteralPath (Join-Path $root 'src\translations') -File | ForEach-Object { "translations/$($_.Name)" }

$zip = [IO.Compression.ZipFile]::OpenRead($Vpk)
try {
    $actual = @($zip.Entries | Where-Object { -not $_.FullName.EndsWith('/') } | ForEach-Object FullName | Sort-Object)
    if (($actual -join "`n") -ne (($expected | Sort-Object) -join "`n")) { throw 'Safe-profile VPK file set differs from the reviewed package profile.' }
    foreach ($prefix in @('payloads/', 'boot.bin', 'boot.inf', 'addons/recovery.lua')) {
        if ($actual | Where-Object { $_ -like "$prefix*" }) { throw "Safe-profile VPK contains excluded path: $prefix" }
    }
    $reader = [IO.StreamReader]::new($zip.GetEntry('index.lua').Open())
    try { $entry = $reader.ReadToEnd() } finally { $reader.Dispose() }
    if ($entry -notmatch 'XMBFLOW_SAFE_PROFILE = true' -or $entry -notmatch 'dofile\("app0:legacy-index.lua"\)') {
        throw 'Safe-profile VPK wrapper does not enable the guarded legacy entry.'
    }
    $legacyReader = [IO.StreamReader]::new($zip.GetEntry('legacy-index.lua').Open())
    try { $legacy = $legacyReader.ReadToEnd() } finally { $legacyReader.Dispose() }
    foreach ($required in @('xmbSafeProfile = rawget(_G, "XMBFLOW_SAFE_PROFILE") == true', 'XmbSafeProfile.enable()', 'function Setup_Adrenaline()', 'function AutoMakeBootBin(', 'function launch_Adrenaline(')) {
        if (-not $legacy.Contains($required)) { throw "Safe-profile legacy entry is missing guard: $required" }
    }
} finally { $zip.Dispose() }
Write-Host "Safe-profile VPK checks passed: $((Get-FileHash -LiteralPath $Vpk -Algorithm SHA256).Hash.ToLowerInvariant())"
