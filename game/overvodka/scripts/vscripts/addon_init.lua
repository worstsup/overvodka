require('utils')
require('server/debug_panel')
require('util/custom_indicator')
if IsClient() then
    require( 'util/functions_client' )
end

ListenToGameEvent("chat_wheel_console_command", function (data, event)
    if IsClient() then
        SendToConsole(data.command)
    end
end, nil)

if IsServer() then
    return
end

ListenToGameEvent("event_toggle_alt_cast", function(event)
    local ability = EntIndexToHScript(event.ent_index)
    if ability then
        ability.alt_casted = event.is_alted == 1
    end
end,nil)