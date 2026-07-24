-- Shared, presentation-only XMB navigation primitives.
-- This module owns no library data and performs no system or file action.
XmbNavigation = {}

function XmbNavigation.move(selection, direction, count)
    if count == nil or count < 1 then
        return 0
    end

    selection = selection + direction
    while selection < 1 do
        selection = selection + count
    end
    while selection > count do
        selection = selection - count
    end
    return selection
end

function XmbNavigation.approach(current, target, amount)
    return current + (target - current) * amount
end
