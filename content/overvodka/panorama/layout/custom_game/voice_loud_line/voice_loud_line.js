// url("s2r://panorama/images/hud/voiceicon_regular_png.vtex")
// url("s2r://panorama/images/hud/voiceicon_mute_png.vtex")


let VoiceChat = FindDotaHudElement("VoiceChat")
let ambient_noice_correction = CustomNetTables.GetTableValue("voice_data", "ambient_noice_correction").ambient_noice_correction * -1
let last_game_time = Game.GetGameTime()
let last_counter = Game.GetConvarInt("voice_threshold")
let last_setver_counter = Game.GetConvarInt("voice_threshold")
let currentPercent = 0

function ScreemLoop() {
    let counter = Game.GetConvarFloat("voice_threshold")
    let portait = Players.GetLocalPlayerPortraitUnit()
// print(counter)
    if (!HasModifier(portait, "modifier_prince_r") ) {
        $.GetContextPanel().style.visibility = "collapse"
        $.GetContextPanel().style.opacity = "0"
        $.GetContextPanel().visible = false
    }
    else {
        $.GetContextPanel().visibility = "visible"
        $.GetContextPanel().style.opacity = "1"
        $.GetContextPanel().visible = true
        let postition = GameUI.GetScreenWorldPosition( GameUI.GetCursorPosition() )
        let order = {
            OrderType: dotaunitorder_t.DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position: postition,
            QueueBehavior: OrderQueueBehavior_t.DOTA_ORDER_QUEUE_NEVER,
            ShowEffects: false
        }
        Game.PrepareUnitOrders( order )
    }
    if (!VoiceChat) {
        VoiceChat = FindDotaHudElement("VoiceChat")
    }

    if (counter == -60 || counter == -59) {
        counter = last_counter
    }

    if (VoiceChat) {
        let targetPercent = (counter + ambient_noice_correction) / ambient_noice_correction * 100
        targetPercent = Math.max(0, Math.min(100, targetPercent))
    
        const accel = 0.04
        currentPercent += (targetPercent - currentPercent) * accel
        if (currentPercent < 0) {
            currentPercent = 0
        }
    
        // $("#ChannelBarProgress_custom").style.width = Math.max(1, currentPercent.toFixed(2)) + "%"
        $("#ChannelBarProgress_custom_container").style.clip = "rect( 0%," + Math.max(1, currentPercent.toFixed(2)) + "%, 100%, 0% )"
        // $("#ChannelBarProgress_custom_container").style.clip = "rect( 0%," + Math.max(1, 100) + "%, 100%, 0% )"

        GameEvents.SendEventClientSide("event_update_loud", {
            "is_transmitting": VoiceChat.BHasClass("Transmitting"),
            "voice_level": currentPercent * ambient_noice_correction
        })

        if (last_setver_counter != counter && (last_game_time + 1/30) < Game.GetGameTime()) {
            last_game_time = Game.GetGameTime()
            last_setver_counter = counter
            GameEvents.SendCustomGameEventToServer("event_update_loud_server", {
                "voice_level": counter
            })
        }
        
        if (!Game.IsInToolsMode()) {
            VoiceChat.style.visibility = "collapse"
            VoiceChat.style.opacity = "0"
            VoiceChat.visible = false
        }
        
        last_counter = counter
    }

    $.Schedule(0, ScreemLoop)
}

$.Schedule(0, ScreemLoop)
