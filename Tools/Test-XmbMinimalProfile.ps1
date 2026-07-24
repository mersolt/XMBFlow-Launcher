param([string]$Source = (Join-Path $PSScriptRoot '..\src\xmb-test.lua'))

$text = Get-Content -Raw $Source
$required = @('Controls.read()', 'Screen.clear(', 'Screen.flip()', 'System.exit()', 'SCE_CTRL_CIRCLE', 'SCE_CTRL_UP', 'SCE_CTRL_DOWN', 'local option_counts = {4, 3, 4, 3, 5, 3}', 'Graphics.drawScaleImage')
foreach ($entry in $required) {
    if (-not $text.Contains($entry)) { throw "Missing minimal XMB profile invariant: $entry" }
}

$forbidden = @(
    'ux0:', 'ur0:', 'vs0:', 'System.installVpk', 'System.reboot',
    'System.deleteFile', 'System.deleteDirectory', 'System.copyFile',
    'dofile(', 'loadfile(', 'Sound.', 'Font.'
)
foreach ($entry in $forbidden) {
    if ($text.Contains($entry)) { throw "Minimal XMB profile must not contain: $entry" }
}
if ($text.Contains('SCE_CTRL_CIRCLE_MAP')) { throw 'Standalone XMB test must not rely on the legacy mapping variable.' }
if ($text.Contains('draw_placeholder_card') -or $text.Contains('Graphics.fillRect(x, x + 52')) { throw 'Standalone XMB test must render icons without obsolete markers or cards.' }
foreach ($icon in @('settings','photo','music','video','games','apps')) {
    if (-not $text.Contains("app0:/DATA/xmb-icon-$icon.png")) { throw "Missing reviewed category icon: $icon" }
}

Write-Host 'XMB minimal profile structural checks passed.'
