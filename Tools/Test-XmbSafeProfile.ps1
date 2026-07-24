param(
    [string]$Source = (Join-Path $PSScriptRoot '..\src\index.lua'),
    [string]$Guard = (Join-Path $PSScriptRoot '..\src\addons\xmb-safe-profile.lua')
)

$sourceText = Get-Content -Raw $Source
$guardText = Get-Content -Raw $Guard
foreach ($required in @('xmbSafeProfile = rawget(_G, "XMBFLOW_SAFE_PROFILE") == true', 'files_table = import_cached_DB()', 'xmbPrototypeEnabled = xmbSafeProfile')) {
    if (-not $sourceText.Contains($required)) { throw "Missing safe-profile entry invariant: $required" }
}
foreach ($required in @('if not xmbSafeProfile and string.match(System.getBootParams() or "", "recovery") then', 'System.setGpuXbarSpeed(166)', 'if not xmbSafeProfile then' + [Environment]::NewLine + '        Check_Adrenaline_Compatibility()')) {
    if (-not $sourceText.Contains($required)) { throw "Missing safe-profile startup gate: $required" }
}
foreach ($required in @('function Setup_Adrenaline()', 'function AutoMakeBootBin(', 'function launch_Adrenaline(')) {
    $start = $sourceText.IndexOf($required)
    if ($start -lt 0) { throw "Missing legacy helper boundary: $required" }
    $slice = $sourceText.Substring($start, [Math]::Min(260, $sourceText.Length - $start))
    if (-not $slice.Contains('if xmbSafeProfile then')) { throw "Safe profile must return before $required performs work." }
}
foreach ($required in @('function launch_vita_title(def_titleid)', 'if xmbSafeProfile then' + [Environment]::NewLine + '        if type(def_titleid) == "string" and string.match(def_titleid, "^[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]$") then', 'System.launchApp(def_titleid)')) {
    if (-not $sourceText.Contains($required)) { throw "Missing safe-profile native launch bridge: $required" }
}
foreach ($required in @('XmbSafeProfile = {}', 'function XmbSafeProfile.enable()', '"installVpk"', '"reboot"', '"copyFile"', '"deleteFile"', '"deleteDirectory"', '"rename"', '"createDirectory"')) {
    if (-not $guardText.Contains($required)) { throw "Missing safe-profile guard invariant: $required" }
}
if ($guardText.Contains('System.executeUri') -or $guardText.Contains('System.launchApp')) {
    throw 'The safe profile must retain existing launch APIs.'
}
Write-Host 'XMB safe-profile structural checks passed.'
