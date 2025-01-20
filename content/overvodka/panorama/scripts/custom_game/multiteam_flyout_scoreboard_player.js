const LocalPlayer = Players.GetLocalPlayer()

function ToggleMute() {
    let playerId = $.GetContextPanel().GetAttributeInt("player_id", -1);
    if (playerId !== -1) {
        var newIsMuted = !IsPlayerMuted(playerId);
        Game.SetPlayerMuted(playerId, newIsMuted);
        // $.GetContextPanel().SetHasClass("player_muted", newIsMuted);
        GameEvents.SendCustomGameEventToServer("player_want_toggle_mute", {muted_player:playerId})
    }
}

(function () {
    let playerId = $.GetContextPanel().GetAttributeInt("player_id", -1);
    SubscribeAndFireNetTableByKey("players", `player_${LocalPlayer}_mutes`, function(v){
        $.GetContextPanel().SetHasClass("player_muted", IsPlayerMuted(playerId));
    })
})();