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
local vertical_column = 5
local pending_column = 5
local vertical_alpha = 1
local vertical_fade_direction = 0
local vertical_fade_delay = 0
local glow_phase = 0
local held_direction = 0
local navigation_repeat = 0
local column_count = 8
local category_anchor_x = 480
local option_counts = {7, 3, 3, 3, 6, 2, 3, 2}
local selected_options = {1, 1, 1, 1, 1, 1, 1, 1}
local visual_options = {1, 1, 1, 1, 1, 1, 1, 1}
local oldpad = Controls.read()
local running = true
local category_icons = {
    Graphics.loadImage("app0:/DATA/xmb-icon-settings.png"),
    Graphics.loadImage("app0:/DATA/xmb-icon-photo.png"),
    Graphics.loadImage("app0:/DATA/xmb-icon-music.png"),
    Graphics.loadImage("app0:/DATA/xmb-icon-video.png"),
    Graphics.loadImage("app0:/DATA/xmb-icon-games.png"),
    Graphics.loadImage("app0:/DATA/xmb-icon-network.png"),
    Graphics.loadImage("app0:/DATA/xmb-icon-apps.png"),
    Graphics.loadImage("app0:/DATA/xmb-icon-apps.png")
}
local setting_icons = {
    theme = Graphics.loadImage("app0:/DATA/xmb-setting-theme.png"),
    sound = Graphics.loadImage("app0:/DATA/xmb-setting-sound.png"),
    network = Graphics.loadImage("app0:/DATA/xmb-setting-network.png"),
    display = Graphics.loadImage("app0:/DATA/xmb-setting-display.png"),
    system = Graphics.loadImage("app0:/DATA/xmb-setting-system.png"),
    time = Graphics.loadImage("app0:/DATA/xmb-setting-time.png"),
    photoviewer = Graphics.loadImage("app0:/DATA/xmb-object-photoviewer.png"),
    trophy = Graphics.loadImage("app0:/DATA/xmb-object-trophy.png"),
    saved_data = Graphics.loadImage("app0:/DATA/xmb-object-saved-data.png")
}
Sound.init()
local navigation_click = Sound.open("app0:/DATA/xmb-cursor.ogg")
local font_buffer = Extended.loadFontIntoMemory("app0:/DATA/font-SawarabiGothic-Regular.ttf")
local font = Extended.loadFontFromMemory(font_buffer)
Font.setPixelSizes(font, 18)
local category_labels = {"Settings", "Photo", "Music", "Video", "Games", "Network", "System Apps", "Homebrew Apps"}
local object_labels = {
    {"Theme Settings", "Display Settings", "Sound Settings", "Network Settings", "System Settings", "Date and Time Settings", "XMBFlow Settings"},
    {"Gallery", "Camera", "Panoramic Camera"},
    {"Music Library", "Now Playing", "Internet Radio"},
    {"Video Library", "Remote Play", "Video Settings"},
    {"Memory Stick", "Saved Data Utility", "Game Settings", "Trophy Collection", "Retro Systems", "Collections"},
    {"Internet Browser", "Online Manual"},
    {"LiveArea Apps", "Downloads", "Utilities"},
    {"Homebrew Apps", "Homebrew Utilities"}
}

local function draw_wave(base_y, phase, color)
    for x = 0, width - 8, 8 do
        local y = math.floor(base_y + math.sin((x / 92) + phase) * 28)
        Graphics.fillRect(x, x + 8, y, y + 5, color)
    end
end

local function draw_vertical_options(column, alpha)
    if alpha <= 0.01 then return end
    local selected_option = selected_options[column]
    visual_options[column] = visual_options[column] + (selected_option - visual_options[column]) * 0.18
    local visual_option = visual_options[column]
    for option = 1, option_counts[column] do
        local relative = option - visual_option
        do
            local focus = math.max(0, 1 - math.abs(relative))
            local scale = 0.42 + 0.20 * focus
            local color = Color.new(255, 255, 255, math.floor((145 + 110 * focus) * alpha))
            local pulse = 0.50 + 0.50 * ((math.sin(glow_phase / 18) + 1) * 0.5)
            local text_brightness = math.floor(145 + 110 * focus * pulse)
            local text_color = Color.new(text_brightness, text_brightness, text_brightness, math.floor((145 + 110 * focus) * alpha))
            local x = category_anchor_x
            local y = 296 + relative * 66
            local object_icon = category_icons[column]
            if column == 1 and option == 1 then object_icon = setting_icons.theme end
            if column == 1 and option == 2 then object_icon = setting_icons.display end
            if column == 1 and option == 3 then object_icon = setting_icons.sound end
            if column == 1 and option == 4 then object_icon = setting_icons.network end
            if column == 1 and option == 5 then object_icon = setting_icons.system end
            if column == 1 and option == 6 then object_icon = setting_icons.time end
            if column == 2 and option == 1 then object_icon = setting_icons.photoviewer end
            if column == 5 and option == 4 then object_icon = setting_icons.trophy end
            if column == 5 and option == 2 then object_icon = setting_icons.saved_data end
            if relative < 0 then
                y = 296 + relative * 234
            end
            if focus > 0.02 then
                local glow_scale = scale + 0.045 * focus
                Graphics.drawScaleImage(x - 48 * glow_scale, y - 48 * glow_scale, object_icon, glow_scale, glow_scale, Color.new(255, 255, 255, math.floor((40 + 100 * focus * pulse) * alpha)))
            end
            Graphics.drawScaleImage(x - 48 * scale, y - 48 * scale, object_icon, scale, scale, color)
            Font.print(font, x + 40, y - 10, object_labels[column][option], text_color)
        end
    end
