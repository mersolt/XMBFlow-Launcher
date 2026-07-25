param([string]$Source = (Join-Path $PSScriptRoot '..\src\index.lua'))

$text = Get-Content -Raw $Source
$required = @(
    'xmbSafeProfile = rawget(_G, "XMBFLOW_SAFE_PROFILE") == true',
    'xmbPrototypeEnabled = xmbSafeProfile',
    '{label = "PlayStation Mobile", category = 39}',
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
    'local function xmb_prototype_draw_vertical_object(icon, x, y, label, focus, alpha, app_icon)',
    'function xmb_prototype_all_games()',
    'if not xmbPrototypeDebugOpen then return end',
    'local function xmb_prototype_draw_submenu_indicator(parent_x, child_x, y, alpha)',
    'local function xmb_prototype_current_read_only_apps_list(column)',
    'local function xmb_prototype_move_read_only_apps_selection(column, direction)',
    'local function xmb_prototype_current_inert_list(column)',
    'local function xmb_prototype_move_inert_selection(column, direction)',
    'function xmb_prototype_open_inert_selection(column)',
    'function xmb_prototype_go_back_inert(column)',
    'function xmb_prototype_inert_has_parent(column)',
    'local function xmb_prototype_read_only_item_icon(column, item)',
    'local function xmb_prototype_focus_legacy_selection(category, selection)',
    'function xmb_prototype_read_direction(pad)',
    'Controls.readLeftAnalog()',
    'function xmb_prototype_move_direction(direction)',
    'xmbPrototypeGamesGrandparentList = nil',
    'xmb_prototype_library_folders = {',
    'local function xmb_prototype_combined_collections()',
    '{label = "Game Data", kind = "library", xmb_icon_path = "app0:/DATA/xmb-object-game-data.png"}',
    '{label = "Game Settings", xmb_icon_path = "app0:/DATA/xmb-object-game-settings.png"}',
    'function xmb_prototype_installed_app_icon(item)',
    '{label = "Collections", kind = "collections"}',
    '{label = "Retro Systems", kind = "retro"}',
    '{label = "All Games", category = 0}',
    'xmbPrototypeGamesParentStartOffset = 0',
    'xmbPrototypeChildAxisAlpha = xmbPrototypeChildAxisAlpha +',
    'xmbPrototypeReturningToNestedParent = true',
    'xmbPrototypeAppOptionsOpen = false',
    'xmbPrototypeAppOptionsVisualSelection = 1',
    'local function xmb_prototype_draw_app_options()',
    'local function xmb_prototype_current_selected_entry()',
    'local function xmb_prototype_is_app_entry(entry)',
    'local function xmb_prototype_draw_information_card()',
    'local function xmb_prototype_information_entry(entry)',
    'local function xmb_prototype_system_app_record(reference)',
    'local function xmb_prototype_information_size(entry)',
    'local function xmb_prototype_information_directory_size(dir)',
    'if type(entry.game_path) == "string" then table.insert(paths, entry.game_path) end',
    'local size = xmb_prototype_information_directory_size("ux0:/app/" .. titleid)',
    'local function xmb_prototype_information_type(entry, source)',
    '"Information", "Change category", "Delete"',
    'xmbPrototypeAppOptionsVisualSelection = XmbNavigation.approach(',
    '"app0:/DATA/xmb-app-options-highlight.png"',
    '"app0:/DATA/xmb-app-options-panel.png"',
    'Graphics.drawScaleImage(panel_x, anchor_y - math.floor(row_height / 2), xmbPrototypeAppOptionsHighlight, 1, 1',
    'xmbPrototypeSubmenuAlpha = xmbPrototypeSubmenuAlpha +',
    'Sound.setVolume(xmbNavigationClick, 32767)',
    'Sound.setVolume(xmbNavigationCancel, 32767)',
    '"app0:/DATA/xmb-cursor-loud.ogg"',
    '"app0:/DATA/xmb-cancel.ogg"',
    'if Network.isWifiEnabled() then',
    'Graphics.drawScaleImage(806, 35, imgWifi, 1, 1, white)',
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
    'system_app = "NPXS10009"',
    'system_app = "NPXS10010"',
    '"NPXS10094"',
    '"Online Manual"',
    'function xmb_prototype_read_sfo_metadata(path)',
    'PARENTAL_LEVEL = true',
    'PSP2_SYSTEM_VER = true',
    '"Parental level"',
    '"Required firmware"',
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
if ($prototypeRenderer -notmatch 'category_rows = function\(category\)' -or -not $text.Contains('return xmb_prototype_category_rows(category)') -or -not $text.Contains('local rows = xCatLookup(category) or {}')) {
    throw 'The XMB read-only data provider must expose category rows without a fallback scan.'
}
foreach ($removedPreviewFeature in @('xmb_prototype_existing_game_icon', 'xmb_prototype_games_item_detail', 'Graphics.drawScaleImage(810, 242')) {
    if ($prototypeRenderer.Contains($removedPreviewFeature)) {
        throw "The XMB renderer must not retain the deferred cover-preview feature: $removedPreviewFeature"
    }
}
if (-not $prototypeRenderer.Contains('xmb_prototype_item_icon(item, vertical_icon)')) {
    throw 'The XMB Games renderer must use explicit XMB paths or installed app icons, not RetroFlow cover paths.'
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
if (-not $prototypeRenderer.Contains('showCat = selected.xmb_source_category or category') -or -not $prototypeRenderer.Contains('xmbPrototypeEnabled = false')) {
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
if ($text.Contains('(xmbPrototypeColumn == 7 or xmbPrototypeColumn == 8) and Controls.check(pad, SCE_CTRL_TRIANGLE)')) {
    throw 'Triangle must use selected-entry app detection instead of a column-specific check.'
}
if ($prototypeRenderer.Contains('Font.print(fnt28')) {
    throw 'The XMB renderer must use only initialized font handles.'
}
if ($text.Contains('xmbPrototypeAppOptionsOpen or xmbPrototypeAppOptionsAlpha > 0.01')) {
    throw 'Closing the app-options pane must not block XMB input.'
}
if ($text.Contains('xmbPrototypeInformationOpen or xmbPrototypeInformationAlpha > 0.01')) {
    throw 'Closing the information card must not block XMB input.'
}
if (-not $text.Contains('xmbPrototypeColumn == 5 and xmbPrototypeGamesParentList ~= nil and direction == -1')) {
    throw 'Nested Games columns must use Left as the same return path as Circle.'
}
if (-not $text.Contains('xmbPrototypeColumn == 5 and xmbPrototypeGamesParentList ~= nil and direction == 1')) {
    throw 'Nested Games columns must not switch the horizontal axis on Right.'
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
foreach ($obsoleteGamesLabel in @('"USER COLLECTIONS"', '"COLLECTIONS", kind = "categories"', '"RETRO SYSTEMS", kind = "retro"')) {
    if ($text.Contains($obsoleteGamesLabel)) { throw "Games root must not retain obsolete folder: $obsoleteGamesLabel" }
}

Write-Host 'XMB prototype structural checks passed.'
