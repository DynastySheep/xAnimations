-- Load the necessary natives
local entityLoaded = util.require_natives(1627063482)

-- Load the animation data from the JSON file
local animData = json.decode(system.load_file("anim_data.json"))

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