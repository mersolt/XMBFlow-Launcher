param([string]$Source = (Join-Path $PSScriptRoot '..\src\xmb-test.lua'))

$text = Get-Content -Raw $Source
$required = @('Controls.read()', 'Screen.clear(', 'Screen.flip()', 'System.exit()', 'SCE_CTRL_CIRCLE', 'SCE_CTRL_UP', 'SCE_CTRL_DOWN', 'local option_counts = {6, 3, 3, 3, 6, 2, 4}', 'local selected_options = {1, 1, 1, 1, 1, 1, 1}', 'local visual_options = {1, 1, 1, 1, 1, 1, 1}', 'local visual_column = 5', 'Graphics.drawScaleImage')
foreach ($entry in $required) {
    if (-not $text.Contains($entry)) { throw "Missing minimal XMB profile invariant: $entry" }
}

$forbidden = @(
    'ux0:', 'ur0:', 'vs0:', 'System.installVpk', 'System.reboot',
    'System.deleteFile', 'System.deleteDirectory', 'System.copyFile',
    'dofile(', 'loadfile('
)
foreach ($entry in $forbidden) {
    if ($text.Contains($entry)) { throw "Minimal XMB profile must not contain: $entry" }
}
if ($text.Contains('SCE_CTRL_CIRCLE_MAP')) { throw 'Standalone XMB test must not rely on the legacy mapping variable.' }
if ($text.Contains('draw_placeholder_card') -or $text.Contains('Graphics.fillRect(x, x + 52')) { throw 'Standalone XMB test must render icons without obsolete markers or cards.' }
if ($text.IndexOf('local selected_option = selected_options[selected_column]') -gt $text.IndexOf('for column = 1, column_count do')) { throw 'Vertical objects must render before the fixed category axis.' }
if (-not $text.Contains('local vertical_column = 5') -or -not $text.Contains('local pending_column = 5') -or -not $text.Contains('local vertical_fade_direction = 0') -or -not $text.Contains('local vertical_fade_delay = 0') -or -not $text.Contains('vertical_fade_delay = 12') -or -not $text.Contains('vertical_alpha = math.min(1, vertical_alpha + 0.06)')) { throw 'Horizontal category changes must fully fade out, pause, then gently fade in the vertical object axis.' }
if (-not $text.Contains('y = 296 + relative * 234') -or $text.Contains('local arc = 1 - math.abs(1 + relative * 2)')) { throw 'The preceding object must move behind the fixed category icon without a lateral detour.' }
if (-not $text.Contains('math.sin(glow_phase / 18)') -or -not $text.Contains('category_icons[column], glow_scale, glow_scale, Color.new(255, 255, 255') -or -not $text.Contains('local text_color = Color.new')) { throw 'Focused icons and labels must use the persistent white XMB-style silhouette glow pulse.' }
if (-not $text.Contains('Controls.readLeftAnalog()') -or -not $text.Contains('local navigation_repeat = 0') -or -not $text.Contains('analog_x < 96') -or -not $text.Contains('analog_y > 160')) { throw 'The standalone mockup must support held D-pad and left-analog navigation.' }
if (-not $text.Contains('Sound.init()') -or -not $text.Contains('Sound.open("app0:/DATA/xmb-cursor.ogg")') -or -not $text.Contains('Sound.play(navigation_click, NO_LOOP)') -or -not $text.Contains('Sound.close(navigation_click)')) { throw 'The standalone mockup must use only the reviewed original navigation sound.' }
if ($text.Contains('if relative >= -1 and relative <= 2')) { throw 'Vertical objects must be rendered beyond the viewport and clipped by the screen.' }
foreach ($icon in @('xmb-setting-sound.png', 'xmb-setting-network.png', 'xmb-setting-display.png', 'xmb-setting-system.png', 'xmb-setting-time.png', 'xmb-object-photoviewer.png')) {
    if (-not $text.Contains("app0:/DATA/$icon")) { throw "Missing reviewed settings icon: $icon" }
}
if (-not $text.Contains('app0:/DATA/xmb-object-trophy.png') -or -not $text.Contains('"LiveArea Apps", "Homebrew Apps", "Downloads", "XMBFlow Settings"')) { throw 'Apps must expose the LiveArea and Homebrew mockup folders, and Games must expose Trophy Collection.' }
if (-not $text.Contains('"Sound Settings", "Network Settings", "System Settings", "Date and Time Settings"') -or -not $text.Contains('if column == 1 and option == 3 then object_icon = setting_icons.sound end')) { throw 'Settings icons must appear in the Settings column.' }
if (-not $text.Contains('local x = category_anchor_x + relative * 130')) { throw 'The horizontal category axis must interpolate around the fixed XMB anchor.' }
foreach ($icon in @('settings','photo','music','video','games','network','apps')) {
    if (-not $text.Contains("app0:/DATA/xmb-icon-$icon.png")) { throw "Missing reviewed category icon: $icon" }
}
if (-not $text.Contains('font-SawarabiGothic-Regular.ttf') -or -not $text.Contains('Font.print')) { throw 'Mockup text must use the reviewed packaged font.' }

Write-Host 'XMB minimal profile structural checks passed.'
