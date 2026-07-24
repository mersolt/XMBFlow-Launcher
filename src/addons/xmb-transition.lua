-- Shared transition math for swapping the XMB vertical axis between columns.
-- It is pure state math and has no data, input, filesystem, or system access.
XmbTransition = {}

function XmbTransition.request(display_column, pending_column, direction)
    if pending_column ~= display_column then
        return -1
    end
    return direction
end

function XmbTransition.update(visual_column, selected_column, alpha, direction, delay, display_column, pending_column)
    visual_column = visual_column + (selected_column - visual_column) * 0.18
    if direction < 0 then
        alpha = math.max(0, alpha - 0.14)
        if alpha == 0 then
            display_column = pending_column
            direction = 1
            delay = 12
        end
    elseif direction > 0 then
        if delay > 0 then
            delay = delay - 1
        else
            alpha = math.min(1, alpha + 0.06)
            if alpha == 1 then
                direction = 0
            end
        end
    end
    return visual_column, alpha, direction, delay, display_column
end
