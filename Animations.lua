-- [[Auto Updater from https://github.com/hexarobi/stand-lua-auto-updater
local status, auto_updater = pcall(require, "auto-updater")
if not status then
    local auto_update_complete = nil util.toast("Installing auto-updater...", TOAST_ALL)
    async_http.init("raw.githubusercontent.com", "/hexarobi/stand-lua-auto-updater/main/auto-updater.lua",
        function(result, headers, status_code)
            local function parse_auto_update_result(result, headers, status_code)
                local error_prefix = "Error downloading auto-updater: "
                if status_code ~= 200 then util.toast(error_prefix..status_code, TOAST_ALL) return false end
                if not result or result == "" then util.toast(error_prefix.."Found empty file.", TOAST_ALL) return false end
                filesystem.mkdir(filesystem.scripts_dir() .. "lib")
                local file = io.open(filesystem.scripts_dir() .. "lib\\auto-updater.lua", "wb")
                if file == nil then util.toast(error_prefix.."Could not open file for writing.", TOAST_ALL) return false end
                file:write(result) file:close() util.toast("Successfully installed auto-updater lib", TOAST_ALL) return true
            end
            auto_update_complete = parse_auto_update_result(result, headers, status_code)
        end, function() util.toast("Error downloading auto-updater lib. Update failed to download.", TOAST_ALL) end)
    async_http.dispatch() local i = 1 while (auto_update_complete == nil and i < 40) do util.yield(250) i = i + 1 end
    if auto_update_complete == nil then error("Error downloading auto-updater lib. HTTP Request timeout") end
    auto_updater = require("auto-updater")
end
if auto_updater == true then error("Invalid auto-updater lib. Please delete your Stand/Lua Scripts/lib/auto-updater.lua and try again") end

local default_check_interval = 604800
local auto_update_config = {
    source_url="https://raw.githubusercontent.com/DynastySheep/xAnimations/main/Animations.lua",
    script_relpath=SCRIPT_RELPATH,
    switch_to_branch=selected_branch,
    verify_file_begins_with="--",
    check_interval=86400,
    silent_updates=true,
    dependencies={
        {
            name="anim_data",
            source_url="https://raw.githubusercontent.com/DynastySheep/xAnimations/main/lib/anim_data.json",
            script_relpath="lib/anim_data.json",
            verify_file_begins_with="{",
            check_interval=default_check_interval,
            is_required=true,
        },
    }
}

auto_updater.run_auto_update(auto_update_config)

-- Auto Updater Ends Here!


util.require_natives(1627063482)

-- Register the chat command and map it to the corresponding scenario
chat.on_message(function(sender, recipient, message, team_chat)
    if sender == players.user() and team_chat then
        if animData[message] ~= nil then
            util.toast("Performing " .. message)
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(sender)
            AI.TASK_START_SCENARIO_IN_PLACE(ped, animData[message], 0, true)
            chat.clear_last_message() -- remove the last chat message (the command)
        end
    end
end)


-- Manually check for updates with a menu option
menu.action(menu.my_root(), "Check for Update", {}, "The script will automatically check for updates at most daily, but you can manually check using this option anytime.", function()
    auto_update_config.check_interval = 0
    util.toast("Checking for updates")
    auto_updater.run_auto_update(auto_update_config)
end)