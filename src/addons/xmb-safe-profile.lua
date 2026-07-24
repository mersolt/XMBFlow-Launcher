-- Opt-in runtime guard for the personal XMBFlow safe profile.
-- It deliberately blocks mutation/helper operations while preserving the
-- read-only and launch APIs needed by the XMB launcher.
XmbSafeProfile = {}

function XmbSafeProfile.enable()
    local blocked_system_calls = {
        "installVpk", "reboot", "copyFile", "deleteFile", "deleteDirectory",
        "rename", "createDirectory"
    }

    for _, name in ipairs(blocked_system_calls) do
        if System[name] then
            System[name] = function()
                return false
            end
        end
    end

    if Network and Network.downloadFile then
        Network.downloadFile = function()
            return false
        end
    end
end
