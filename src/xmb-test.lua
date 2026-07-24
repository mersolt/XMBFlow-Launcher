-- XMBFlow minimal package smoke test.
--
-- This is intentionally a standalone entry script for a future PC-staged
-- prototype package. It does not load RetroFlow, DATA assets, scanners,
-- launch adapters, files, caches, or configuration. The normal application
-- entry point remains src/index.lua.

local width = 960
local height = 544
local selected_column = 5
local visual_column = 5
local column_count = 7
local category_anchor_x = 480
local option_counts = {4, 3, 4, 3, 5, 3, 3}
local selected_options = {1, 1, 1, 1, 1, 1, 1}
local visual_options = {1, 1, 1, 1, 1, 1, 1}
local oldpad = Controls.read()
local running = true
local category_icons = {
    Graphics.loadImage("app0:/DATA/xmb-icon-settings.png"),
    Graphics.loadImage("app0:/DATA/xmb-icon-photo.png"),
    Graphics.loadImage("app0:/DATA/xmb-icon-music.png"),
    Graphics.loadImage("app0:/DATA/xmb-icon-video.png"),
    Graphics.loadImage("app0:/DATA/xmb-icon-games.png"),
    Graphics.loadImage("app0:/DATA/xmb-icon-network.png"),
    Graphics.loadImage("app0:/DATA/xmb-icon-apps.png")
}
local font_buffer = Extended.loadFontIntoMemory("app0:/DATA/font-SawarabiGothic-Regular.ttf")
local font = Extended.loadFontFromMemory(font_buffer)
Font.setPixelSizes(font, 18)
local category_labels = {"Settings", "Photo", "Music", "Video", "Games", "Network", "Apps"}
local object_labels = {
    {"Theme Settings", "Display Settings", "Power Settings", "System Information"},
    {"Photo Viewer", "Camera", "Slideshow"},
    {"Music Library", "Now Playing", "Internet Radio", "Sound Settings"},
    {"Video Library", "Remote Play", "Video Settings"},
    {"Memory Stick", "Saved Data Utility", "Game Settings", "Retro Systems", "Collections"},
    {"Internet Browser", "Online Manual", "Network Settings"},
    {"Downloads", "Utilities", "XMBFlow Settings"}
}

local function draw_wave(base_y, phase, color)
    for x = 0, width - 8, 8 do
        local y = math.floor(base_y + math.sin((x / 92) + phase) * 28)
        Graphics.fillRect(x, x + 8, y, y + 5, color)
    end
end

while running do
    -- Lua Player Plus requires an explicit blend phase around 2D drawing.
    -- This matches the frame lifecycle used by the known-working export tool.
    Graphics.initBlend()
    Screen.clear()
    Graphics.fillRect(0, width, 0, height, Color.new(4, 10, 28, 255))

    -- Original XMB-inspired geometry, drawn at runtime rather than loaded from
    -- a Sony-derived image or from a legacy DATA folder.
    draw_wave(356, 0.0, Color.new(0, 102, 180, 110))
    draw_wave(368, 0.7, Color.new(0, 185, 245, 190))
    draw_wave(380, 1.2, Color.new(70, 220, 255, 230))

    -- Static mock status presentation, modelled on the compact top-right
    -- arrangement in the supplied reference video.
    Font.print(font, 770, 18, "7/4  0:14", Color.new(245, 250, 255, 230))
    Graphics.fillRect(914, 940, 20, 34, Color.new(245, 250, 255, 230))
    Graphics.fillRect(940, 945, 24, 30, Color.new(245, 250, 255, 230))
    Graphics.fillRect(917, 937, 23, 31, Color.new(4, 10, 28, 255))
    Graphics.fillRect(919, 934, 25, 29, Color.new(245, 250, 255, 230))

    -- XMB keeps a fixed category anchor. The selected object list animates
    -- around it: the prior object takes a short lateral arc to the above
    -- slot, rather than vanishing behind the fixed category icon.
    visual_column = visual_column + (selected_column - visual_column) * 0.18
    local selected_option = selected_options[selected_column]
    visual_options[selected_column] = visual_options[selected_column] + (selected_option - visual_options[selected_column]) * 0.18
    local visual_option = visual_options[selected_column]
    for option = 1, option_counts[selected_column] do
        local relative = option - visual_option
        if relative >= -1 and relative <= 2 then
            local focus = math.max(0, 1 - math.abs(relative))
            local scale = 0.42 + 0.20 * focus
            local color = Color.new(math.floor(120 + 135 * focus), math.floor(160 + 75 * focus), math.floor(205 + 50 * focus), math.floor(145 + 110 * focus))
            local x = category_anchor_x
            local y = 296 + relative * 66
            if relative < 0 then
                local arc = 1 - math.abs(1 + relative * 2)
                x = x + 110 * arc
                y = 296 + relative * 234
            end
            if focus > 0.02 then
                local glow_scale = scale + 0.10 * focus
                Graphics.drawScaleImage(x - 48 * glow_scale, y - 48 * glow_scale, category_icons[selected_column], glow_scale, glow_scale, Color.new(95, 220, 255, math.floor(35 * focus)))
            end
            Graphics.drawScaleImage(x - 48 * scale, y - 48 * scale, category_icons[selected_column], scale, scale, color)
            Font.print(font, x + 40, y - 10, object_labels[selected_column][option], color)
        end
    end

    for column = 1, column_count do
        local relative = column - visual_column
        local x = category_anchor_x + relative * 130
        local focus = math.max(0, 1 - math.abs(relative))
        local color = Color.new(math.floor(120 - 15 * focus), math.floor(160 + 75 * focus), math.floor(205 + 50 * focus), math.floor(150 + 105 * focus))
        local scale = 0.82 + 0.33 * focus
        if focus > 0.02 then Graphics.drawScaleImage(x - 48 * (scale + 0.10 * focus), 166 - 48 * (scale + 0.10 * focus), category_icons[column], scale + 0.10 * focus, scale + 0.10 * focus, Color.new(95, 220, 255, math.floor(35 * focus))) end
        Graphics.drawScaleImage(x - 48 * scale, 166 - 48 * scale, category_icons[column], scale, scale, color)
        Font.print(font, x - 30, 226, category_labels[column], color)
    end

    local pad = Controls.read()
    if Controls.check(pad, SCE_CTRL_LEFT) and not Controls.check(oldpad, SCE_CTRL_LEFT) then
        selected_column = selected_column - 1
        if selected_column < 1 then selected_column = column_count end
    elseif Controls.check(pad, SCE_CTRL_RIGHT) and not Controls.check(oldpad, SCE_CTRL_RIGHT) then
        selected_column = selected_column + 1
        if selected_column > column_count then selected_column = 1 end
    elseif Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP) then
        selected_options[selected_column] = selected_options[selected_column] - 1
        if selected_options[selected_column] < 1 then selected_options[selected_column] = option_counts[selected_column] end
    elseif Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN) then
        selected_options[selected_column] = selected_options[selected_column] + 1
        if selected_options[selected_column] > option_counts[selected_column] then selected_options[selected_column] = 1 end
    elseif Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE) then
        running = false
    end

    Graphics.termBlend()
    Screen.flip()
    Screen.waitVblankStart()
    oldpad = pad
end

System.exit()
