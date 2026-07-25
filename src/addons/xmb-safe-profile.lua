-- Opt-in runtime guard for the personal XMBFlow safe profile.
-- It deliberately blocks mutation/helper operations while preserving the
-- read-only and launch APIs needed by the XMB launcher.
XmbSafeProfile = {}

function XmbSafeProfile.enable()
    local private_root = rawget(_G, "XMBFLOW_DATA_ROOT")
    local function is_private_path(path)
        return type(path) == "string" and type(private_root) == "string" and path:sub(1, #private_root) == private_root
    end
    local function is_legacy_data_path(path)
        return type(path) == "string" and path:sub(1, 20) == "ux0:/data/RetroFlow/"
    end

    local blocked_system_calls = {
        "installVpk", "reboot", "deleteFile", "deleteDirectory", "rename"
    }

    for _, name in ipairs(blocked_system_calls) do
        if System[name] then
            System[name] = function()
                return false
            end
        end
    end

    -- "createDirectory" and "copyFile" are allowed only inside the private
    -- root, with copies restricted to bundled databases.
    -- XMBFlow may initialise its own non-system data directory.  It never
    -- receives permission to create or copy files into RetroFlow or Vita paths.
    if System.createDirectory then
        local create_directory = System.createDirectory
        System.createDirectory = function(path)
            return is_private_path(path) and create_directory(path) or false
        end
    end
    if System.copyFile then
        local copy_file = System.copyFile
        System.copyFile = function(source, destination)
            return is_private_path(destination) and type(source) == "string" and source:sub(1, 13) == "app0:/addons/" and copy_file(source, destination) or false
        end
    end

    -- Do not permit the enabled XMB profile to fall back to RetroFlow's
    -- shared state, even through an unreviewed legacy helper.
    for _, name in ipairs({"doesFileExist", "doesDirExist", "listDirectory", "openFile"}) do
        if System[name] then
            local system_call = System[name]
            System[name] = function(path, ...)
                if is_legacy_data_path(path) then return nil end
                return system_call(path, ...)
            end
        end
    end

    if Network and Network.downloadFile then
        Network.downloadFile = function()
            return false
        end
    end
end
