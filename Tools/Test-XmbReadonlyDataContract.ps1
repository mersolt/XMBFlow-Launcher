param([string]$Source = (Join-Path $PSScriptRoot '..\src\addons\xmb-readonly-data.lua'))

$text = Get-Content -Raw $Source
foreach ($required in @('XmbReadOnlyData = {}', 'function XmbReadOnlyData.create(source)', 'folders = source.folders or {}', 'retro_systems = source.retro_systems or {}', 'collections = source.collections or {}', 'category_rows = function(category)')) {
    if (-not $text.Contains($required)) { throw "Missing XMB read-only data contract invariant: $required" }
}
foreach ($forbidden in @('ux0:', 'ur0:', 'vs0:', 'System.installVpk', 'System.reboot', 'System.deleteFile', 'System.deleteDirectory', 'System.copyFile', 'dofile(', 'loadfile(', 'launch_')) {
    if ($text.Contains($forbidden)) { throw "XMB read-only data contract must not contain: $forbidden" }
}
Write-Host 'XMB read-only data contract checks passed.'
