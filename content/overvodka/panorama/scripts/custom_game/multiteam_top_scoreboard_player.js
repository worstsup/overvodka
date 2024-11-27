const LocalPlayer = Players.GetLocalPlayer()

function PortraitClicked() {
    // TODO: ctrl and alt click support
    Players.PlayerPortraitClicked($.GetContextPanel().GetAttributeInt("player_id", -1), false, false);
}

function TipClicked() {
    GameEvents.SendCustomGameEventToServer( "player_want_tip", {tips_player:LocalPlayer, tipped_player: $.GetContextPanel().GetAttributeInt("player_id", -1)} )
}