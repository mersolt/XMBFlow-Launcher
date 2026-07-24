-- Shared geometry for the XMB-style axes. This is pure presentation math.
XmbLayout = {}

function XmbLayout.relative(index, visual_index)
    return index - visual_index
end

function XmbLayout.focus(relative)
    return math.max(0, 1 - math.abs(relative))
end

function XmbLayout.horizontal_x(anchor_x, index, visual_index, spacing)
    return anchor_x + XmbLayout.relative(index, visual_index) * spacing
end

function XmbLayout.vertical_y(anchor_y, index, visual_index, down_spacing, up_spacing)
    local relative = XmbLayout.relative(index, visual_index)
    return anchor_y + relative * (relative < 0 and up_spacing or down_spacing)
end
