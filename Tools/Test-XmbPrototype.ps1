param([string]$Source = (Join-Path $PSScriptRoot '..\src\index.lua'))

$text = Get-Content -Raw $Source
$required = @(
    'xmbSafeProfile = rawget(_G, "XMBFLOW_SAFE_PROFILE") == true',
    'xmbPrototypeEnabled = xmbSafeProfile',
    '{label = "PLAYSTATION MOBILE", category = 39}',
    '"Settings", "Photo", "Music", "Video", "Games", "Network", "System Apps", "Homebrew"',
    'xmb_prototype_system_apps_category = 46',
    'xmb_prototype_homebrew_apps_category = 2',
    'xmb_prototype_icon_paths = {',
    'local function xmb_prototype_read_only_data()',
    'XmbNavigation.move(',
    'XmbNavigation.approach(',
    'XmbTransition.request(',
    'XmbTransition.update(',
    'XmbRender.icon(',
    'XmbRender.each_category(',
    'XmbRender.each_vertical(',
    'local function xmb_prototype_category_icon(column)',
    'local function xmb_prototype_draw_vertical_object(icon, x, y, label, focus, alpha)',
    'local function xmb_prototype_draw_submenu_indicator(parent_x, child_x, y, alpha)',
    'local function xmb_prototype_current_read_only_apps_list(column)',
    'local function xmb_prototype_move_read_only_apps_selection(column, direction)',
    'local function xmb_prototype_current_inert_list(column)',
    'local function xmb_prototype_move_inert_selection(column, direction)',
    'local function xmb_prototype_read_only_item_icon(column, item)',
    'local function xmb_prototype_focus_legacy_selection(category, selection)',
    'function xmb_prototype_read_direction(pad)',
    'Controls.readLeftAnalog()',
    'function xmb_prototype_move_direction(direction)',
    'xmbPrototypeGamesGrandparentList = nil',
    'xmbPrototypeGamesParentStartOffset = 0',
    'xmbPrototypeChildAxisAlpha = xmbPrototypeChildAxisAlpha +',
    'xmbPrototypeReturningToNestedParent = true',
    'xmbPrototypeAppOptionsOpen = false',
    'local function xmb_prototype_draw_app_options()',
    '"Information", "Change category"',
    'xmbPrototypeSubmenuAlpha = xmbPrototypeSubmenuAlpha +',
    'Sound.setVolume(xmbNavigationClick, 32767)',
    '"app0:/DATA/xmb-system-browser.png"',
    '"app0:/DATA/xmb-system-party.png"',
    '"Gallery"',
    '"NPXS10003"',
    '"NPXS10004"',
    '"NPXS10008"',
    '"app0:/DATA/xmb-object-panorama.png"',
    '"app0:/DATA/xmb-setting-parental-controls.png"',
    '"app0:/DATA/xmb-system-email.png"',
    '"app0:/DATA/xmb-object-return-livearea.png"',
    '"NPXS10094"',
    '"Online Manual"',
    'local function xmb_prototype_update_transition()',
    'local function xmb_prototype_reset_navigation()',
    'local xmbPrototypeToggleChanged = false',
    'xmbPrototypeEnabled = not xmbPrototypeEnabled'
)

foreach ($entry in $required) {
    if (-not $text.Contains($entry)) { throw "Missing XMB prototype invariant: $entry" }
}

