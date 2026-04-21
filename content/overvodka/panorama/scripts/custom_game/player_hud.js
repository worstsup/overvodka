const LocalPlayer = Players.GetLocalPlayer()
const Container = $("#PlayersTitlesContainer")
const TipsContainer = $("#TipsContainer")
const SecondaryAbilities = $("#DFGMSecondaryAbilities");
const DoubleRating = $("#DoubleRating");
const TeamLeavedEncounter = $("#TeamLeavedEncounter");
const ChaosSelectionRoot = $("#ChaosSelectionRoot");
const ChaosSelectionTimerText = $("#ChaosSelectionTimerText");
const ChaosSelectionTimerFill = $("#ChaosSelectionTimerFill");
const ChaosHistoryPanel = $("#ChaosHistoryPanel");
const ChaosHistoryEntries = $("#ChaosHistoryEntries");
const ChaosHistoryToggleButton = $("#ChaosHistoryToggleButton");
const DotaHUDPanel = GetDotaHud();
let SilvernameFacet2Target = -1;
let DamagePanel = null;
let EpsteinWSquares = {};
let MisoloQMarkers = {};
let ChaosSelectionCards = {};
let ChaosSelectionEndTime = -1;
let ChaosSelectionSeq = -1;
let ChaosSelectionTimerSeq = 0;
let ChaosHistoryCollapsed = false;
let ChaosHistoryHasEntries = false;
let ChaosHistoryHiddenByShop = false;
const CHAOS_HISTORY_ANIM_DURATION = 0.24;
const CHAOS_HISTORY_HIGHLIGHT_DURATION = 10.0;
let ChaosHistoryInitialized = false;
let ChaosHistoryLatestSignature = null;
let ChaosHistoryHighlightSignature = null;
let ChaosHistoryHighlightUntil = 0;
let ChaosHistoryHighlightSeq = 0;

const ChaosCardPanels = {
    1: $("#ChaosCard1"),
    2: $("#ChaosCard2"),
    3: $("#ChaosCard3"),
};

const ChaosCardTitles = {
    1: $("#ChaosCardTitle1"),
    2: $("#ChaosCardTitle2"),
    3: $("#ChaosCardTitle3"),
};

const ChaosCardDescriptions = {
    1: $("#ChaosCardDesc1"),
    2: $("#ChaosCardDesc2"),
    3: $("#ChaosCardDesc3"),
};

let dota_glyph = DotaHUDPanel.FindChildTraverse("GlyphScanContainer");
let roshan = DotaHUDPanel.FindChildTraverse("RoshanTimerContainer");
let tormentor = DotaHUDPanel.FindChildTraverse("TormentorTimerContainer");
let facet_icon = DotaHUDPanel.FindChildrenWithClassTraverse("FacetHolder");
if (dota_glyph && roshan && tormentor && Game.GetMapInfo().map_display_name != "overvodka_5x5") {
    dota_glyph.style.visibility = "collapse";
    roshan.style.visibility = "collapse";
    tormentor.style.visibility = "collapse";
}

let SlotsKeys = [
    {
        Default: "N",
        Dota: DOTAKeybindCommand_t.DOTA_KEYBIND_CONTROL_GROUP5,
        Current: "",
        Slot: "HighFive",
        Func: CastHighFive,
    },
    {
        Default: "K",
        Dota: DOTAKeybindCommand_t.DOTA_KEYBIND_CONTROL_GROUP6,
        Current: "",
        Slot: "Seasonal1",
        Func: CastSeasonal1,
    },
    {
        Default: "L",
        Dota: DOTAKeybindCommand_t.DOTA_KEYBIND_CONTROL_GROUP7,
        Current: "",
        Slot: "Seasonal2",
        Func: CastSeasonal2,
    },
]

let DoubleRatingLastTime = 0

let TeamLeavedSequence = 0

function GetMinuteText(minutes){
    let AbsMinutes = Math.abs(minutes)
    let LastTwoDigits = AbsMinutes % 100
    let LastDigit = AbsMinutes % 10

    if(LastTwoDigits >= 11 && LastTwoDigits <= 14){
        return $.Localize("#PLAYER_HUD_TeamLeavedValue2")
    }
    if(LastDigit == 1){
        return $.Localize("#PLAYER_HUD_TeamLeavedValue")
    }
    if(LastDigit >= 2 && LastDigit <= 4){
        return $.Localize("#PLAYER_HUD_TeamLeavedValue3")
    }
    return $.Localize("#PLAYER_HUD_TeamLeavedValue2")
}

const LocalizeFormat = function () {
	let formatted = $.Localize(arguments[0]);
	for (let i = 1; i < arguments.length; i++) {
		const regex = new RegExp(`%s${i}`, 'g');
		formatted = formatted.replace(regex, arguments[i]);
	}
	return formatted;
};

const GetPlayerColorHex = (playerID) => {
	let color = Players.GetPlayerColor(playerID).toString(16);
	color = color.substring(6, 8) + color.substring(4, 6) + color.substring(2, 4) + color.substring(0, 2);
	return `#${color}`;
};


const CHAT_PATCH_RETRIES = 12;
const CHAT_PATCH_INTERVAL = 0.05;
const CHAT_MAX_LINES_SCAN = 25;

function UpdateInnateIconOffset() {
    if (!facet_icon) {
        facet_icon = DotaHUDPanel.FindChildrenWithClassTraverse("FacetHolder");
    }

    if (facet_icon) {
        facet_icon[0].style.visibility = "collapse";
    }

    $.Schedule(0.5, UpdateInnateIconOffset);
}

function _GetChatRoot() {
    const hud = GetDotaHud && GetDotaHud();
    if (!hud) return null;

    return (
        hud.FindChildTraverse("ChatLinesContainer") ||
        hud.FindChildTraverse("ChatLinesPanel") ||
        hud.FindChildTraverse("ChatLines")
    );
}

function _FindInlineImagesRecursive(panel, outArr) {
    if (!panel) return;
    if (panel.paneltype === "Image" && panel.id && panel.id.startsWith("InlineImage")) {
        outArr.push(panel);
    }
    const n = panel.GetChildCount ? panel.GetChildCount() : 0;
    for (let i = 0; i < n; i++) {
        _FindInlineImagesRecursive(panel.GetChild(i), outArr);
    }
}