end

while running do
    -- Lua Player Plus requires an explicit blend phase around 2D drawing.
    -- This matches the frame lifecycle used by the known-working export tool.
    Graphics.initBlend()
    glow_phase = glow_phase + 1
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

    -- XMB hides the object axis completely before showing the next category.
    -- Fast horizontal input updates the pending category while the axis is
    -- hidden, preventing intermediate object lists from flashing onscreen.
    visual_column = visual_column + (selected_column - visual_column) * 0.18
    if vertical_fade_direction < 0 then
        vertical_alpha = math.max(0, vertical_alpha - 0.14)
        if vertical_alpha == 0 then
            vertical_column = pending_column
            vertical_fade_direction = 1
            vertical_fade_delay = 12
        end
    elseif vertical_fade_direction > 0 then
        if vertical_fade_delay > 0 then
            vertical_fade_delay = vertical_fade_delay - 1
        else
            vertical_alpha = math.min(1, vertical_alpha + 0.06)
            if vertical_alpha == 1 then vertical_fade_direction = 0 end
        end
    end
    draw_vertical_options(vertical_column, vertical_alpha)

    for column = 1, column_count do
        local relative = column - visual_column
        local x = category_anchor_x + relative * 130
        local focus = math.max(0, 1 - math.abs(relative))
        local color = Color.new(255, 255, 255, math.floor(150 + 105 * focus))
        local pulse = 0.50 + 0.50 * ((math.sin(glow_phase / 18) + 1) * 0.5)
        local text_brightness = math.floor(145 + 110 * focus * pulse)
        local text_color = Color.new(text_brightness, text_brightness, text_brightness, math.floor(150 + 105 * focus))
        local scale = 0.82 + 0.33 * focus
        if focus > 0.02 then
            local glow_scale = scale + 0.045 * focus
            Graphics.drawScaleImage(x - 48 * glow_scale, 166 - 48 * glow_scale, category_icons[column], glow_scale, glow_scale, Color.new(255, 255, 255, math.floor(40 + 100 * focus * pulse)))
        end
        Graphics.drawScaleImage(x - 48 * scale, 166 - 48 * scale, category_icons[column], scale, scale, color)
        Font.print(font, x - 30, 226, category_labels[column], text_color)
    end

    local pad = Controls.read()
    local analog_x, analog_y = Controls.readLeftAnalog()
    local direction = 0
    if Controls.check(pad, SCE_CTRL_LEFT) or analog_x < 96 then
        direction = -1
    elseif Controls.check(pad, SCE_CTRL_RIGHT) or analog_x > 160 then
        direction = 1
    elseif Controls.check(pad, SCE_CTRL_UP) or analog_y < 96 then
        direction = -2
    elseif Controls.check(pad, SCE_CTRL_DOWN) or analog_y > 160 then
        direction = 2
    end
    if direction == 0 then
        held_direction = 0
        navigation_repeat = 0
    elseif direction ~= held_direction or navigation_repeat <= 0 then
        local is_new_direction = direction ~= held_direction
        held_direction = direction
        navigation_repeat = is_new_direction and 18 or 5
        if direction == -1 then
            selected_column = selected_column - 1
            if selected_column < 1 then selected_column = column_count end
            pending_column = selected_column
            if pending_column ~= vertical_column then vertical_fade_direction = -1 end
        elseif direction == 1 then
            selected_column = selected_column + 1
            if selected_column > column_count then selected_column = 1 end
            pending_column = selected_column
            if pending_column ~= vertical_column then vertical_fade_direction = -1 end
        elseif direction == -2 then
            selected_options[selected_column] = selected_options[selected_column] - 1
            if selected_options[selected_column] < 1 then selected_options[selected_column] = option_counts[selected_column] end
        elseif direction == 2 then
            selected_options[selected_column] = selected_options[selected_column] + 1
            if selected_options[selected_column] > option_counts[selected_column] then selected_options[selected_column] = 1 end
        end
        Sound.play(navigation_click, NO_LOOP)
    else
        navigation_repeat = navigation_repeat - 1
    end
    if Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE) then
        running = false
    end

    Graphics.termBlend()
    Screen.flip()
    Screen.waitVblankStart()
    oldpad = pad
end

Sound.close(navigation_click)
System.exit()