$prototypeStart = $text.IndexOf('-- XMB PROTOTYPE: presentation only.')
$prototypeEnd = $text.IndexOf('-- Function to detect inserted Vita cartridge')
if ($prototypeStart -lt 0 -or $prototypeEnd -le $prototypeStart) { throw 'Could not isolate the XMB prototype renderer for safety checks.' }
$prototypeRenderer = $text.Substring($prototypeStart, $prototypeEnd - $prototypeStart)
foreach ($forbidden in @('launch_', 'System.installVpk', 'System.reboot', 'System.copyFile', 'System.deleteFile', 'System.deleteDirectory')) {
    if ($prototypeRenderer.Contains($forbidden)) { throw "Read-only XMB renderer must not contain: $forbidden" }
}
if ($prototypeRenderer -notmatch 'category_rows = function\(category\)' -or $prototypeRenderer -notmatch 'return xCatLookup\(category\) or \{\}') {
    throw 'The XMB read-only data provider must expose category rows without a fallback scan.'
}
foreach ($removedPreviewFeature in @('xmb_prototype_existing_game_icon', 'xmb_prototype_games_item_detail', 'Graphics.drawScaleImage(810, 242')) {
    if ($prototypeRenderer.Contains($removedPreviewFeature)) {
        throw "The XMB renderer must not retain the deferred cover-preview feature: $removedPreviewFeature"
    }
}
if (-not $prototypeRenderer.Contains('xmb_prototype_object_icon(item.xmb_icon_path) or vertical_icon')) {
    throw 'The XMB Games renderer must use explicit XMB icon paths instead of RetroFlow cover paths.'
}
if ($text -match 'Settings\.write\(.*xmbPrototype' -or $text -match 'WriteConfig.*xmbPrototype') {
    throw 'XMB prototype selection must remain session-only.'
}
if (-not $text.Contains('if xmbPrototypeEnabled == false and (Controls.check(pad, SCE_CTRL_CROSS_MAP)')) {
    throw 'The legacy Cross launch handler must be disabled while the XMB prototype owns input.'
}
if ($text -notmatch 'if xmbPrototypeEnabled then\s+draw_xmb_prototype\(\)\s+else\s+if setBackground >= 1 then') {
    throw 'The safe XMB profile must render directly instead of drawing the legacy UI behind an overlay.'
}
foreach ($button in @('SCE_CTRL_TRIANGLE', 'SCE_CTRL_START', 'SCE_CTRL_SELECT', 'SCE_CTRL_SQUARE')) {
    if (-not $text.Contains("elseif xmbPrototypeEnabled == false and (Controls.check(pad, $button")) {
        throw "The legacy $button handler must be disabled while the XMB prototype owns input."
    }
}
if (-not $prototypeRenderer.Contains('showCat = category') -or -not $prototypeRenderer.Contains('xmbPrototypeEnabled = false')) {
    throw 'The XMB entry handoff must select the existing legacy category and return to the legacy renderer.'
}
if (-not $text.Contains('xmb_prototype_activate_app_selection(xmbPrototypeColumn)')) {
    throw 'The System and Homebrew Apps columns must activate their selected entry from XMB.'
}
if (-not $text.Contains('xmb_prototype_activate_inert_selection(xmbPrototypeColumn)')) {
    throw 'The Photo and Network shortcut columns must activate their mapped system apps from XMB.'
}
if (-not $text.Contains('xmbPrototypeAppOptionsOpen = true')) {
    throw 'Triangle must open the inert XMB app options pane for selected app entries.'
}
if ($text.Contains('xmbPrototypeColumn == 7 or xmbPrototypeColumn == 8) and Controls.check(pad, SCE_CTRL_UP)')) {
    throw 'Apps navigation must use the shared XMB direction handler exactly once.'
}
foreach ($rendererChrome in @('"XMB prototype"', '"Left / Right: Categories"', 'tostring(xmbPrototypeGamesSelection) .. " / "')) {
    if ($prototypeRenderer.Contains($rendererChrome)) { throw "The XMB renderer must not contain prototype chrome: $rendererChrome" }
}
foreach ($legacyListSelection in @('Graphics.fillRect(list_x - 20', 'Graphics.fillRect(92, 838')) {
    if ($prototypeRenderer.Contains($legacyListSelection)) { throw "The XMB renderer must not retain the left-aligned list selection: $legacyListSelection" }
}
if ($text.Contains('draw_xmb_prototype_placeholder_column') -or $text.Contains('xmb_prototype_placeholder_columns')) { throw 'Prototype must not render obsolete category cards.' }

Write-Host 'XMB prototype structural checks passed.'
