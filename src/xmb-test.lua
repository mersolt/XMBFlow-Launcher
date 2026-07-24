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
local submenu_open = false
local submenu_selection = 1
local submenu_visual_selection = 1
local submenu_alpha = 0
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
local submenu_labels = {"Placeholder Action", "Preview Details", "More Options"}
-- The packaged smoke entry is assembled with xmb-readonly-data.lua before
-- this source. It supplies fixed rows only, with no Vita paths or file reads.
local xmb_test_data = XmbReadOnlyData.create({
    category_rows = function(column)
        return object_labels[column] or {}
    end
})

local function draw_wave(base_y, phase, color)
    for x = 0, width - 8, 8 do
        local y = math.floor(base_y + math.sin((x / 92) + phase) * 28)
        Graphics.fillRect(x, x + 8, y, y + 5, color)
    end
end

local function get_object_icon(column, option)
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
    return object_icon
end

local function draw_vertical_options(column, alpha, anchor_x)
    if alpha <= 0.01 then return end
    local selected_option = selected_options[column]
    visual_options[column] = XmbNavigation.approach(visual_options[column], selected_option, 0.18)
    local visual_option = visual_options[column]
    XmbRender.each_vertical(1, option_counts[column], visual_option, 296, 66, 234, function(option, relative, y, focus)
        do
            local scale = 0.42 + 0.20 * focus
            local color = Color.new(255, 255, 255, math.floor((145 + 110 * focus) * alpha))
            local pulse = 0.50 + 0.50 * ((math.sin(glow_phase / 18) + 1) * 0.5)
            local text_brightness = math.floor(145 + 110 * focus * pulse)
            local text_color = Color.new(text_brightness, text_brightness, text_brightness, math.floor((145 + 110 * focus) * alpha))
            local x = anchor_x
            local object_icon = get_object_icon(column, option)
            if focus > 0.02 then
                local glow_scale = scale + 0.045 * focus
                XmbRender.glowing_icon(object_icon, x, y, scale, glow_scale, color, Color.new(255, 255, 255, math.floor((40 + 100 * focus * pulse) * alpha)))
            else
                XmbRender.icon(object_icon, x, y, scale, color)
            end
            Font.print(font, x + 40, y - 10, xmb_test_data.category_rows(column)[option], text_color)
        end
    end)
end

local function draw_submenu_options(column, parent_x)
    if submenu_alpha <= 0.01 then return end
    submenu_visual_selection = XmbNavigation.approach(submenu_visual_selection, submenu_selection, 0.18)
    XmbRender.each_vertical(1, #submenu_labels, submenu_visual_selection, 296, 66, 234, function(option, relative, y, focus)
        local scale = 0.34 + 0.16 * focus
        local icon = get_object_icon(column, ((selected_options[column] + option - 1) % option_counts[column]) + 1)
        local alpha = math.floor((130 + 125 * focus) * submenu_alpha)
        if focus > 0.02 then
            local glow_scale = scale + 0.04 * focus
            XmbRender.glowing_icon(icon, parent_x + 220, y, scale, glow_scale, Color.new(255, 255, 255, alpha), Color.new(255, 255, 255, math.floor((38 + 92 * focus) * submenu_alpha)))
        else
            XmbRender.icon(icon, parent_x + 220, y, scale, Color.new(255, 255, 255, alpha))
        end
        Font.print(font, parent_x + 260, y - 10, submenu_labels[option], Color.new(255, 255, 255, alpha))
    end)
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
    visual_column, vertical_alpha, vertical_fade_direction, vertical_fade_delay, vertical_column = XmbTransition.update(visual_column, selected_column, vertical_alpha, vertical_fade_direction, vertical_fade_delay, vertical_column, pending_column)
    local submenu_target = submenu_open and 1 or 0
    submenu_alpha = submenu_alpha + (submenu_target - submenu_alpha) * 0.14
    local parent_x = category_anchor_x - 390 * submenu_alpha
    draw_vertical_options(vertical_column, vertical_alpha * (1 - 0.52 * submenu_alpha), parent_x)
    if submenu_alpha > 0.01 then draw_submenu_options(vertical_column, parent_x) end

    XmbRender.each_category(category_labels, visual_column, parent_x, 130, function(column, _, relative, x, focus)
        local category_alpha = math.floor((150 + 105 * focus) * (column == selected_column and 1 or 1 - submenu_alpha))
        local color = Color.new(255, 255, 255, category_alpha)
        local pulse = 0.50 + 0.50 * ((math.sin(glow_phase / 18) + 1) * 0.5)
        local text_brightness = math.floor(145 + 110 * focus * pulse)
        local text_color = Color.new(text_brightness, text_brightness, text_brightness, category_alpha)
        local scale = 0.82 + 0.33 * focus
        if focus > 0.02 then
            local glow_scale = scale + 0.045 * focus
            XmbRender.glowing_icon(category_icons[column], x, 166, scale, glow_scale, color, Color.new(255, 255, 255, math.floor((40 + 100 * focus * pulse) * (column == selected_column and 1 or 1 - submenu_alpha))))
        else
            XmbRender.icon(category_icons[column], x, 166, scale, color)
        end
        Font.print(font, x - 30, 226, category_labels[column], text_color)
    end)

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
            if submenu_open then
                submenu_open = false
            else
                selected_column = XmbNavigation.move(selected_column, -1, column_count)
                pending_column = selected_column
                vertical_fade_direction = XmbTransition.request(vertical_column, pending_column, vertical_fade_direction)
            end
        elseif direction == 1 then
            if not submenu_open then
                selected_column = XmbNavigation.move(selected_column, 1, column_count)
                pending_column = selected_column
                vertical_fade_direction = XmbTransition.request(vertical_column, pending_column, vertical_fade_direction)
            end
        elseif direction == -2 then
            if submenu_open then
                submenu_selection = XmbNavigation.move(submenu_selection, -1, #submenu_labels)
            else
                selected_options[selected_column] = XmbNavigation.move(selected_options[selected_column], -1, option_counts[selected_column])
            end
        elseif direction == 2 then
            if submenu_open then
                submenu_selection = XmbNavigation.move(submenu_selection, 1, #submenu_labels)
            else
                selected_options[selected_column] = XmbNavigation.move(selected_options[selected_column], 1, option_counts[selected_column])
            end
        end
        Sound.play(navigation_click, NO_LOOP)
    else
        navigation_repeat = navigation_repeat - 1
    end
    if Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS) and not submenu_open then
        submenu_open = true
        submenu_selection = 1
        submenu_visual_selection = 1
        Sound.play(navigation_click, NO_LOOP)
    elseif Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE) then
        if submenu_open then
            submenu_open = false
            Sound.play(navigation_click, NO_LOOP)
        else
            running = false
        end
    end

    Graphics.termBlend()
    Screen.flip()
    Screen.waitVblankStart()
    oldpad = pad
end

Sound.close(navigation_click)
System.exit()
