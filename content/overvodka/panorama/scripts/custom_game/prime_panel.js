"use strict";

var Prime = {};
const SubscribePanel = $("#SubscribePanel");
(function() {
    const LocalPlayer = Players.GetLocalPlayer();
    const SubscribePanel = $("#SubscribePanel");
    const DotaHUDPanel = GetDotaHud();
    Prime.Initialize = function() {
        Game.EmitSound("UUI_SOUNDS.OvervodkaPrime");
        SubscribePanel.SetHasClass("Show", true)
    };
    SubscribeAndFireNetTableByKey("players", `player_${LocalPlayer}`, function(v){
        UpdatePlayerHUD(v)
    })
})();

function UpdatePlayerHUD(v){
    let bSubscribed = v.active == 1

    SubscribePanel.SetHasClass("PlayerSubscribed", bSubscribed)

    if(bSubscribed){
        let Text = v.permanent == 1 ? $.Localize("#PLAYER_HUD_Subscribe_Permanent") : GetDateString(v.end_date, true)
        SubscribePanel.SetDialogVariable("EndDate", Text)
    }
}