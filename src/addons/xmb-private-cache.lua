-- Private cache writer for the XMBFlow safe profile.
-- It replaces RetroFlow's cache writer only after printTable.lua has supplied
-- the serializer.  No RetroFlow path is read, cleared, or written here.
local cache_root = assert(rawget(_G, "XMBFLOW_DATA_ROOT")) .. "CACHE/"

local function write_category_cache(filename, entries)
    local handle = assert(io.open(cache_root .. filename, "w"))
    printTable(entries or {}, handle)
    handle:close()
end

function print_tables()
    -- Each configured category is rewritten independently inside XMBFlow's
    -- private cache.  Unlike RetroFlow's writer, this never clears a folder.
    for _, system in pairs(SystemsToScan) do
        if system.user_db_file and system.table then
            write_category_cache(system.user_db_file, _G[system.table])
        end
    end
end
