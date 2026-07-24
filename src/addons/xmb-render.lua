-- Shared icon drawing primitives for the XMB-style renderer.
-- Callers retain ownership of their image handles and colors.
XmbRender = {}

function XmbRender.icon(image, center_x, center_y, scale, color)
    if image then
        Graphics.drawScaleImage(center_x - 48 * scale, center_y - 48 * scale, image, scale, scale, color)
    end
end

function XmbRender.glowing_icon(image, center_x, center_y, scale, glow_scale, color, glow_color)
    XmbRender.icon(image, center_x, center_y, glow_scale, glow_color)
    XmbRender.icon(image, center_x, center_y, scale, color)
end

function XmbRender.each_category(columns, visual_index, anchor_x, spacing, draw_category)
    for index, label in ipairs(columns) do
        local relative = XmbLayout.relative(index, visual_index)
        local x = XmbLayout.horizontal_x(anchor_x, index, visual_index, spacing)
        draw_category(index, label, relative, x, XmbLayout.focus(relative))
    end
end
