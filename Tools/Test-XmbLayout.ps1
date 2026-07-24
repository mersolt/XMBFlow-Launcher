param([string]$Source = (Join-Path $PSScriptRoot '..\src\addons\xmb-layout.lua'))

$text = Get-Content -Raw $Source
foreach ($required in @('XmbLayout = {}', 'function XmbLayout.relative(index, visual_index)', 'function XmbLayout.focus(relative)', 'function XmbLayout.horizontal_x(anchor_x, index, visual_index, spacing)', 'function XmbLayout.vertical_y(anchor_y, index, visual_index, down_spacing, up_spacing)')) {
    if (-not $text.Contains($required)) { throw "Missing XMB layout invariant: $required" }
}
foreach ($forbidden in @('ux0:', 'ur0:', 'vs0:', 'System.installVpk', 'System.reboot', 'System.deleteFile', 'System.deleteDirectory', 'System.copyFile', 'dofile(', 'loadfile(', 'launch_')) {
    if ($text.Contains($forbidden)) { throw "XMB layout module must not contain: $forbidden" }
}
Write-Host 'XMB layout checks passed.'
