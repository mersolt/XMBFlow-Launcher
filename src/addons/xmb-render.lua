-- Shared icon drawing primitives for the XMB-style renderer.
-- Callers retain ownership of their image handles and colors.
XmbRender = {}
XmbRender.filtered_images = {}

function XmbRender.icon(image, center_x, center_y, scale, color)
    if image then
        if not XmbRender.filtered_images[image] then
            Graphics.setImageFilters(image, FILTER_LINEAR, FILTER_LINEAR)
            XmbRender.filtered_images[image] = true
        end
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

function XmbRender.each_vertical(first_index, last_index, visual_index, anchor_y, down_spacing, up_spacing, draw_item)
    -- Draw from bottom to top so an item's square artwork stays in front of
    -- the next object below it instead of being covered by that object.
    for index = last_index, first_index, -1 do
        local relative = XmbLayout.relative(index, visual_index)
        local y = XmbLayout.vertical_y(anchor_y, index, visual_index, down_spacing, up_spacing)
        draw_item(index, relative, y, XmbLayout.focus(relative))
    end
end
