param([string]$Source = (Join-Path $PSScriptRoot '..\src\xmb-test.lua'))

$contractTest = Join-Path $PSScriptRoot 'Test-XmbReadonlyDataContract.ps1'
& $contractTest
$navigationTest = Join-Path $PSScriptRoot 'Test-XmbNavigation.ps1'
& $navigationTest
$layoutTest = Join-Path $PSScriptRoot 'Test-XmbLayout.ps1'
& $layoutTest
$transitionTest = Join-Path $PSScriptRoot 'Test-XmbTransition.ps1'
& $transitionTest
$renderTest = Join-Path $PSScriptRoot 'Test-XmbRender.ps1'
& $renderTest

$text = Get-Content -Raw $Source
$required = @('Controls.read()', 'Screen.clear(', 'Screen.flip()', 'System.exit()', 'SCE_CTRL_CIRCLE', 'SCE_CTRL_UP', 'SCE_CTRL_DOWN', 'local option_counts = {7, 3, 3, 3, 6, 2, 3, 2}', 'local selected_options = {1, 1, 1, 1, 1, 1, 1, 1}', 'local visual_options = {1, 1, 1, 1, 1, 1, 1, 1}', 'local visual_column = 5', 'XmbRender.glowing_icon(', 'XmbReadOnlyData.create({', 'xmb_test_data.category_rows(column)[option]', 'XmbNavigation.move(', 'XmbNavigation.approach(')
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
if ($text.IndexOf('local selected_option = selected_options[selected_column]') -gt $text.IndexOf('XmbRender.each_category(category_labels')) { throw 'Vertical objects must render before the fixed category axis.' }
if (-not $text.Contains('local vertical_column = 5') -or -not $text.Contains('local pending_column = 5') -or -not $text.Contains('local vertical_fade_direction = 0') -or -not $text.Contains('local vertical_fade_delay = 0') -or -not $text.Contains('XmbTransition.update(visual_column, selected_column, vertical_alpha, vertical_fade_direction, vertical_fade_delay, vertical_column, pending_column)')) { throw 'Horizontal category changes must fully fade out, pause, then gently fade in the vertical object axis.' }
if (-not $text.Contains('XmbLayout.vertical_y(296, option, visual_option, 66, 234)') -or $text.Contains('local arc = 1 - math.abs(1 + relative * 2)')) { throw 'The preceding object must move behind the fixed category icon without a lateral detour.' }
if (-not $text.Contains('math.sin(glow_phase / 18)') -or -not $text.Contains('XmbRender.glowing_icon(category_icons[column]') -or -not $text.Contains('local text_color = Color.new')) { throw 'Focused icons and labels must use the persistent white XMB-style silhouette glow pulse.' }
if (-not $text.Contains('Controls.readLeftAnalog()') -or -not $text.Contains('local navigation_repeat = 0') -or -not $text.Contains('analog_x < 96') -or -not $text.Contains('analog_y > 160')) { throw 'The standalone mockup must support held D-pad and left-analog navigation.' }
if (-not $text.Contains('local submenu_open = false') -or -not $text.Contains('local function draw_submenu_options(column, parent_x)') -or -not $text.Contains('Controls.check(pad, SCE_CTRL_CROSS)') -or -not $text.Contains('submenu_open = true') -or -not $text.Contains('if submenu_open then')) { throw 'The standalone mockup must open a second read-only vertical submenu axis with Cross.' }
if (-not $text.Contains('XmbNavigation.move(submenu_selection, -1, #submenu_labels)') -or -not $text.Contains('XmbNavigation.move(submenu_selection, 1, #submenu_labels)') -or -not $text.Contains('local parent_x = category_anchor_x - 390 * submenu_alpha') -or -not $text.Contains('1 - 0.52 * submenu_alpha')) { throw 'The submenu must smoothly move and dim the parent axis while it owns Up/Down navigation.' }
if (-not $text.Contains('local submenu_target = submenu_open and 1 or 0') -or -not $text.Contains('column == selected_column and 1 or 1 - submenu_alpha')) { throw 'Opening a submenu must smoothly hide non-selected horizontal categories while retaining the selected category.' }
if (-not $text.Contains('Sound.init()') -or -not $text.Contains('Sound.open("app0:/DATA/xmb-cursor.ogg")') -or -not $text.Contains('Sound.play(navigation_click, NO_LOOP)') -or -not $text.Contains('Sound.close(navigation_click)')) { throw 'The standalone mockup must use only the reviewed original navigation sound.' }
if ($text.Contains('if relative >= -1 and relative <= 2')) { throw 'Vertical objects must be rendered beyond the viewport and clipped by the screen.' }
foreach ($icon in @('xmb-setting-theme.png', 'xmb-setting-sound.png', 'xmb-setting-network.png', 'xmb-setting-display.png', 'xmb-setting-system.png', 'xmb-setting-time.png', 'xmb-object-photoviewer.png', 'xmb-object-saved-data.png')) {
    if (-not $text.Contains("app0:/DATA/$icon")) { throw "Missing reviewed settings icon: $icon" }
}
if (-not $text.Contains('app0:/DATA/xmb-object-trophy.png') -or -not $text.Contains('"System Apps", "Homebrew Apps"') -or -not $text.Contains('"LiveArea Apps", "Downloads", "Utilities"') -or -not $text.Contains('"Homebrew Apps", "Homebrew Utilities"')) { throw 'System Apps and Homebrew Apps must remain separate mockup categories, and Games must expose Trophy Collection.' }
if (-not $text.Contains('"Sound Settings", "Network Settings", "System Settings", "Date and Time Settings"') -or -not $text.Contains('if column == 1 and option == 3 then object_icon = setting_icons.sound end')) { throw 'Settings icons must appear in the Settings column.' }
if (-not $text.Contains('XmbRender.each_category(category_labels, visual_column, parent_x, 130')) { throw 'The horizontal category axis must interpolate around the submenu-adjusted XMB anchor.' }
foreach ($icon in @('settings','photo','music','video','games','network','apps')) {
    if (-not $text.Contains("app0:/DATA/xmb-icon-$icon.png")) { throw "Missing reviewed category icon: $icon" }
}
if (-not $text.Contains('font-SawarabiGothic-Regular.ttf') -or -not $text.Contains('Font.print')) { throw 'Mockup text must use the reviewed packaged font.' }

Write-Host 'XMB minimal profile structural checks passed.'
