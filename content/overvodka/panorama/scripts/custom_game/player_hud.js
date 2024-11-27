const LocalPlayer = Players.GetLocalPlayer()
const SubscribePanel = $("#SubscribePanel")
const TipsContainer = $("#TipsContainer")
const SecondaryAbilities = $("#DFGMSecondaryAbilities");
const DotaHUDPanel = GetDotaHud();
const DefaultSlotKeyBind = "N";
let SlotKeyBindDota = Game.GetKeybindForCommand(DOTAKeybindCommand_t.DOTA_KEYBIND_CONTROL_GROUP5);
let SlotKey = "";

function StartSecondaryAbilities() {
    let dota_sec = DotaHUDPanel.FindChildTraverse("SecondaryAbilityContainer");
    if (dota_sec) {
        dota_sec.style.marginTop = "1px"
        let Tertiary = dota_sec.FindChildrenWithClassTraverse("TertiaryAbilityContainer");
        if (Tertiary && Tertiary[0]) {
            let FindCont = Tertiary[0].FindChildTraverse("DFGMSecondaryAbilities");
            if (FindCont) {
                DeleteAllChildrenByID(Tertiary[0], "DFGMSecondaryAbilities");
            }
            SecondaryAbilities.SetParent(Tertiary[0]);
        }
    }
    let BuffsFix = DotaHUDPanel.FindChildTraverse("buffs");
    let DebuffsFix = DotaHUDPanel.FindChildTraverse("debuffs");
    if (BuffsFix && DebuffsFix) {
        BuffsFix.style.marginBottom = "200px";
        DebuffsFix.style.marginBottom = "200px";
    }

    let HighFivePanel = SecondaryAbilities.FindChildTraverse("HighFive");
    if(HighFivePanel){
        HighFivePanel.SetPanelEvent("onactivate", function(){
            CastHighFive()
        })
    }
    SetUpKeyBind();
    UpdateSecondaryAbilities();
}
function UpdateSecondaryAbilities() {
    let Unit = Players.GetLocalPlayerPortraitUnit()
    let HideOnThisUnit = true
    if(Unit && Unit != -1){
        let HighFive = Entities.GetAbilityByName( Unit, "plus_high_five" )
        if(HighFive && HighFive != -1){
            let HighFivePanel = SecondaryAbilities.FindChildTraverse("HighFive");
            if(HighFivePanel){
                HideOnThisUnit = false
                let CDRemaining = Abilities.GetCooldownTimeRemaining(HighFive)
                HighFivePanel.SetHasClass("Cooldown", CDRemaining > 0);
                HighFivePanel.SetDialogVariable("cd", CDRemaining <= 5 ? CDRemaining.toFixed(1) : CDRemaining.toFixed(0));
            }
        }
    }
    SecondaryAbilities.SetHasClass("HideAbilities", HideOnThisUnit)
    SetUpKeyBind();
    $.Schedule(0, UpdateSecondaryAbilities)
}

function CheckCastableOnUnit(Unit){
    if(Entities.IsControllableByPlayer(Unit, Players.GetLocalPlayer())){
        return true
    }else if(Entities.IsRealHero( Unit )){
        let PID = Entities.GetPlayerOwnerID( Unit )
        if(PID != -1){
            let Info = Game.GetPlayerInfo( PID )
            if(Info.player_connection_state != DOTAConnectionState_t.DOTA_CONNECTION_STATE_CONNECTED && Info.player_connection_state != DOTAConnectionState_t.DOTA_CONNECTION_STATE_NOT_YET_CONNECTED){
                return true
            }
        }
    }
    return false
}

function CastHighFive(){
    let Unit = Players.GetLocalPlayerPortraitUnit()
    if(Unit && Unit != -1 && CheckCastableOnUnit(Unit)){
        let HighFive = Entities.GetAbilityByName( Unit, "plus_high_five" )
        if(HighFive && HighFive != -1){
            Abilities.ExecuteAbility(HighFive, Unit, false);
        }
    }
}

function SetUpKeyBind() {
    let oldKey = SlotKey;
    SlotKeyBindDota = Game.GetKeybindForCommand(DOTAKeybindCommand_t.DOTA_KEYBIND_CONTROL_GROUP5);
    if (SlotKey == "") {
        SlotKey = DefaultSlotKeyBind;
    }
    if (SlotKeyBindDota != "") {
        SlotKey = SlotKeyBindDota;
    }
    if (oldKey != SlotKey) {
        let HighFivePanel = SecondaryAbilities.FindChildTraverse("HighFive");
        if (HighFivePanel) {
            HighFivePanel.SetDialogVariable("BindKey", SlotKey+"")
        }
        const cmd_name = "CastDFGMText" + Math.floor(Math.random() * 99999999);
        Game.CreateCustomKeyBind(SlotKey, cmd_name);
        Game.AddCommand(cmd_name, () => CastHighFive(), "", 0);
    }
}

function ToggleSubscribePanel(){
    SubscribePanel.SetHasClass("Show", !SubscribePanel.BHasClass("Show"))
}

function CloseSubscribePanel(){
    SubscribePanel.RemoveClass("Show")
}

