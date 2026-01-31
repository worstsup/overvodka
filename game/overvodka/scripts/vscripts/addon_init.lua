require('utils')
require('server/debug_panel')
require('util/custom_indicator')

if IsServer() then
    ListenToGameEvent("player_chat", function(keys)
        local pid = keys.playerid
        if pid == nil then return end

        local hero = PlayerResource:GetSelectedHeroName(pid) or ""
        CustomGameEventManager:Send_ServerToAllClients("overvodka_player_chat", {
            playerid = pid,
            hero = hero,
            text = keys.text or "",
            teamonly = keys.teamonly or 0,
        })
    end, nil)
    ListenToGameEvent("game_rules_state_change", function()
        local state = GameRules:State_Get()
        if state == 10 then
            OvervodkaGameMode:UpdateMute(_, _, _)
            CustomNetTables:SetTableValue("ov_flags", "prince", { is_present = 0 })
	        for _,entity in pairs( HeroList:GetAllHeroes()) do
                if entity:GetUnitName() == "npc_dota_hero_abaddon" then
                    SendToServerConsole("sv_alltalk 1")
                    Convars:SetInt("sv_alltalk", 1)
                    local team = entity:GetTeamNumber()
                    CustomNetTables:SetTableValue("ov_flags", "prince", { is_present = 1, team = team })
                end
            end
        end
    end, nil)
end
if IsClient() then
    require( 'util/functions_client' )
    SendToConsole("voice_vox 0")
    Convars:SetInt("voice_vox", 0)
    Convars:SetBool("dota_clientside_wearables", false)
    
    ListenToGameEvent("game_rules_state_change", function()
        local state = GameRules:State_Get()
        if state == 10 then
            if CustomNetTables:GetTableValue("ov_flags", "prince").is_present == 0 then
                return
            end

            if GetLocalPlayerTeam(GetLocalPlayerID()) == CustomNetTables:GetTableValue("ov_flags", "prince").team then
                SendToConsole("snd_voipvolume 1")
                Convars:SetFloat("snd_voipvolume", 1)
                SendToConsole("dota_chat_filter_settings 3")
                Convars:SetFloat("dota_chat_filter_settings", 3)

                SendToConsole("voice_threshold -59")
                Convars:SetInt("voice_threshold", -59)
                SendToConsole("voice_vox 2")
                Convars:SetInt("voice_vox", 2)
                SendToConsole("voice_always_sample_mic 1")
                Convars:SetInt("voice_always_sample_mic", 1)
                SendToConsole("r_farz 999999")
                Convars:SetInt("r_farz", 999999)
                local ambient_noice_correction = CustomNetTables:GetTableValue("voice_data", "ambient_noice_correction").ambient_noice_correction
                local last_print_time = GameRules:GetGameTime()

                local transmuting_counter = 0
                ListenToGameEvent('event_update_loud', function(data)
                    local stacks = Convars:GetFloat("voice_threshold")

                    if data.is_transmitting == 1 then
                        if transmuting_counter < 0 then
                            transmuting_counter = 0
                        end
                        transmuting_counter = transmuting_counter + 1
                        stacks = min(stacks + 1, -1.1)
                    else
                        if transmuting_counter > 0 then
                            transmuting_counter = 0
                        end
                        transmuting_counter = transmuting_counter - 1
                        stacks = max(stacks - 0.4, ambient_noice_correction)
                    end

                    SendToConsole("voice_threshold " .. stacks)
                    Convars:SetFloat("voice_threshold", stacks)
                end, nil)
            end
        end
    end, nil )
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