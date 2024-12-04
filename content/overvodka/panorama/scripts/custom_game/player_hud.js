const LocalPlayer = Players.GetLocalPlayer()
const Container = $("#PlayersTitlesContainer")
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

let Offset = 125
let UISCALE_X = 1;
let UISCALE_Y = 1;

let AdminPlayers = []

function UpdateTitles() {
    $.Schedule(0, UpdateTitles)

    UISCALE_X = DotaHUDPanel.actualuiscale_x;
    UISCALE_Y = DotaHUDPanel.actualuiscale_y;

    for (const Unit of Entities.GetAllHeroEntities()) {
        let bIsAdminEnt = IsAdminEnt(Unit)

        if(!bIsAdminEnt){continue}

        let bIsDead = !Entities.IsAlive( Unit )
        let bIsIllusion = Entities.IsIllusion( Unit )

        if(bIsDead && bIsIllusion){
            DeletePlayerTitle(Unit)
            continue
        }

        const panel = GetOrCreatePlayerTitlePanel(Unit)

        panel.checked = true
    }

    for (let i = Container.GetChildCount(); i > -1; i--) {
        const panel = Container.GetChild(i)
        if(panel){
            let Unit = panel.title_unit
            
            let bIsDead = !Entities.IsAlive( Unit)

            let bIsActivePlayerHero = false
            let PlayerID = Entities.GetPlayerOwnerID( Unit )
            const Hero = Players.GetPlayerHeroEntityIndex( PlayerID )

            if(Hero != -1 && Hero == Unit){
                bIsActivePlayerHero = true
            }
            if(!panel.checked && !bIsActivePlayerHero){
                DeletePlayerTitle(Unit)
                continue
            }

            panel.SetHasClass("TitleHiddenByHero", bIsDead || !panel.checked)

            panel.checked = false

            if(!bIsDead){
                let HeroOrigin = Entities.GetAbsOrigin(Unit);
                let ScreenX = Game.WorldToScreenX(HeroOrigin[0], HeroOrigin[1], HeroOrigin[2] + 250 )
                let ScreenY = Game.WorldToScreenY(HeroOrigin[0], HeroOrigin[1], HeroOrigin[2] + 250 )
                let bIsOutScreen = GameUI.GetScreenWorldPosition(ScreenX, ScreenY) == null
                panel.SetHasClass("TitleHidden", bIsOutScreen)
                if(!bIsOutScreen){
                    let x = (ScreenX - (100 * UISCALE_Y)) / UISCALE_X;
                    let y = (ScreenY - (Offset * UISCALE_Y)) / UISCALE_Y;
                    panel.style.position = (Math.floor(x)) + "px " + (Math.floor(y)) + "px" + ' 0';
                }
            }
        }
    }
    
    // for (const PlayerID of Game.GetAllPlayerIDs()) {
    //     // $.Msg("==========================================")
    //     const panel = GetOrCreatePlayerTitlePanel(PlayerID)

    //     const Hero = Players.GetPlayerHeroEntityIndex( PlayerID )

    //     panel.SetHasClass("TitleHiddenByHero", Hero == -1)

    //     if(Hero != -1){
    //         let bIsDead = !Entities.IsAlive( Hero )
    //         let bSeenByMyTeam = IsSeenByMyTeam(Hero)
    //         panel.SetHasClass("TitleHiddenByHero", bIsDead || !bSeenByMyTeam)
    //         if(!bIsDead){
    //             let HeroOrigin = Entities.GetAbsOrigin(Hero);
    //             let ScreenX = Game.WorldToScreenX(HeroOrigin[0], HeroOrigin[1], HeroOrigin[2] + 250 )
    //             let ScreenY = Game.WorldToScreenY(HeroOrigin[0], HeroOrigin[1], HeroOrigin[2] + 250 )
    //             let bIsOutScreen = GameUI.GetScreenWorldPosition(ScreenX, ScreenY) == null
    //             panel.SetHasClass("TitleHidden", bIsOutScreen)
    //             if(!bIsOutScreen){
    //                 let x = (ScreenX - (100 * UISCALE_Y)) / UISCALE_X;
    //                 let y = (ScreenY - (Offset * UISCALE_Y)) / UISCALE_Y;
    //                 panel.style.position = (Math.floor(x)) + "px " + (Math.floor(y)) + "px" + ' 0';
    //             }
    //         }
    //     }
    //     // $.Msg("==========================================")
    // }
}

function GetOrCreatePlayerTitlePanel(EntIndex) {
    let find = Container.FindChildTraverse(`unit_${EntIndex}`)
    if(find){
        return find
    }else{
        let panel = $.CreatePanel("Panel", Container, `unit_${EntIndex}`, {})
        panel.title_unit = EntIndex
        panel.BLoadLayout("file://{resources}/layout/custom_game/player_title.xml", false, false)
        return panel
    }
}

function DeletePlayerTitle(EntIndex){
    let find = Container.FindChildTraverse(`unit_${EntIndex}`)
    if(find){
        SafeDeleteAsync(find)
    }
}

function GetAdmins() {
    let Admins = []
    for (const PlayerID of Game.GetAllPlayerIDs()) {
        if(Players.IsSpectator( PlayerID )){
            continue
        }

        let PlayerInfo = CustomNetTables.GetTableValue("players", `player_${PlayerID}_special_info`)
        if(PlayerInfo){
            if(PlayerInfo.is_admin == 1){
                Admins.push(PlayerID)
            }
        }
    }
    AdminPlayers = Admins
}

function IsAdminEnt(unit){
    let PlayerID = Entities.GetPlayerOwnerID( unit )
    if(PlayerID == -1){
        return false
    }

    if(AdminPlayers.includes(PlayerID)){
        return true
    }

    return false
}

(function(){

    let BeforePanel = DotaHUDPanel.FindChildTraverse("ContextualTips");
    let Hud = DotaHUDPanel.FindChildTraverse("HUDElements");
    if (Hud && BeforePanel) {
        let Find = Hud.FindChildTraverse("PlayersTitlesContainer");
        if (Find) {
            Find.DeleteAsync(0.0);
        }
        Container.SetParent(Hud);
        Hud.MoveChildBefore(Container, BeforePanel);
    }

    GetAdmins()

    UpdateTitles()
})();



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