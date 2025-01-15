require('utils')
require('server/debug_panel')

ListenToGameEvent("chat_wheel_console_command", function (data, event)
    if IsClient() then
        SendToConsole(data.command)
    end
end, nil)