function _StripTags(s) {
    return (s || "").replace(/<[^>]*>/g, "").replace(/\s+/g, " ").trim();
}

function _LineText(linePanel) {
    let res = [];
    const stack = [linePanel];
    while (stack.length) {
        const p = stack.pop();
        if (!p) continue;
        if (p.paneltype === "Label" && typeof p.text === "string" && p.text.length > 0) {
            res.push(p.text);
        }
        const n = p.GetChildCount ? p.GetChildCount() : 0;
        for (let i = 0; i < n; i++) stack.push(p.GetChild(i));
    }
    return _StripTags(res.join(" "));
}

function _GetChatLines(chatRoot) {
    if (!chatRoot) return [];

    if (chatRoot.FindChildrenWithClassTraverse) {
        const arr = chatRoot.FindChildrenWithClassTraverse("ChatLine");
        if (arr && arr.length) return arr;
    }

    const out = [];
    const n = chatRoot.GetChildCount ? chatRoot.GetChildCount() : 0;
    for (let i = 0; i < n; i++) out.push(chatRoot.GetChild(i));
    return out;
}

function PatchHeroIconInChatPrintf(playerID, heroName, rawText) {
    const iconPath = "file://{images}/heroes/" + GetOvervodkaHeroName(heroName) + ".png";
    const needle = _StripTags(rawText);
    if (!needle) return;

    let attempt = 0;

    const tick = () => {
        attempt++;

        const root = _GetChatRoot();
        if (!root) {
            if (attempt < CHAT_PATCH_RETRIES) $.Schedule(CHAT_PATCH_INTERVAL, tick);
            return;
        }

        const lines = _GetChatLines(root);
        if (!lines || lines.length === 0) {
            if (attempt < CHAT_PATCH_RETRIES) $.Schedule(CHAT_PATCH_INTERVAL, tick);
            return;
        }

        let start = Math.max(0, lines.length - CHAT_MAX_LINES_SCAN);
        let patchedAny = false;

        for (let i = lines.length - 1; i >= start; i--) {
            const line = lines[i];
            if (!line || !line.IsValid()) continue;

            const lineText = _LineText(line);
            if (!lineText) continue;

            if (lineText.indexOf(needle) === -1) continue;

            const stamp = `${playerID}|${iconPath}|${needle}`;
            if (line._ovk_icon_stamp === stamp) {
                patchedAny = true;
                continue;
            }

            const imgs = [];
            _FindInlineImagesRecursive(line, imgs);
            if (!imgs.length) continue;

            for (const img of imgs) {
                img.SetImage(iconPath);
            }

            line._ovk_icon_stamp = stamp;
            patchedAny = true;
        }

        if (attempt < CHAT_PATCH_RETRIES) {
            $.Schedule(CHAT_PATCH_INTERVAL, tick);
        }
    };

    $.Schedule(0.0, tick);
}


let rune = 0;
const AlertBehavior_Skip = Symbol("AlertBehavior_Skip");
const ExplicitBehaviors = {
	["modifier_oracle_prognosticate"]: AlertBehavior_Skip,
	["modifier_bounty_hunter_track"]: AlertBehavior_Skip,
	["modifier_spirit_breaker_charge_of_darkness_target"]: AlertBehavior_Skip,
	modifier_ability_test_passive: function (data) {
		let [playerid, ent, serial, hasstacks] = [data.playerid, data.ent, data.serial, data.hasstacks]
		return [
			"#Custom_Modifier_Alert", // loc_string like "%s1 is %s2 affected by %s3"
			[
				//params
			]
		]
	}
}
GameEvents.Subscribe("cdota_buff_alert", function (data) {
	let [playerid, ent, serial, hasstacks] = [data.playerid, data.ent, data.serial, data.hasstacks];
	if (Players.GetTeam(playerid) != Players.GetTeam(Players.GetLocalPlayer())) return;
	let name = Buffs.GetName(ent, serial);
	if (name === "") return;
	let behavior = ExplicitBehaviors[name];
	if (behavior) {
		let [loc_string, values] = behavior(data)
        const msg = LocalizeFormat(loc_string, ...values);
        $.DispatchEvent("DOTAChatMessagePrintf", msg, playerid, 0);

        const heroEnt = Players.GetPlayerHeroEntityIndex(playerid);
        const heroName = (heroEnt !== -1) ? Entities.GetUnitName(heroEnt) : "";
        if (heroName !== "") {
            PatchHeroIconInChatPrintf(playerid, heroName, msg);
        }

	} else {
		let playerowner = Entities.GetPlayerOwnerID(ent);
		let iscontrol = Entities.GetPlayerOwnerID(ent) == playerid;
		let isdebuff = Buffs.IsDebuff(ent, serial);
		let remaining_time = Buffs.GetRemainingTime(ent, serial);
		let hasduration = Buffs.GetDuration(ent, serial) > 0 && remaining_time > 0;
		let stackcount = Buffs.GetStackCount(ent, serial);
		let ishero = Entities.IsHero(ent);
		let isenemy = Entities.IsEnemy(ent);
		let loc_string = iscontrol ? "#DOTA_Modifier_Alert" :
			ishero ?
				isenemy ? "#DOTA_Modifier_Alert_Enemy_Hero" : "#DOTA_Modifier_Alert_Ally_Hero" :
				isenemy ? "#DOTA_Modifier_Alert_Enemy_Unit" : "#DOTA_Modifier_Alert_Ally_Unit";
		let [s1, s2, s3, s4, s5, s6] = [];
		s1 = isdebuff ? "#ff0000" : "#00ff00"
		s2 = hasstacks || stackcount > 1 ? `${stackcount} ` : "";
		s3 = $.Localize("#DOTA_Tooltip_" + name);
		switch (loc_string) {
			case "#DOTA_Modifier_Alert":
				s4 = hasduration ? LocalizeFormat("#DOTA_Modifier_Alert_Time_Remaining", remaining_time.toFixed(1)) : "";
                const msg = LocalizeFormat(loc_string, s1, s2, s3, s4);
                $.DispatchEvent("DOTAChatMessagePrintf", msg, playerid, 0);

                const heroEnt = Players.GetPlayerHeroEntityIndex(playerid);
                const heroName = (heroEnt !== -1) ? Entities.GetUnitName(heroEnt) : "";
                if (heroName !== "") {
                    PatchHeroIconInChatPrintf(playerid, heroName, msg);
                }
				break;
			default:
				s4 = GetPlayerColorHex(playerowner);
				s5 = $.Localize(`#${Entities.GetUnitName(ent)}`);
				s6 = hasduration ? LocalizeFormat("#DOTA_Modifier_Alert_Time_Remaining", remaining_time.toFixed(1)) : "";
                const msg2 = LocalizeFormat(loc_string, s1, s2, s3, s4, s5, s6);
                $.DispatchEvent("DOTAChatMessagePrintf", msg2, playerid, 0);

                const heroEnt2 = Players.GetPlayerHeroEntityIndex(playerid);
                const heroName2 = (heroEnt2 !== -1) ? Entities.GetUnitName(heroEnt2) : "";
                if (heroName2 !== "") {
                    PatchHeroIconInChatPrintf(playerid, heroName2, msg2);
                }
		}
	}
})

