param(
    [string]$Source = (Join-Path $PSScriptRoot '..\src\index.lua'),
    [string]$Guard = (Join-Path $PSScriptRoot '..\src\addons\xmb-safe-profile.lua')
)

$sourceText = Get-Content -Raw $Source
$guardText = Get-Content -Raw $Guard
foreach ($required in @('local xmbSafeProfile = rawget(_G, "XMBFLOW_SAFE_PROFILE") == true', 'files_table = import_cached_DB()', 'local xmbPrototypeEnabled = xmbSafeProfile')) {
    if (-not $sourceText.Contains($required)) { throw "Missing safe-profile entry invariant: $required" }
}
foreach ($required in @('XmbSafeProfile = {}', 'function XmbSafeProfile.enable()', '"installVpk"', '"reboot"', '"copyFile"', '"deleteFile"', '"deleteDirectory"', '"rename"', '"createDirectory"')) {
    if (-not $guardText.Contains($required)) { throw "Missing safe-profile guard invariant: $required" }
}
if ($guardText.Contains('System.executeUri') -or $guardText.Contains('System.launchApp')) {
    throw 'The safe profile must retain existing launch APIs.'
}
Write-Host 'XMB safe-profile structural checks passed.'
