param([string]$Source = (Join-Path $PSScriptRoot '..\src\index.lua'))

$text = Get-Content -Raw $Source
$required = @(
    'local xmbPrototypeEnabled = false',
    '{label = "PLAYSTATION MOBILE", category = 39}',
    '"SETTINGS", "PHOTO", "MUSIC", "VIDEO", "GAMES", "NETWORK", "SYSTEM APPS", "HOMEBREW APPS"',
    'local xmb_prototype_system_apps_category = 42',
    'local xmb_prototype_homebrew_apps_category = 2',
    'local xmb_prototype_icon_paths = {',
    'local function xmb_prototype_read_only_data()',
    'XmbNavigation.move(',
    'XmbNavigation.approach(',
    'local function xmb_prototype_category_icon(column)',
    'local function xmb_prototype_current_read_only_apps_list(column)',
    'local function xmb_prototype_move_read_only_apps_selection(column, direction)',
    'local function xmb_prototype_existing_game_icon(item)',
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
$gameIconStart = $prototypeRenderer.IndexOf('local function xmb_prototype_existing_game_icon(item)')
$gameIconEnd = $prototypeRenderer.IndexOf("end`n", $gameIconStart)
if ($gameIconStart -lt 0 -or $gameIconEnd -le $gameIconStart) { throw 'Could not isolate the XMB game-art helper.' }
$gameIconHelper = $prototypeRenderer.Substring($gameIconStart, $gameIconEnd - $gameIconStart)
if ($gameIconHelper.Contains('Graphics.loadImage') -or $gameIconHelper.Contains('Threads.addTask')) {
    throw 'The XMB game-art helper must reuse loaded handles and must not load or queue artwork.'
}
if ($text -match 'Settings\.write\(.*xmbPrototype' -or $text -match 'WriteConfig.*xmbPrototype') {
    throw 'XMB prototype selection must remain session-only.'
}
if ($text.Contains('draw_xmb_prototype_placeholder_column') -or $text.Contains('xmb_prototype_placeholder_columns')) { throw 'Prototype must not render obsolete category cards.' }

Write-Host 'XMB prototype structural checks passed.'
