-- XMBFlow minimal package smoke test.
--
-- This is intentionally a standalone entry script for a future PC-staged
-- prototype package. It does not load RetroFlow, DATA assets, scanners,
-- launch adapters, files, caches, or configuration. The normal application
-- entry point remains src/index.lua.

local width = 960
local height = 544
local selected_column = 5
local column_count = 7
local oldpad = Controls.read()
local running = true

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

    for column = 1, column_count do
        local x = 90 + (column - 1) * 130
        local selected = column == selected_column
        local color = selected and Color.new(105, 235, 255, 255) or Color.new(120, 160, 205, 150)
        local top = selected and 142 or 162
        Graphics.fillRect(x, x + 52, top, top + 52, color)
        Graphics.fillRect(x + 8, x + 44, top + 8, top + 44, Color.new(4, 10, 28, 230))
    end

    local pad = Controls.read()
    if Controls.check(pad, SCE_CTRL_LEFT) and not Controls.check(oldpad, SCE_CTRL_LEFT) then
        selected_column = selected_column - 1
        if selected_column < 1 then selected_column = column_count end
    elseif Controls.check(pad, SCE_CTRL_RIGHT) and not Controls.check(oldpad, SCE_CTRL_RIGHT) then
        selected_column = selected_column + 1
        if selected_column > column_count then selected_column = 1 end
    elseif Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE) then
        running = false
    end

    Graphics.termBlend()
    Screen.flip()
    Screen.waitVblankStart()
    oldpad = pad
end

System.exit()
