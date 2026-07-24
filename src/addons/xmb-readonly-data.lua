-- Shared data contract for the presentation-only XMB renderer.
--
-- Callers supply already-available rows. This module intentionally performs
-- no filesystem, scan, cache, launch, installation, copy, delete, or reboot
-- operation. A normal RetroFlow session supplies its in-memory tables; the
-- smoke package supplies fixed fixture rows.
XmbReadOnlyData = {}

function XmbReadOnlyData.create(source)
    source = source or {}
    local category_rows = source.category_rows or function()
        return {}
    end

    return {
        folders = source.folders or {},
        retro_systems = source.retro_systems or {},
        collections = source.collections or {},
        category_rows = function(category)
            return category_rows(category) or {}
        end
    }
end
