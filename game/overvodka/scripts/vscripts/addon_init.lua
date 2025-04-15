require('utils')
require('server/debug_panel')
require('util/custom_indicator')
ListenToGameEvent("chat_wheel_console_command", function (data, event)
    if IsClient() then
        SendToConsole(data.command)
    end
end, nil)