function TipPlayer(){
    GameEvents.SendCustomGameEventToAllClients( "player_tipped", {tips_player:LocalPlayer, tipped_player: LocalPlayer} )
    // GameEvents.SendCustomGameEventToServer( "player_want_tip", {tips_player:LocalPlayer, tipped_player: LocalPlayer} )
}

function PlayerTipped(event){
    let panel = $.CreatePanel("Panel", TipsContainer, "", {})
    panel.BLoadLayout("file://{resources}/layout/custom_game/tip_snippet.xml", false, false)

    if(event.tipped_player == LocalPlayer || event.tips_player == LocalPlayer){
        Game.EmitSound("UUI_SOUNDS.PlayerTipped")
    }

    let LeftPlayerInfo = Game.GetPlayerInfo(event.tips_player)
    let RightPlayerInfo = Game.GetPlayerInfo(event.tipped_player)

    let LeftPlayerColor = GetHEXPlayerColor(event.tips_player)
    let RightPlayerColor = GetHEXPlayerColor(event.tipped_player)

    let LeftPlayerNamePanel = panel.FindChildTraverse("LeftPlayerName")
    let RightPlayerNamePanel = panel.FindChildTraverse("RightPlayerName")

    if(LeftPlayerNamePanel && RightPlayerNamePanel){
        LeftPlayerNamePanel.style.color = LeftPlayerColor
        RightPlayerNamePanel.style.color = RightPlayerColor
    }

    let LeftPlayerHeroPanel = panel.FindChildTraverse("LeftPlayerHero")
    let RightPlayerHeroPanel = panel.FindChildTraverse("RightPlayerHero")

    if(LeftPlayerHeroPanel && RightPlayerHeroPanel){
        let LeftHeroName = GetOvervodkaHeroName(LeftPlayerInfo.player_selected_hero)
        let RightHeroName = GetOvervodkaHeroName(RightPlayerInfo.player_selected_hero)

        LeftPlayerHeroPanel.SetImage("file://{images}/heroes/" + LeftHeroName + ".png");
        RightPlayerHeroPanel.SetImage("file://{images}/heroes/" + RightHeroName + ".png");
    }

    panel.SetDialogVariable("LeftPlayerName", LeftPlayerInfo.player_name)
    panel.SetDialogVariable("RightPlayerName", RightPlayerInfo.player_name)

    let FirstChild = TipsContainer.GetChild(0)
    if(FirstChild){
        TipsContainer.MoveChildBefore(panel, FirstChild)
    }

    panel.AddClass("Show")

    $.Schedule(5, function(){
        panel.RemoveClass("Show")
        $.Schedule(0.21, function(){
            SafeDeleteAsync(panel)
        })
    })

    SendCustomMessageToChat(event)
}

function SendCustomMessageToChat(event){
    let Hero = Players.GetPlayerHeroEntityIndex( event.tips_player )
    let HeroName = Entities.GetUnitName(Hero)
    let Info = Game.GetPlayerInfo(event.tips_player)
    let InfoTipped = Game.GetPlayerInfo(event.tipped_player)
    let playerColor = GetHEXPlayerColor(event.tips_player)
    let TippedPlayerColor = GetHEXPlayerColor(event.tipped_player)
    let OvervodkaName = GetOvervodkaHeroName(HeroName)
    let Text = `<font color='${playerColor}'>${Info.player_name}</font> ${$.Localize('#PLAYER_HUD_TIPPED')} <font color='${TippedPlayerColor}'>${InfoTipped.player_name}</font>. ${$.Localize('#PLAYER_HUD_TIPPED_Text')}`

    let ChatLines = DotaHUDPanel.FindChildTraverse("ChatLinesPanel")
    if(ChatLines){
        let msgPanel = $.CreatePanel("Panel", ChatLines, "", {class:"ChatLine"})
        msgPanel.BLoadLayout("file://{resources}/layout/custom_game/custom_chat_line.xml", false, false)
        msgPanel.hittest = false

        let HeroImage = msgPanel.FindChildTraverse("HeroImage")

        HeroImage.SetImage( "file://{images}/heroes/" + OvervodkaName + ".png" );

        msgPanel.SetDialogVariable("Text", Text)
        $.Schedule(5, function(){
            msgPanel.AddClass("ExpireThis")
        })
    }
}
(function(){
    StartSecondaryAbilities();

    DeleteAllChildren(TipsContainer)

    let fx_panel = $.CreatePanel("DOTAParticleScenePanel", $("#EffectPreview"), "", {
        class: "PreviewPanelSize",
        hittest: "false",
        particleName: "particles/econ/events/summer_2021/summer_2021_emblem_effect.vpcf",
        startActive: "true",
        particleonly: "false",
        cameraOrigin: "0 -250 225",
        lookAt: "0 0 15",
        fov: "60",
        squarePixels: "true",
        drawbackground: "true"
    });

    GameEvents.Subscribe("player_tipped", PlayerTipped)

    SubscribeAndFireNetTableByKey("players", `player_${LocalPlayer}`, function(v){
        SubscribePanel.SetHasClass("PlayerSubscribed", v.active == 1)

        if(v.active == 1){
            let Text = v.permanent == 1 ? $.Localize("#PLAYER_HUD_Subscribe_Permanent") : GetDateString(v.end_date, true)
            SubscribePanel.SetDialogVariable("EndDate", Text)
        }
    })
})();