let ping_stacks = 2;
let ping_cooldown = 5;
$.RegisterForUnhandledEvent("DOTAShowBuffTooltip", function (buffpanel, ent, serial) {
	let button = buffpanel.GetChild(0);
	let name = Buffs.GetName(ent, serial);
	if (button) {
		button.SetPanelEvent("onactivate", function () {
			if (ExplicitBehaviors[name] == AlertBehavior_Skip) {
				Players.BuffClicked(ent, serial, IsDotaAltPressed());
			} else if (IsDotaAltPressed()) {
				if (ping_stacks <= 0) {
					return;
				};
				ping_stacks--;
				$.Schedule(ping_cooldown, () => {
					ping_stacks++;
				});
				GameEvents.SendCustomGameEventToAllClients("cdota_buff_alert", {
					playerid: Players.GetLocalPlayer(),
					ent: ent,
					serial: serial,
					hasstacks: buffpanel.BHasClass("has_stacks"),
				});
			}
		});
	}
})

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

    // let HighFivePanel = SecondaryAbilities.FindChildTraverse("HighFive");
    // if(HighFivePanel){
    //     HighFivePanel.SetPanelEvent("onactivate", function(){
    //         CastHighFive()
    //     })
    // }
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
        let Seasonal1 = Entities.GetAbilityByName( Unit, "seasonal_ti11_duel" )
        if(Seasonal1 && Seasonal1 != -1){
            let SeasonalPanel = SecondaryAbilities.FindChildTraverse("Seasonal1");
            if(SeasonalPanel){
                HideOnThisUnit = false
                let CDRemaining = Abilities.GetCooldownTimeRemaining(Seasonal1)
                SeasonalPanel.SetHasClass("Cooldown", CDRemaining > 0);
                SeasonalPanel.SetDialogVariable("cd", CDRemaining <= 5 ? CDRemaining.toFixed(1) : CDRemaining.toFixed(0));
            }
        }
        let Seasonal2 = Entities.GetAbilityByName( Unit, "seasonal_ti11_balloon" )
        if(Seasonal2 && Seasonal2 != -1){
            let SeasonalPanel = SecondaryAbilities.FindChildTraverse("Seasonal2");
            if(SeasonalPanel){
                HideOnThisUnit = false
                let CDRemaining = Abilities.GetCooldownTimeRemaining(Seasonal2)
                SeasonalPanel.SetHasClass("Cooldown", CDRemaining > 0);
                SeasonalPanel.SetDialogVariable("cd", CDRemaining <= 5 ? CDRemaining.toFixed(1) : CDRemaining.toFixed(0));
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

GameEvents.Subscribe("overvodka_player_chat", (data) => {
    const pid = data.playerid | 0;
    const heroName = data.hero || "";
    const msgText = (data.text || "").toString();

    const customIconPath = "file://{images}/heroes/" + GetOvervodkaHeroName(heroName) + ".png";

    PatchChatLineForMessage(pid, msgText, customIconPath);
});

function PatchChatLineForMessage(playerID, msgText, iconPath) {
    const startTime = Game.GetGameTime();
    const maxTime = 0.8;
    const interval = 0.0;

    function attempt() {
        const chatContainer = DotaHUDPanel.FindChildTraverse("ChatLinesContainer");
        if (!chatContainer) {
            if (Game.GetGameTime() - startTime < maxTime) $.Schedule(interval, attempt);
            return;
        }

        const lines = chatContainer.FindChildrenWithClassTraverse("ChatLine");
        if (!lines || lines.length === 0) {
            if (Game.GetGameTime() - startTime < maxTime) $.Schedule(interval, attempt);
            return;
        }

        const from = Math.max(0, lines.length - 10);
        for (let i = lines.length - 1; i >= from; i--) {
            const line = lines[i];
            if (!line) continue;

            if (msgText && !ChatLineContainsText(line, msgText)) continue;

            const img = GetFirstInlineImageRecursive(line);
            if (img) {
                img.SetImage(iconPath);

                $.Schedule(0.15, () => { if (img && img.IsValid()) img.SetImage(iconPath); });
                $.Schedule(0.30, () => { if (img && img.IsValid()) img.SetImage(iconPath); });

                return;
            }
        }

        if (Game.GetGameTime() - startTime < maxTime) {
            $.Schedule(interval, attempt);
        }
    }

    attempt();
}

function ChatLineContainsText(root, text) {
    const labels = [];
    CollectPanelsByTypeRecursive(root, "Label", labels);
    for (const l of labels) {
        if (l && typeof l.text === "string" && l.text.indexOf(text) !== -1) {
            return true;
        }
    }
    return false;
}

function GetFirstInlineImageRecursive(root) {
    const images = [];
    CollectInlineImagesRecursive(root, images);
    return images.length > 0 ? images[0] : null;
}

function CollectInlineImagesRecursive(panel, out) {
    if (!panel) return;

    if (panel.paneltype === "Image" && panel.id && panel.id.startsWith("InlineImage")) {
        out.push(panel);
    }

    const cnt = panel.GetChildCount ? panel.GetChildCount() : 0;
    for (let i = 0; i < cnt; i++) {
        CollectInlineImagesRecursive(panel.GetChild(i), out);
    }
}

function CollectPanelsByTypeRecursive(panel, typeName, out) {
    if (!panel) return;

    if (panel.paneltype === typeName) out.push(panel);

    const cnt = panel.GetChildCount ? panel.GetChildCount() : 0;
    for (let i = 0; i < cnt; i++) {
        CollectPanelsByTypeRecursive(panel.GetChild(i), typeName, out);
    }
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

function CastSeasonal1(){
    let Unit = Players.GetLocalPlayerPortraitUnit()
    if(Unit && Unit != -1 && CheckCastableOnUnit(Unit)){
        let HighFive = Entities.GetAbilityByName( Unit, "seasonal_ti11_duel" )
        if(HighFive && HighFive != -1){
            Abilities.ExecuteAbility(HighFive, Unit, false);
        }
    }
}
function CastSeasonal2(){
    let Unit = Players.GetLocalPlayerPortraitUnit()
    if(Unit && Unit != -1 && CheckCastableOnUnit(Unit)){
        let HighFive = Entities.GetAbilityByName( Unit, "seasonal_ti11_balloon" )
        if(HighFive && HighFive != -1){
            Abilities.ExecuteAbility(HighFive, Unit, false);
        }
    }
}

function SetUpKeyBind() {
    for (const KeysInfo of SlotsKeys) {
        let oldKey = KeysInfo.Current;
        let DotaKey = Game.GetKeybindForCommand(KeysInfo.Dota);
        if (KeysInfo.Current == "") {
            KeysInfo.Current = KeysInfo.Default;
        }
        if (DotaKey != "") {
            KeysInfo.Current = DotaKey;
        }
        if (oldKey != KeysInfo.Current) {
            let PanelForBind = SecondaryAbilities.FindChildTraverse(KeysInfo.Slot);
            if (PanelForBind) {
                PanelForBind.SetDialogVariable("BindKey", KeysInfo.Current+"")
            }
            const cmd_name = "CastDFGMText" + Math.floor(Math.random() * 99999999);
            Game.CreateCustomKeyBind(KeysInfo.Current, cmd_name);
            Game.AddCommand(cmd_name, () => KeysInfo.Func(), "", 0);
        }
    }
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
        msgPanel.hittestchildren = false

        let HeroImage = msgPanel.FindChildTraverse("HeroImage")

        HeroImage.SetImage( "file://{images}/heroes/" + OvervodkaName + ".png" );

        msgPanel.SetDialogVariable("text", Text)
        $.Schedule(5, function(){
            msgPanel.AddClass("ExpireThisAfter")
        })
    }
}

let Offset = 125
let UISCALE_X = 1;
let UISCALE_Y = 1;
let DamageOffset = 170; 
let DamageHalfWidth = 100;

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

        if(!IsTitleActive(Unit)){
            DeletePlayerTitle(Unit)
            continue
        }

        const panel = GetOrCreatePlayerTitlePanel(Unit)

        panel.checked = true
    }

    for (let i = Container.GetChildCount() - 1; i >= 0; i--) {
        const panel = Container.GetChild(i);
        if (!panel) continue;

        const Unit = panel.title_unit;

        if (Unit === undefined || Unit === null || !Entities.IsValidEntity(Unit)) {
            continue;
        }

        let bIsDead = !Entities.IsAlive(Unit);

        let bIsActivePlayerHero = false;
        let PlayerID = Entities.GetPlayerOwnerID(Unit);
        const Hero = Players.GetPlayerHeroEntityIndex(PlayerID);

        if (Hero != -1 && Hero == Unit) {
            bIsActivePlayerHero = true;
        }
        if (!panel.checked && !bIsActivePlayerHero) {
            DeletePlayerTitle(Unit);
            continue;
        }

        panel.SetHasClass("TitleHiddenByHero", bIsDead || !panel.checked);

        panel.checked = false;

        if (!bIsDead) {
            let HeroOrigin = Entities.GetAbsOrigin(Unit);
            let ScreenX = Game.WorldToScreenX(HeroOrigin[0], HeroOrigin[1], HeroOrigin[2] + 250);
            let ScreenY = Game.WorldToScreenY(HeroOrigin[0], HeroOrigin[1], HeroOrigin[2] + 250);
            let bIsOutScreen = GameUI.GetScreenWorldPosition(ScreenX, ScreenY) == null;
            panel.SetHasClass("TitleHidden", bIsOutScreen);
            if (!bIsOutScreen) {
                let x = (ScreenX - (100 * UISCALE_Y)) / UISCALE_X;
                let y = (ScreenY - (Offset * UISCALE_Y)) / UISCALE_Y;
                panel.style.position = Math.floor(x) + "px " + Math.floor(y) + "px 0";
            }
        }
    }

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

function IsTitleActive(unit){
    if(!IsAdminEnt(unit)){return false}

    let PlayerID = Entities.GetPlayerOwnerID( unit )

    let PlayerInfo = CustomNetTables.GetTableValue("players", `player_${PlayerID}_title_status`)
    if(PlayerInfo && PlayerInfo.status == 1){
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

function OnDoubleRating(){
    if(!IsPlayerDoubled()){
        GameEvents.SendCustomGameEventToServer( "player_doubled_rating", {} )
        Game.EmitSound( "UUI_SOUNDS.DoubledRating" )
    }
}

function IsPlayerDoubled(){
    let PlayerInfo = CustomNetTables.GetTableValue("players", `player_${LocalPlayer}_double_rating`)
    if(PlayerInfo && PlayerInfo.doubled == 1){
        return true
    }

    return false
}

function UpdatePlayerHUD(v){
    let bSubscribed = v.active == 1
    let bHasDoubleRating = v.double_rating != undefined && v.double_rating.count != undefined && v.double_rating.count > 0

    let bPlayerDoubled = IsPlayerDoubled()

    let bTime = (Math.max(Math.floor(DoubleRatingLastTime - Game.GetGameTime()), 0)) > 0

    let bDoubleRatingShow = bTime && bSubscribed && bHasDoubleRating && !bPlayerDoubled

    DoubleRating.SetHasClass("Show", bDoubleRatingShow)
    if(bDoubleRatingShow){
        DoubleRating.SetDialogVariable("count", v.double_rating.count)
    }
}

function DoubleRatingTimer(){
    let Diff = Math.max(Math.floor(DoubleRatingLastTime - Game.GetGameTime()), 0)

    DoubleRating.SetDialogVariable("close_timer", Diff)

    DoubleRating.SetHasClass("Alarm", Diff <= 5)

    if(Diff > 0){
        $.Schedule(1, DoubleRatingTimer)
    }else{
        let PlayerInfo = CustomNetTables.GetTableValue("players", `player_${LocalPlayer}`)
        if(PlayerInfo){
            UpdatePlayerHUD(PlayerInfo)
        }
    }
}

function OnTeamLeaved(event){
    TeamLeavedSequence += 1
    let CurrentSequence = TeamLeavedSequence

    let color = GameUI.CustomUIConfig().team_colors[event.team]
    let icon = GameUI.CustomUIConfig().team_icons[event.team]
    let TeamDetails = Game.GetTeamDetails( event.team )
    if(!TeamLeavedEncounter || !TeamDetails || !color || !icon){
        return
    }

    Game.EmitSound("UUI_SOUNDS.TeamLeaved")

    TeamLeavedEncounter.AddClass("Show")

    let TeamName = $.Localize( TeamDetails.team_name )

    let ReducedTime = Math.floor(event.time_reduce/60)

    let CurrentBonusGold = event.bonus_gold * event.missing_teams
    let CurrentBonusXp = event.bonus_xp * event.missing_teams

    let TimeDescription = $.Localize("#PLAYER_HUD_TeamLeavedDescription1")
    let TimeReducedText = $.Localize("#PLAYER_HUD_TeamLeavedNoTimeReduced")
    if(ReducedTime > 0){
        let MinuteText = GetMinuteText(ReducedTime)
        TimeReducedText = `${ReducedTime} ${MinuteText}`
    }else{
        TimeDescription = ""
    }

    TeamLeavedEncounter.SetDialogVariable("LeavedTeamName", TeamName)
    TeamLeavedEncounter.SetDialogVariable("TimeReduced", TimeReducedText)
    TeamLeavedEncounter.SetDialogVariableInt("XpIncrease", event.bonus_xp)
    TeamLeavedEncounter.SetDialogVariableInt("GoldIncrease", event.bonus_gold)
    TeamLeavedEncounter.SetDialogVariableInt("GoldIncreaseCurrent", CurrentBonusGold)
    TeamLeavedEncounter.SetDialogVariableInt("XpIncreaseCurrent", CurrentBonusXp)

    let TimeDescriptionPanel = TeamLeavedEncounter.FindChildTraverse("TeamLeavedTimeDescription")
    if(TimeDescriptionPanel){
        TimeDescriptionPanel.text = TimeDescription
    }

    let NamePanel = TeamLeavedEncounter.FindChildTraverse("TeamLeavedName")
    if(NamePanel){
        NamePanel.style.color = color
    }

    let IconPanel = TeamLeavedEncounter.FindChildTraverse("TeamLeavedIcon")
    if(IconPanel){
        IconPanel.SetImage(icon)
    }

    let IconPanel2 = TeamLeavedEncounter.FindChildTraverse("TeamLeavedShieldIcon")
    if(IconPanel2){
        IconPanel2.style.washColor = color
    }

    let Duration = Number(event.duration) || 5
    $.Schedule(Duration, function(){
        if(CurrentSequence == TeamLeavedSequence){
            TeamLeavedEncounter.RemoveClass("Show")
        }
    })
}

function OnSilvernameFacet2TargetStart(event) {
    SilvernameFacet2Target = event.entindex;
}

function OnSilvernameFacet2TargetEnd(event) {
    if (SilvernameFacet2Target === event.entindex) {
        SilvernameFacet2Target = -1;
    }
    DeleteDamageTitlePanel(event.entindex);
}

function UpdateSilvernameFacet2Damage() {
    if (SilvernameFacet2Target !== -1 && Entities.IsValidEntity(SilvernameFacet2Target)) {
        const ent = SilvernameFacet2Target;

        const buff = HasModifierOnUnit(ent, "modifier_silvername_w_facet_2_target");
        if (!buff) {
            DeleteDamageTitlePanel(ent);
        } else {
            const panel = GetOrCreateDamageTitlePanel(ent);
            const label = panel.FindChildTraverse("DamageText");

            const dmg = Buffs.GetStackCount(ent, buff) | 0;
            if (label) {
                label.text = dmg > 0 ? (dmg) : "0";
            }

            panel.SetHasClass("TitleHidden", dmg <= 0);

            const origin = Entities.GetAbsOrigin(ent);
            const worldX = origin[0];
            const worldY = origin[1];
            const worldZ = origin[2] + 100; // высота над моделью

            const screenX = Game.WorldToScreenX(worldX, worldY, worldZ);
            const screenY = Game.WorldToScreenY(worldX, worldY, worldZ);

            if (screenX === -1 || screenY === -1) {
                panel.visible = false;
            } else {
                panel.visible = true;

                const x = (screenX - (DamageHalfWidth * UISCALE_Y)) / UISCALE_X;
                const y = (screenY - (DamageOffset   * UISCALE_Y)) / UISCALE_Y;

                panel.style.position = Math.floor(x) + "px " + Math.floor(y) + "px 0px";
            }
        }
    } else {
    }

    $.Schedule(0.03, UpdateSilvernameFacet2Damage);
}


function GetOrCreateDamageTitlePanel(entIndex) {
    const id = `silvername_w_facet_2_${entIndex}`;
    let panel = Container.FindChildTraverse(id);
    if (panel) return panel;

    panel = $.CreatePanel("Panel", Container, id);
    panel.unit_index = entIndex;
    panel.BLoadLayout("file://{resources}/layout/custom_game/silvername_w_facet_2_damage.xml", false, false);
    return panel;
}

function DeleteDamageTitlePanel(entIndex) {
    const id = `silvername_w_facet_2_${entIndex}`;
    const panel = Container.FindChildTraverse(id);
    if (panel) {
        panel.DeleteAsync(0);
    }
}

function OnMisoloQMarkerStart(event) {
    if (!event || event.entindex == null) return;
    MisoloQMarkers[event.entindex] = true;
}

function OnMisoloQMarkerEnd(event) {
    if (!event || event.entindex == null) return;
    delete MisoloQMarkers[event.entindex];
    DeleteMisoloQMarkerPanel(event.entindex);
}

function GetOrCreateMisoloQMarkerPanel(entIndex) {
    const id = `misolo_q_marker_${entIndex}`;
    let panel = Container.FindChildTraverse(id);
    if (panel) return panel;

    panel = $.CreatePanel("Panel", Container, id);
    panel.hittest = false;
    panel.hittestchildren = false;
    panel.BLoadLayout("file://{resources}/layout/custom_game/heroes/misolo/misolo_q_marker.xml", false, false);
    return panel;
}

function DeleteMisoloQMarkerPanel(entIndex) {
    const id = `misolo_q_marker_${entIndex}`;
    const panel = Container.FindChildTraverse(id);
    if (panel) panel.DeleteAsync(0);
}

const MISOLO_Q_MARKER_Z_OFFSET = 235;
const MISOLO_Q_MARKER_HALF_WIDTH = 150;
const MISOLO_Q_MARKER_OFFSET = 150;

function UpdateMisoloQMarkers() {
    UISCALE_X = DotaHUDPanel.actualuiscale_x;
    UISCALE_Y = DotaHUDPanel.actualuiscale_y;

    for (const entStr in MisoloQMarkers) {
        const ent = parseInt(entStr);

        if (!Entities.IsValidEntity(ent) || !Entities.IsAlive(ent)) {
            DeleteMisoloQMarkerPanel(ent);
            delete MisoloQMarkers[entStr];
            continue;
        }

        const has = HasModifierOnUnit(ent, "modifier_misolo_q_debuff");
        if (!has) {
            DeleteMisoloQMarkerPanel(ent);
            delete MisoloQMarkers[entStr];
            continue;
        }

        const panel = GetOrCreateMisoloQMarkerPanel(ent);
        const origin = Entities.GetAbsOrigin(ent);
        const sx = Game.WorldToScreenX(origin[0], origin[1], origin[2] + MISOLO_Q_MARKER_Z_OFFSET);
        const sy = Game.WorldToScreenY(origin[0], origin[1], origin[2] + MISOLO_Q_MARKER_Z_OFFSET);
        const bIsOutScreen = (GameUI.GetScreenWorldPosition(sx, sy) == null);

        if (sx === -1 || sy === -1 || bIsOutScreen) {
            panel.visible = false;
            continue;
        }

        panel.visible = true;

        const x = (sx - (MISOLO_Q_MARKER_HALF_WIDTH * UISCALE_Y)) / UISCALE_X;
        const y = (sy - (MISOLO_Q_MARKER_OFFSET * UISCALE_Y)) / UISCALE_Y;

        panel.style.position = Math.floor(x) + "px " + Math.floor(y) + "px 0";
    }

    $.Schedule(0, UpdateMisoloQMarkers);
}

function OnEpsteinWSquareStart(event) {
    if (!event || event.entindex == null) return;
    EpsteinWSquares[event.entindex] = true;
}

function OnEpsteinWSquareEnd(event) {
    if (!event || event.entindex == null) return;
    delete EpsteinWSquares[event.entindex];
    DeleteEpsteinWSquarePanel(event.entindex);
}

function GetOrCreateEpsteinWSquarePanel(entIndex) {
    const id = `epstein_w_square_${entIndex}`;
    let panel = Container.FindChildTraverse(id);
    if (panel) return panel;

    panel = $.CreatePanel("Panel", Container, id);
    panel.hittest = false;
    panel.hittestchildren = false;
    panel.BLoadLayout("file://{resources}/layout/custom_game/heroes/epstein/epstein_w_square.xml", false, false);
    return panel;
}

function DeleteEpsteinWSquarePanel(entIndex) {
    const id = `epstein_w_square_${entIndex}`;
    const panel = Container.FindChildTraverse(id);
    if (panel) panel.DeleteAsync(0);
}

const SQUARE_SIZE = 180;
const Z_OFFSET    = 110;

function UpdateEpsteinWSquares() {
    UISCALE_X = DotaHUDPanel.actualuiscale_x;
    UISCALE_Y = DotaHUDPanel.actualuiscale_y;

    for (const entStr in EpsteinWSquares) {
        const ent = parseInt(entStr);

        if (!Entities.IsValidEntity(ent)) {
            DeleteEpsteinWSquarePanel(ent);
            delete EpsteinWSquares[entStr];
            continue;
        }

        const has = HasModifierOnUnit(ent, "modifier_epstein_w_debuff");
        if (!has) {
            DeleteEpsteinWSquarePanel(ent);
            delete EpsteinWSquares[entStr];
            continue;
        }

        const panel = GetOrCreateEpsteinWSquarePanel(ent);

        const origin = Entities.GetAbsOrigin(ent);
        const sx = Game.WorldToScreenX(origin[0], origin[1], origin[2] + Z_OFFSET);
        const sy = Game.WorldToScreenY(origin[0], origin[1], origin[2] + Z_OFFSET);

        const bIsOutScreen = (GameUI.GetScreenWorldPosition(sx, sy) == null);
        if (sx === -1 || sy === -1 || bIsOutScreen) {
            panel.visible = false;
            continue;
        }

        panel.visible = true;

        const half = (SQUARE_SIZE * 0.5);

        const x = (sx - (half * UISCALE_Y)) / UISCALE_X;
        const y = (sy - (half * UISCALE_Y)) / UISCALE_Y;

        panel.style.position = Math.floor(x) + "px " + Math.floor(y) + "px 0";
    }

    $.Schedule(0, UpdateEpsteinWSquares);
}

function HideChaosSelection() {
    ChaosSelectionCards = {};
    ChaosSelectionEndTime = -1;
    ChaosSelectionSeq = -1;
    ChaosSelectionTimerSeq += 1;
    ChaosSelectionRoot.RemoveClass("Visible");
    ChaosSelectionTimerFill.style.width = "0%";
    ChaosSelectionTimerText.text = $.Localize("#CHAOS_SELECTION_TIMER_DEFAULT");

    for (let index = 1; index <= 3; index++) {
        const cardPanel = ChaosCardPanels[index];
        if (cardPanel) {
            cardPanel.visible = false;
        }
    }
}

function UpdateChaosSelectionTimer(timerSeq) {
    if (timerSeq !== ChaosSelectionTimerSeq) {
        return;
    }

    if (ChaosSelectionEndTime <= 0) {
        ChaosSelectionTimerFill.style.width = "0%";
        ChaosSelectionTimerText.text = $.Localize("#CHAOS_SELECTION_TIMER_DEFAULT");
        return;
    }

    const remaining = Math.max(ChaosSelectionEndTime - Game.GetGameTime(), 0);
    const seconds = Math.max(Math.ceil(remaining), 0);
    const progress = Math.max(Math.min(remaining / 10, 1), 0);

    ChaosSelectionTimerText.text = LocalizeFormat("#CHAOS_SELECTION_TIMER", seconds);
    ChaosSelectionTimerFill.style.width = `${(progress * 100).toFixed(2)}%`;

    if (remaining > 0 && ChaosSelectionEndTime > 0) {
        $.Schedule(0.016, () => UpdateChaosSelectionTimer(timerSeq));
    }
}

function OnChaosSelectionUpdate(value) {
    if (!value || value.active !== 1) {
        HideChaosSelection();
        return;
    }

    ChaosSelectionCards = {};
    ChaosSelectionEndTime = value.end_time || -1;

    for (let index = 1; index <= 3; index++) {
        const cardData = value[`card_${index}`];
        const cardPanel = ChaosCardPanels[index];
        const title = ChaosCardTitles[index];
        const description = ChaosCardDescriptions[index];

        if (!cardPanel || !title || !description) {
            continue;
        }

        if (cardData) {
            ChaosSelectionCards[index] = cardData;
            cardPanel.visible = true;
            title.text = $.Localize(cardData.title_key);
            description.text = $.Localize(cardData.desc_key);
        } else {
            cardPanel.visible = false;
            title.text = "";
            description.text = "";
        }
    }

    if (ChaosSelectionSeq !== value.seq) {
        const selectionSeq = value.seq;
        ChaosSelectionSeq = selectionSeq;
        ChaosSelectionTimerSeq += 1;
        ChaosSelectionRoot.RemoveClass("Visible");
        $.Schedule(0.0, () => {
            if (ChaosSelectionSeq === selectionSeq && ChaosSelectionEndTime > 0) {
                ChaosSelectionRoot.AddClass("Visible");
            }
        });
    } else {
        ChaosSelectionRoot.AddClass("Visible");
    }

    UpdateChaosSelectionTimer(ChaosSelectionTimerSeq);
}

function OnChaosHistoryUpdate(value) {
    const count = value && value.count ? value.count : 0;
    const newestEntry = count > 0 ? value["entry_1"] : null;
    const newestSignature = BuildChaosHistoryEntrySignature(newestEntry);
    const hasNewEntry =
        ChaosHistoryInitialized &&
        newestSignature &&
        newestSignature !== ChaosHistoryLatestSignature;

    DeleteAllChildren(ChaosHistoryEntries);

    ChaosHistoryHasEntries = count > 0;

    if (!ChaosHistoryHasEntries) {
        ChaosHistoryCollapsed = false;
        ClearChaosHistoryHighlight();
    }

    for (let index = 1; index <= count; index++) {
        const entry = value[`entry_${index}`];
        if (!entry) {
            continue;
        }

        const row = $.CreatePanel("Panel", ChaosHistoryEntries, "");
        row.AddClass("ChaosHistoryEntry");
        row._chaosHistorySignature = BuildChaosHistoryEntrySignature(entry);
        if (index === 1 && IsChaosHistoryEntryHighlighted(row._chaosHistorySignature)) {
            row.AddClass("NewChaosHistoryEntry");
        }

        const title = $.CreatePanel("Label", row, "");
        title.AddClass("ChaosHistoryEntryTitle");
        title.text = $.Localize(entry.title_key);

        const text = $.CreatePanel("Label", row, "");
        text.AddClass("ChaosHistoryEntryText");
        text.text = $.Localize(entry.summary_key);
    }

    if (hasNewEntry) {
        BeginChaosHistoryHighlight(newestSignature);
    }

    ChaosHistoryLatestSignature = newestSignature;
    ChaosHistoryInitialized = true;
    UpdateChaosHistoryState();
    RefreshChaosHistoryHighlightClasses();
}

function UpdateChaosHistoryState() {
    if (!ChaosHistoryPanel || !ChaosHistoryToggleButton) {
        return;
    }

    const showPanel = ChaosHistoryHasEntries && !ChaosHistoryCollapsed && !ChaosHistoryHiddenByShop;
    const showToggle = ChaosHistoryHasEntries && ChaosHistoryCollapsed && !ChaosHistoryHiddenByShop;

    SetAnimatedPanelVisible(ChaosHistoryPanel, showPanel);
    SetAnimatedPanelVisible(ChaosHistoryToggleButton, showToggle);
}

function IsPanelActuallyVisible(panel) {
    if (!panel) {
        return false;
    }

    return panel.visible !== false &&
        panel.style.visibility !== "collapse" &&
        panel.actuallayoutwidth > 0 &&
        panel.actuallayoutheight > 0;
}

function IsDotaShopOpen() {
    if (GameUI && typeof GameUI.IsShopOpen === "function") {
        return GameUI.IsShopOpen();
    }

    if (Game && typeof Game.IsShopOpen === "function") {
        return Game.IsShopOpen();
    }

    if (!DotaHUDPanel) {
        return false;
    }

    const possibleShopPanels = [
        DotaHUDPanel.FindChildTraverse("shop"),
        DotaHUDPanel.FindChildTraverse("ShopMain"),
        DotaHUDPanel.FindChildTraverse("HudShop"),
    ];

    for (let index = 0; index < possibleShopPanels.length; index++) {
        if (IsPanelActuallyVisible(possibleShopPanels[index])) {
            return true;
        }
    }

    return false;
}

function UpdateChaosHistoryShopState() {
    const shouldHide = IsDotaShopOpen();
    if (ChaosHistoryHiddenByShop !== shouldHide) {
        ChaosHistoryHiddenByShop = shouldHide;
        UpdateChaosHistoryState();
    }

    $.Schedule(0.1, UpdateChaosHistoryShopState);
}

function SetAnimatedPanelVisible(panel, shouldShow) {
    if (!panel) {
        return;
    }

    const nextSeq = (panel._chaosVisSeq || 0) + 1;
    panel._chaosVisSeq = nextSeq;

    if (shouldShow) {
        panel.style.visibility = "visible";
        $.Schedule(0.0, () => {
            if (panel._chaosVisSeq !== nextSeq) {
                return;
            }

            panel.AddClass("Visible");
        });
        return;
    }

    panel.RemoveClass("Visible");
    $.Schedule(CHAOS_HISTORY_ANIM_DURATION, () => {
        if (panel._chaosVisSeq !== nextSeq || panel.BHasClass("Visible")) {
            return;
        }

        panel.style.visibility = "collapse";
    });
}

function BuildChaosHistoryEntrySignature(entry) {
    if (!entry) {
        return null;
    }

    return `${entry.effect_id || ""}|${entry.player_id || ""}|${entry.time || ""}`;
}

function IsChaosHistoryEntryHighlighted(signature) {
    return !!signature &&
        signature === ChaosHistoryHighlightSignature &&
        ChaosHistoryHighlightUntil > Game.GetGameTime();
}

function RefreshChaosHistoryHighlightClasses() {
    if (!ChaosHistoryEntries) {
        return;
    }

    for (let index = 0; index < ChaosHistoryEntries.GetChildCount(); index++) {
        const row = ChaosHistoryEntries.GetChild(index);
        if (!row) {
            continue;
        }

        row.SetHasClass("NewChaosHistoryEntry", IsChaosHistoryEntryHighlighted(row._chaosHistorySignature));
    }
}

function ClearChaosHistoryHighlight() {
    ChaosHistoryHighlightSignature = null;
    ChaosHistoryHighlightUntil = 0;
    ChaosHistoryHighlightSeq += 1;
}

function BeginChaosHistoryHighlight(signature) {
    if (!signature) {
        return;
    }

    ChaosHistoryCollapsed = false;
    ChaosHistoryHighlightSignature = signature;
    ChaosHistoryHighlightUntil = Game.GetGameTime() + CHAOS_HISTORY_HIGHLIGHT_DURATION;
    ChaosHistoryHighlightSeq += 1;
    const highlightSeq = ChaosHistoryHighlightSeq;

    RefreshChaosHistoryHighlightClasses();

    $.Schedule(CHAOS_HISTORY_HIGHLIGHT_DURATION, () => {
        if (ChaosHistoryHighlightSeq !== highlightSeq) {
            return;
        }

        ClearChaosHistoryHighlight();
        RefreshChaosHistoryHighlightClasses();
    });
}

function OpenChaosHistory() {
    if (!ChaosHistoryHasEntries || !ChaosHistoryCollapsed) {
        return;
    }

    ChaosHistoryCollapsed = false;
    Game.EmitSound("UUI_SOUNDS.QuestsOpen");
    UpdateChaosHistoryState();
}

function CloseChaosHistory() {
    if (!ChaosHistoryHasEntries || ChaosHistoryCollapsed) {
        return;
    }

    ChaosHistoryCollapsed = true;
    Game.EmitSound("UUI_SOUNDS.QuestsClose");
    UpdateChaosHistoryState();
}

function OnChaosCardActivated(slot) {
    const cardData = ChaosSelectionCards[slot];
    if (!cardData) {
        return;
    }

    GameEvents.SendCustomGameEventToServer("chaos_pick_card", {
        effect_id: cardData.id,
    });
}

(function(){
    StartSecondaryAbilities();
    HideChaosSelection();
    UpdateChaosHistoryShopState();

    DeleteAllChildren(TipsContainer)
    GameEvents.Subscribe("player_tipped", PlayerTipped)

    GameEvents.Subscribe("on_team_leaved", OnTeamLeaved)

    GameEvents.Subscribe("silvername_w_facet_2_target_start", OnSilvernameFacet2TargetStart);
    GameEvents.Subscribe("silvername_w_facet_2_target_end", OnSilvernameFacet2TargetEnd);
    UpdateSilvernameFacet2Damage();
    UpdateInnateIconOffset();

    GameEvents.Subscribe("misolo_q_marker_start", OnMisoloQMarkerStart);
    GameEvents.Subscribe("misolo_q_marker_end", OnMisoloQMarkerEnd);
    UpdateMisoloQMarkers();

    GameEvents.Subscribe("epstein_w_square_start", OnEpsteinWSquareStart);
    GameEvents.Subscribe("epstein_w_square_end", OnEpsteinWSquareEnd);
    UpdateEpsteinWSquares();

    SubscribeAndFireNetTableByKey("players", `player_${LocalPlayer}_double_rating_time`, function(v){
        DoubleRatingLastTime = v.time
        DoubleRatingTimer()

        let PlayerInfo = CustomNetTables.GetTableValue("players", `player_${LocalPlayer}`)
        if(PlayerInfo){
            UpdatePlayerHUD(PlayerInfo)
        }
    })

    SubscribeAndFireNetTableByKey("players", `player_${LocalPlayer}`, function(v){
        UpdatePlayerHUD(v)
    })

    SubscribeAndFireNetTableByKey("players", `player_${LocalPlayer}_double_rating`, function(v){
        let PlayerInfo = CustomNetTables.GetTableValue("players", `player_${LocalPlayer}`)
        if(PlayerInfo){
            UpdatePlayerHUD(PlayerInfo)
        }
    })

    SubscribeAndFireNetTableByKey("chaos", "history", OnChaosHistoryUpdate)
    SubscribeAndFireNetTableByKey("chaos", `selection_${LocalPlayer}`, OnChaosSelectionUpdate)
})();
