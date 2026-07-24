param([string]$Source = (Join-Path $PSScriptRoot '..\src\xmb-test.lua'))

$text = Get-Content -Raw $Source
$required = @('Controls.read()', 'Screen.clear(', 'Screen.flip()', 'System.exit()', 'SCE_CTRL_CIRCLE', 'local column_count = 6', 'local function draw_placeholder_card(column)')
foreach ($entry in $required) {
    if (-not $text.Contains($entry)) { throw "Missing minimal XMB profile invariant: $entry" }
}

$forbidden = @(
    'app0:', 'ux0:', 'ur0:', 'vs0:', 'System.installVpk', 'System.reboot',
    'System.deleteFile', 'System.deleteDirectory', 'System.copyFile',
    'dofile(', 'loadfile(', 'Sound.', 'Graphics.loadImage', 'Font.'
)
foreach ($entry in $forbidden) {
    if ($text.Contains($entry)) { throw "Minimal XMB profile must not contain: $entry" }
}
if ($text.Contains('SCE_CTRL_CIRCLE_MAP')) { throw 'Standalone XMB test must not rely on the legacy mapping variable.' }

Write-Host 'XMB minimal profile structural checks passed.'
