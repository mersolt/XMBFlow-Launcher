param([string]$Source = (Join-Path $PSScriptRoot '..\src\addons\xmb-navigation.lua'))

$text = Get-Content -Raw $Source
foreach ($required in @('XmbNavigation = {}', 'function XmbNavigation.move(selection, direction, count)', 'function XmbNavigation.approach(current, target, amount)', 'while selection < 1 do', 'while selection > count do')) {
    if (-not $text.Contains($required)) { throw "Missing XMB navigation invariant: $required" }
}
foreach ($forbidden in @('ux0:', 'ur0:', 'vs0:', 'System.installVpk', 'System.reboot', 'System.deleteFile', 'System.deleteDirectory', 'System.copyFile', 'dofile(', 'loadfile(', 'launch_')) {
    if ($text.Contains($forbidden)) { throw "XMB navigation module must not contain: $forbidden" }
}
Write-Host 'XMB navigation checks passed.'
