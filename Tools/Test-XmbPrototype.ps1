param([string]$Source = (Join-Path $PSScriptRoot '..\src\index.lua'))

$text = Get-Content -Raw $Source
$required = @(
    'local xmbPrototypeEnabled = false',
    '{label = "PLAYSTATION MOBILE", category = 39}',
    '{label = "SYSTEM APPS", category = 42}',
    'local xmb_prototype_placeholder_columns = {',
    'local function draw_xmb_prototype_placeholder_column(column)',
    'local function xmb_prototype_current_apps_list()',
    'local function xmb_prototype_open_apps_selection()',
    'local function xmb_prototype_reset_navigation()',
    'local xmbPrototypeToggleChanged = false',
    'xmbPrototypeEnabled = not xmbPrototypeEnabled'
)

foreach ($entry in $required) {
    if (-not $text.Contains($entry)) { throw "Missing XMB prototype invariant: $entry" }
}

if ($text -match 'xmb_prototype_open_apps_selection\(\).*launch_') {
    throw 'Apps prototype must not activate a launch adapter.'
}
if ($text -match 'Settings\.write\(.*xmbPrototype' -or $text -match 'WriteConfig.*xmbPrototype') {
    throw 'XMB prototype selection must remain session-only.'
}
if ($text -match 'draw_xmb_prototype_placeholder_column\(.*Settings\.' -or $text -match 'draw_xmb_prototype_placeholder_column\(.*System\.') {
    throw 'Placeholder columns must remain presentation-only.'
}

Write-Host 'XMB prototype structural checks passed.'
