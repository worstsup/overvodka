"use strict";

var Prime = {};
const SubscribePanel = $("#SubscribePanel");
(function() {
    const LocalPlayer = Players.GetLocalPlayer();
    const SubscribePanel = $("#SubscribePanel");
    const DotaHUDPanel = GetDotaHud();
    let fx_panel = $.CreatePanel("DOTAParticleScenePanel", $("#EffectPreview"), "", {
        class: "PreviewPanelSize",
        hittest: "false",
        particleName: "particles/overvodka_prime_effect.vpcf",
        startActive: "true",
        particleonly: "false",
        cameraOrigin: "0 -250 225",
        lookAt: "0 0 15",
        fov: "60",
        squarePixels: "true",
        drawbackground: "true"
    });
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