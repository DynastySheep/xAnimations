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
            source_url="https://raw.githubusercontent.com/DynastySheep/xAnimations/main/lib/anim_data.lua",
            script_relpath="lib/anim_data.lua",
            verify_file_begins_with="return",
            check_interval=default_check_interval,
            is_required=true,
        },
    }
}

auto_updater.run_auto_update(auto_update_config)

-- Auto Updater Ends Here!

local animData = require("anim_data")
util.require_natives(1627063482)

local currentProp = nil

-- Handle chat messages
chat.on_message(function(sender, recipient, message, team_chat)

    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
    if currentProp and ENTITY.DOES_ENTITY_EXIST(currentProp) then
        entities.delete_by_handle(currentProp)
    end

    if sender == players.user() and team_chat then
        local ped = PLAYER.PLAYER_PED_ID()
        if message == "stop" or message == "s" then
            util.toast("Stopping Animation")
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)

            if currentProp and ENTITY.DOES_ENTITY_EXIST(currentProp) then
                entities.delete_by_handle(currentProp)
            end
        else
            local anim = animData[message]

            local animScenario = anim.scenario
            local animDict = anim.dictionary

            if anim ~= nil then
                if animScenario ~= nil then
                    TASK.TASK_START_SCENARIO_IN_PLACE(ped, animScenario, 0, false)
                else
                    if (anim.prop ~= null) then
                        local pos = ENTITY.GET_ENTITY_COORDS(ped)
                        local boneIndex = PED.GET_PED_BONE_INDEX(ped, anim.bone)
                        local hash = util.joaat(anim.prop)
                        STREAMING.REQUEST_MODEL(hash)

                        while not STREAMING.HAS_MODEL_LOADED(hash) do
                            util.yield()
                        end

                        local object = entities.create_object(hash, pos)

                        currentProp = object
                        ENTITY.ATTACH_ENTITY_TO_ENTITY(object, ped, boneIndex, 
                        anim.placement[1] or 0.0, 
                        anim.placement[2] or 0.0,
                        anim.placement[3] or 0.0, 
                        anim.placement[4] or 0.0, 
                        anim.placement[5] or 0.0,
                        anim.placement[6] or 0.0, 
                        false, true, false, true, 1, true)
                        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
                    end

                    STREAMING.REQUEST_ANIM_DICT(animDict)

                    while not STREAMING.HAS_ANIM_DICT_LOADED(animDict) do
                        util.yield()
                    end

                    TASK.TASK_PLAY_ANIM(ped, animDict, anim.name, 8.0, 8.0, anim.duration, anim.flag, 0.0, false, false, false)

                    STREAMING.REMOVE_ANIM_DICT(animDict)
                end
            end
        end
    end
end)

menu.action(menu.my_root(), "Check for Update", {}, "The script will automatically check for updates at most daily, but you can manually check using this option anytime.", function()
    auto_update_config.check_interval = 0
    util.toast("Checking for updates")
    auto_updater.run_auto_update(auto_update_config)
end)