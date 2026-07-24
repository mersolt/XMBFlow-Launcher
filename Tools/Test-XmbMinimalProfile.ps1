param([string]$Source = (Join-Path $PSScriptRoot '..\src\xmb-test.lua'))

$text = Get-Content -Raw $Source
$required = @('Controls.read()', 'Screen.clear(', 'Screen.flip()', 'System.exit()', 'SCE_CTRL_CIRCLE', 'SCE_CTRL_UP', 'SCE_CTRL_DOWN', 'local option_counts = {4, 3, 4, 3, 5, 3, 3}', 'local selected_options = {1, 1, 1, 1, 1, 1, 1}', 'local visual_options = {1, 1, 1, 1, 1, 1, 1}', 'local visual_column = 5', 'Graphics.drawScaleImage')
foreach ($entry in $required) {
    if (-not $text.Contains($entry)) { throw "Missing minimal XMB profile invariant: $entry" }
}

$forbidden = @(
    'ux0:', 'ur0:', 'vs0:', 'System.installVpk', 'System.reboot',
    'System.deleteFile', 'System.deleteDirectory', 'System.copyFile',
    'dofile(', 'loadfile(', 'Sound.'
)
foreach ($entry in $forbidden) {
    if ($text.Contains($entry)) { throw "Minimal XMB profile must not contain: $entry" }
}
if ($text.Contains('SCE_CTRL_CIRCLE_MAP')) { throw 'Standalone XMB test must not rely on the legacy mapping variable.' }
if ($text.Contains('draw_placeholder_card') -or $text.Contains('Graphics.fillRect(x, x + 52')) { throw 'Standalone XMB test must render icons without obsolete markers or cards.' }
if ($text.IndexOf('local selected_option = selected_options[selected_column]') -gt $text.IndexOf('for column = 1, column_count do')) { throw 'Vertical objects must render before the fixed category axis.' }
if (-not $text.Contains('local vertical_column = 5') -or -not $text.Contains('local pending_column = 5') -or -not $text.Contains('local vertical_fade_direction = 0') -or -not $text.Contains('vertical_alpha = math.max(0, vertical_alpha - 0.14)')) { throw 'Horizontal category changes must fully fade out the vertical object axis before showing the next category.' }
if (-not $text.Contains('y = 296 + relative * 234') -or $text.Contains('local arc = 1 - math.abs(1 + relative * 2)')) { throw 'The preceding object must move behind the fixed category icon without a lateral detour.' }
if (-not $text.Contains('math.sin(glow_phase / 18)') -or -not $text.Contains('Font.print(font, x + 39, y - 11') -or -not $text.Contains('Font.print(font, x - 31, 225')) { throw 'Focused icons and labels must use the XMB-style glow pulse.' }
if (-not $text.Contains('local x = category_anchor_x + relative * 130')) { throw 'The horizontal category axis must interpolate around the fixed XMB anchor.' }
foreach ($icon in @('settings','photo','music','video','games','network','apps')) {
    if (-not $text.Contains("app0:/DATA/xmb-icon-$icon.png")) { throw "Missing reviewed category icon: $icon" }
}
if (-not $text.Contains('font-SawarabiGothic-Regular.ttf') -or -not $text.Contains('Font.print')) { throw 'Mockup text must use the reviewed packaged font.' }

Write-Host 'XMB minimal profile structural checks passed.'
