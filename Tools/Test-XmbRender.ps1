param([string]$Source = (Join-Path $PSScriptRoot '..\src\addons\xmb-render.lua'))

$text = Get-Content -Raw $Source
foreach ($required in @('XmbRender = {}', 'function XmbRender.icon(image, center_x, center_y, scale, color)', 'function XmbRender.glowing_icon(image, center_x, center_y, scale, glow_scale, color, glow_color)', 'function XmbRender.each_category(columns, visual_index, anchor_x, spacing, draw_category)', 'function XmbRender.each_vertical(first_index, last_index, visual_index, anchor_y, down_spacing, up_spacing, draw_item)', 'Graphics.drawScaleImage', 'XmbRender.icon(image, center_x, center_y, glow_scale, glow_color)')) {
    if (-not $text.Contains($required)) { throw "Missing XMB render invariant: $required" }
}
foreach ($forbidden in @('ux0:', 'ur0:', 'vs0:', 'System.installVpk', 'System.reboot', 'System.deleteFile', 'System.deleteDirectory', 'System.copyFile', 'dofile(', 'loadfile(', 'launch_')) {
    if ($text.Contains($forbidden)) { throw "XMB render module must not contain: $forbidden" }
}
Write-Host 'XMB render checks passed.'
