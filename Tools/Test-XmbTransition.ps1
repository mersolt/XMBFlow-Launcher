param([string]$Source = (Join-Path $PSScriptRoot '..\src\addons\xmb-transition.lua'))

$text = Get-Content -Raw $Source
foreach ($required in @('XmbTransition = {}', 'function XmbTransition.request(display_column, pending_column, direction)', 'function XmbTransition.update(visual_column, selected_column, alpha, direction, delay, display_column, pending_column)', 'alpha = math.max(0, alpha - 0.14)', 'delay = 12', 'alpha = math.min(1, alpha + 0.06)')) {
    if (-not $text.Contains($required)) { throw "Missing XMB transition invariant: $required" }
}
foreach ($forbidden in @('ux0:', 'ur0:', 'vs0:', 'System.installVpk', 'System.reboot', 'System.deleteFile', 'System.deleteDirectory', 'System.copyFile', 'dofile(', 'loadfile(', 'launch_')) {
    if ($text.Contains($forbidden)) { throw "XMB transition module must not contain: $forbidden" }
}
Write-Host 'XMB transition checks passed.'
