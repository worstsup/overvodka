const LocalPIDPlayer = Players.GetLocalPlayer()

const GUIDE_SHARED_ABILITY_NAME_REMAP = {
    vihor_r: "vihor_ultimate",
    frisk_r: "frisk_ultimate",
    bikov_r: "bikov_ultimate",
    amor_r: "amor_ultimate",
    epstein_q: "epstein_r", acer: "sahur_ultimate", redak: "sahur_e", abuse: "sahur_w", koleso: "sahur_q",
    materka: "dvoreckov_q", alko: "dvoreckov_w", wakas: "dvoreckov_e",
    adod: "kachok_pure_protein", tasty: "kachok_big_tasty", nosex: "kachok_abstention", churban: "kachok_trenbolone", soska: "kachok_test",
    vovacho: "ebanko_q", fofan: "ebanko_w", parit: "ebanko_e", minis: "ebanko_r",
    fei: "eldzhey_q", novape: "eldzhey_w", qmar: "eldzhey_e", srsr: "eldzhey_r",
    shkolota: "shkolnik_peremena", zvonk: "shkolnik_e", or: "shkolnik_r", chef_q: "chef_shout",
    peashooter: "dave_peashooter", sunflower: "dave_sunflower", shield: "dave_e",
    futbik: "speed_penalty", bleval: "speed_bark", twenty: "speed_cr7", gena: "speed_shake",
    stop: "worstsup_q", nerf: "worstsup_w", bigwin: "worstsup_e", code: "rubick_spell_steal",
    pchela: "macan_q", razg: "macan_w", baidul: "macan_e", largus: "macan_r",
    shavel: "mellstroy_shavel", fruits: "mellstroy_meteors", biznes: "mellstroy_business", amamam: "mellstroy_amam",
    bledina: "litvin_bledina", cond: "litvin_conditions", subo: "litvin_subo", zhishi: "litvin_zhishi",
    zveri: "stariy_zveri", yu: "stariy_bolt", lasers: "stariy_lasers",
    dogon: "ashab_dogon", slushay: "ashab_slushay", car: "ashab_car", rocket: "Ashab_rocket",
    konchai: "arsen_konchai", testosteron: "arsen_testosteron", baza: "arsen_baza", tgk: "arsen_tg",
    semya: "nix_semya", gunnar: "gunnar_bash", stopapupa: "zolo_stopapupa",
    awp: "custom_critical_strike", granade: "cheater_granades", antiaim: "custom_passive_evasion", wallhack: "custom_vision_aura", aimlock: "cheater_rage",
    sasavot_e: "sasavot_e_new", sasavot_r: "sasavot_r_new", golovach_e: "golovach_q", golovach_q: "golovach_e",
};

const GUIDE_SHARED_ITEM_NAME_REMAP = {
    item_octarine_core: "item_octarine_vodka",
    item_heart: "item_heart_vodka",
};

function NormalizeGuideAbilityNameShared(abilityName) {
    const normalized = typeof abilityName === "string" ? abilityName : "";
    return GUIDE_SHARED_ABILITY_NAME_REMAP[normalized] || normalized;
}

function NormalizeGuideItemNameShared(itemName) {
    const normalized = typeof itemName === "string" ? itemName : "";
    return GUIDE_SHARED_ITEM_NAME_REMAP[normalized] || normalized;
}

function GetGuideAbilityDisplayNameShared(abilityName) {
    const normalized = NormalizeGuideAbilityNameShared(abilityName);
    const tokens = [
        `#DOTA_Tooltip_ability_${normalized}`,
        `#DOTA_Tooltip_Ability_${normalized}`,
    ];

    for (const token of tokens) {
        const localized = $.Localize(token);
        if (localized !== token) {
            return localized;
        }
    }

    return normalized;
}

function GetDotaHud() {
	var rootUI = $.GetContextPanel();
	while (rootUI.id != "Hud" && rootUI.GetParent() != null) {
		rootUI = rootUI.GetParent();
	}
	return rootUI;
}
function FindDotaHudElement(sId)
{
    return GetDotaHud().FindChildTraverse(sId);
}
function DeleteAllChildren(p) {
    if(p != null){
        let count = p.GetChildCount();
        if (count > 0) {
            for (let i = 0; i < count; i++) {
                let child = p.GetChild(i);
                if (child != undefined) {
                    child.DeleteAsync(0.0);
                }
            }
        }
    }
}

function DeleteAllChildrenWithDelay(p, delay) {
    $.Schedule(delay, function(){
        if(p != null){
            let count = p.GetChildCount();
            if (count > 0) {
                for (let i = 0; i < count; i++) {
                    let child = p.GetChild(i);
                    if (child != undefined) {
                        child.DeleteAsync(0);
                    }
                }
            }
        }
    })
}

function DeleteAllChildrenWithDelayAndRemoveClass(p, delay, classname) {
    if(p != null){
        let count = p.GetChildCount();
        if (count > 0) {
            for (let i = 0; i < count; i++) {
                let child = p.GetChild(i);
                if (child != undefined) {
                    child.RemoveClass(classname)
                }
            }
        }
    }
    $.Schedule(delay, function(){
        if(p != null){
            let count = p.GetChildCount();
            if (count > 0) {
                for (let i = 0; i < count; i++) {
                    let child = p.GetChild(i);
                    if (child != undefined) {
                        child.DeleteAsync(0);
                    }
                }
            }
        }
    })
}

function DeleteAllChildrenByID(p, ID) {
    if(p != null){
        let count = p.GetChildCount();
        if (count > 0) {
            for (let i = 0; i < count; i++) {
                let child = p.GetChild(i);
                if (child != undefined && child.id == ID) {
                    SafeDeleteAsync(child)
                }
            }
        }
    }
}

function SafeDeleteAsync(p){
    if(p && p.IsValid()){
        p.DeleteAsync(0)
    }
}

function SafeDeleteAsyncWithDelay(p, delay){
    $.Schedule(delay, function(){
        if(p && p.IsValid()){
            p.DeleteAsync(0)
        }
    })
}

function SubscribeAndFireNetTableByKey(tableName, keyName, callback){
	const currentValue = CustomNetTables.GetTableValue(tableName, keyName);
	if (currentValue) {
		callback(currentValue);
	}
	return CustomNetTables.SubscribeNetTableListener(tableName, (name, key, values) => {
		if (key == keyName) {
			callback(values);
		}
	});
}

function toArray(obj) {
    const result = [];
    let key = 1;
    while (obj[key] != undefined) {
        result.push(obj[key]);
        key++;
    }
    return result;
}

function GetSteamID32(PlayerID){
    let Table = CustomNetTables.GetTableValue("players", `player_${PlayerID}_steamid`)
    if(Table){
        return Table.steamid
    }

    return 0
}

function GetRankClassName(Rating){
    let Definitions = [
        {
            min: 0,
            max: 1000,
            class_name: "Bronze"
        },
        {
            min: 1000,
            max: 2000,
            class_name: "Silver"
        },
        {
            min: 2000,
            max: 3000,
            class_name: "Gold"
        },
        {
            min: 3000,
            max: 4000,
            class_name: "Platinum"
        },
        {
            min: 4000,
            max: 5000,
            class_name: "Diamond"
        },
        {
            min: 5000,
            max: 6000,
            class_name: "Mythical"
        },
        {
            min: 6000,
            max: 7000,
            class_name: "Legend"
        },
        {
            min: 7000,
            max: 8000,
            class_name: "Divine"
        },
        {
            min: 8000,
            max: 30000,
            class_name: "Hamstergod"
        },
    ]

    for (const RatingInfo of Definitions) {
        if(Rating >= RatingInfo.min){
            if(RatingInfo.max == -1){
                return RatingInfo.class_name
            }else if(Rating < RatingInfo.max){
                return RatingInfo.class_name
            }
        }
    }
    return "Bronze"
}

function GetHEXPlayerColor(PID) {
    var Color = Players.GetPlayerColor(PID).toString(16);
    return Color == null
        ? "#000000"
        : "#" +
            Color.substring(6, 8) +
            Color.substring(4, 6) +
            Color.substring(2, 4) +
            Color.substring(0, 2);
}

function GetOvervodkaHeroName(HeroName){
    let OvervodkaName = "unassigned"

    if (HeroName == "npc_dota_hero_sniper")
    {
        OvervodkaName = "npc_dota_hero_ivanov"
    }
    if (HeroName == "npc_dota_hero_bounty_hunter")
    {
        OvervodkaName = "npc_dota_hero_mellstroy"
    }
    if (HeroName == "npc_dota_hero_meepo")
    {
        OvervodkaName = "npc_dota_hero_kirill"
    }
    if (HeroName == "npc_dota_hero_lion")
    {
        OvervodkaName = "npc_dota_hero_chef"
    }
    if (HeroName == "npc_dota_hero_puck")
    {
        OvervodkaName = "npc_dota_hero_lev"
    }
    if (HeroName == "npc_dota_hero_ursa")
    {
        OvervodkaName = "npc_dota_hero_litvin"
    }
    if (HeroName == "npc_dota_hero_riki")
    {
        OvervodkaName = "npc_dota_hero_sega"
    }
    if (HeroName == "npc_dota_hero_terrorblade")
    {
        OvervodkaName = "npc_dota_hero_senya"
    }	
    if (HeroName == "npc_dota_hero_tinker")
    {
        OvervodkaName = "npc_dota_hero_ilin"
    }	
    if (HeroName == "npc_dota_hero_pudge")
    {
        OvervodkaName = "npc_dota_hero_step"
    }	
    if (HeroName == "npc_dota_hero_brewmaster")
    {
        OvervodkaName = "npc_dota_hero_golmy"
    }	
    if (HeroName == "npc_dota_hero_phoenix")
    {
        OvervodkaName = "npc_dota_hero_orlov"
    }	
    if (HeroName == "npc_dota_hero_axe")
    {
        OvervodkaName = "npc_dota_hero_dima"
    }
    if (HeroName == "npc_dota_hero_invoker")
    {
        OvervodkaName = "npc_dota_hero_zombill"
    }	
    if (HeroName == "npc_dota_hero_kunkka")
    {
        OvervodkaName = "npc_dota_hero_vova"
    }	
    if (HeroName == "npc_dota_hero_rubick")
    {
        OvervodkaName = "npc_dota_hero_mrus"
    }
    if (HeroName == "npc_dota_hero_zuus")
    {
        OvervodkaName = "npc_dota_hero_stariy"
    }
    if (HeroName == "npc_dota_hero_tidehunter")
    {
        OvervodkaName = "npc_dota_hero_tamaev"
    }
    if (HeroName == "npc_dota_hero_earthshaker")
    {
        OvervodkaName = "npc_dota_hero_arsen"
    }
    if (HeroName == "npc_dota_hero_furion")
    {
        OvervodkaName = "npc_dota_hero_nix"
    }
    if (HeroName == "npc_dota_hero_antimage")
    {
        OvervodkaName = "npc_dota_hero_pirat"
    }
    if (HeroName == "npc_dota_hero_ogre_magi")
    {
        OvervodkaName = "npc_dota_hero_zolo"
    }
    if (HeroName == "npc_dota_hero_clinkz")
    {
        OvervodkaName = "npc_dota_hero_cheater"
    }
    if (HeroName == "npc_dota_hero_ancient_apparition")
    {
        OvervodkaName = "npc_dota_hero_chill"
    }
    if (HeroName == "npc_dota_hero_bloodseeker")
    {
        OvervodkaName = "npc_dota_hero_sasavot"
    }
    if (HeroName == "npc_dota_hero_juggernaut")
    {
        OvervodkaName = "npc_dota_hero_golovach"
    }
    if (HeroName == "npc_dota_hero_skeleton_king")
    {
        OvervodkaName = "npc_dota_hero_papich"
    }
    if (HeroName == "npc_dota_hero_rattletrap")
    {
        OvervodkaName = "npc_dota_hero_vihorkov"
    }
    if (HeroName == "npc_dota_hero_storm_spirit")
    {
        OvervodkaName = "npc_dota_hero_rostik"
    }
    if (HeroName == "npc_dota_hero_necrolyte")
    {
        OvervodkaName = "npc_dota_hero_5opka"
    }
    if (HeroName == "npc_dota_hero_morphling")
    {
        if (HasArcana(HeroName))
        {
            OvervodkaName = "npc_dota_hero_underfell_sans"
        }
        else
        {
            OvervodkaName = "npc_dota_hero_sans"
        }
    }
    if (HeroName == "npc_dota_hero_faceless_void")
    {
        OvervodkaName = "npc_dota_hero_evelone"
    }
    if (HeroName == "npc_dota_hero_slark")
    {
        OvervodkaName = "npc_dota_hero_bratishkin"
    }
    if (HeroName == "npc_dota_hero_weaver")
    {
        OvervodkaName = "npc_dota_hero_azazin"
    }
    if (HeroName == "npc_dota_hero_riki")
    {
        OvervodkaName = "npc_dota_hero_stray"
    }
    if (HeroName == "npc_dota_hero_omniknight")
    {
        OvervodkaName = "npc_dota_hero_stint"
    }
    if (HeroName == "npc_dota_hero_void_spirit")
    {
        if (HasArcana(HeroName))
        {
            OvervodkaName = "npc_dota_hero_invincible_arcana"
        }
        else
        {
            OvervodkaName = "npc_dota_hero_invincible"
        }
    }
    if (HeroName == "npc_dota_hero_mars")
    {
        OvervodkaName = "npc_dota_hero_zhenya"
    }
    if (HeroName == "npc_dota_hero_phantom_lancer")
    {
        OvervodkaName = "npc_dota_hero_kolyan"
    }
    if (HeroName == "npc_dota_hero_primal_beast")
    {
        OvervodkaName = "npc_dota_hero_t2x2"
    }
    if (HeroName == "npc_dota_hero_ringmaster")
    {
        OvervodkaName = "npc_dota_hero_mazellov"
    }
    if (HeroName == "npc_dota_hero_warlock")
    {
        OvervodkaName = "npc_dota_hero_king"
    }
    if (HeroName == "npc_dota_hero_spirit_breaker")
    {
        if (HasModifier(HeroName, "modifier_overvodka_store_skin_6")) {
            OvervodkaName = "npc_dota_hero_flash_immortal"
        }
        else {
            OvervodkaName = "npc_dota_hero_flash"
        }
    }
    if (HeroName == "npc_dota_hero_winter_wyvern")
    {
        OvervodkaName = "npc_dota_hero_bikov"
    }
    if (HeroName == "npc_dota_hero_spectre")
    {
        OvervodkaName = "npc_dota_hero_chara"
    }
    if (HeroName == "npc_dota_hero_templar_assassin")
    {
        OvervodkaName = "npc_dota_hero_frisk"
    }
    if (HeroName == "npc_dota_hero_abaddon")
    {
        OvervodkaName = "npc_dota_hero_prince"
    }
    if (HeroName == "npc_dota_hero_tusk")
    {
        OvervodkaName = "npc_dota_hero_seregga"
    }
    if (HeroName == "npc_dota_hero_undying")
    {
        OvervodkaName = "npc_dota_hero_visitor"
    }
    if (HeroName == "npc_dota_hero_ember_spirit")
    {
        OvervodkaName = "npc_dota_hero_peacemaker"
    }
    if (HeroName == "npc_dota_hero_nyx_assassin")
    {
        OvervodkaName = "npc_dota_hero_kolibri"
    }
    if (HeroName == "npc_dota_hero_hoodwink")
    {
        OvervodkaName = "npc_dota_hero_leon"
    }
    if (HeroName == "npc_dota_hero_slardar")
    {
        OvervodkaName = "npc_dota_hero_pistol"
    }
    if (HeroName == "npc_dota_hero_bristleback")
    {
        OvervodkaName = "npc_dota_hero_amor"
    }
    if (HeroName == "npc_dota_hero_beastmaster")
    {
        OvervodkaName = "npc_dota_hero_epstein"
    }
    if (HeroName == "npc_dota_hero_broodmother")
    {
        OvervodkaName = "npc_dota_hero_misolo"
    }
    return OvervodkaName	
}

function EmitErrorToPlayer(errorText, errorSound){
    GameUI.SendCustomHUDError( errorText, errorSound )
}

GameEvents.Subscribe( "SEND_ERROR_TO_PLAYER", function(event){
    EmitErrorToPlayer(event.errorText, event.errorSound)
} )

function IsPlayerSubscribed(PlayerID){
    let Table = CustomNetTables.GetTableValue("players", `player_${PlayerID}`)
    if(Table && Table.active == 1){
        return true
    }

    return false
}

function HasArcana(HeroName){
    if (HeroName == "npc_dota_hero_morphling")
    {
        if (HasModifier(HeroName, "modifier_sans_arcana"))
        {
            return true
        }
    }
    if (HeroName == "npc_dota_hero_void_spirit")
    {
        if (HasModifier(HeroName, "modifier_invincible_arcana"))
        {
            return true
        }
    }
}

function HasModifierOnUnit(entIndex, modifier)
{
    if (!Entities.IsValidEntity(entIndex))
        return false;

    const numBuffs = Entities.GetNumBuffs(entIndex);
    for (let i = 0; i < numBuffs; i++)
    {
        const buff = Entities.GetBuff(entIndex, i);
        if (Buffs.GetName(entIndex, buff) === modifier)
        {
            return buff;
        }
    }
    return false;
}

function HasModifier(heroName, modifier)
 {
    const heroes = Entities.GetAllHeroEntities();
    let unit = null;
    for (let i = 0; i < heroes.length; i++) {
        if (Entities.GetUnitName(heroes[i]) === heroName) {
            unit = heroes[i];
            break;
        }
    }
    if (!unit) return false;
    for (var i = 0; i < Entities.GetNumBuffs(unit); i++) 
    {
        if (Buffs.GetName(unit, Entities.GetBuff(unit, i)) == modifier)
        {
            return Entities.GetBuff(unit, i)
        }
    }
    return false
}

function IsPlayerMuted(PlayerID){
    let Table = CustomNetTables.GetTableValue("players", `player_${LocalPIDPlayer}_mutes`)
    if(Table){
        let Array = toArray(Table)
        if(Array){
            for (const tPlayerID of Array) {
                if(tPlayerID == PlayerID){
                    return true
                }
            }
        }
    }
    return false
}

function GetPlayerRatingInfo(PlayerID){
    let Table = CustomNetTables.GetTableValue("players", `player_${PlayerID}`)
    if(Table && Table.rating != undefined){
        return [Table.rating, GetRankClassName(Table.rating)]
    }

    return [undefined, undefined]
}

function GetDateString(Date, bTime){
    if(!Date){
        return ""
    }
    let DateAndTime = Date.split(" ")
    if(!DateAndTime[0]){
        return ""
    }

    let Day = DateAndTime[0].split("-")[2]
    let Month = DateAndTime[0].split("-")[1]
    let Year = DateAndTime[0].split("-")[0]

    let Time = " "

    if(DateAndTime[1] && bTime){
        Time = " " + DateAndTime[1].split(":")[0] + ":" + DateAndTime[1].split(":")[1]
    }

    return `${Day}.${Month}.${Year}${Time}`
}

function GetUniqueSceneHeroName(hero_name)
{
    if (hero_name == "npc_dota_hero_morphling")
    {
        return "sans_arcana_loadout"
    }
    if (hero_name == "npc_dota_hero_void_spirit")
    {
        return "invincible_arcana_loadout"
    }
    return hero_name
}

function getScreamerRoot() {
    var p = $("#CharaScreamerPanel");
    if (p) return p;

    var hud = $.GetContextPanel();
    while (hud && hud.id !== "Hud") hud = hud.GetParent();
    return hud ? hud.FindChildTraverse("CharaScreamerPanel") : null;
}

function CharaScreamerTrue() {
    var root = getScreamerRoot();
    if (!root) { $.Msg("CharaScreamer panel not found"); return; }
    root.RemoveAndDeleteChildren();

    $.CreatePanel(
        "MoviePanel",
        root,
        "screamer_chara",
        {
            style: "width:100%;height:100%;align:center center;opacity:0.50;",
            class: "chara_screamer_webm",
            src: "file://{resources}/videos/chara_screamer.webm",
            repeat: "true",
            hittest: "false",
            autoplay: "onload"
        }
    );
}

function CharaScreamerFalse() {
    var root = getScreamerRoot();
    if (!root) return;
    root.RemoveAndDeleteChildren();
}

function getScreamerRoot_Visitor() {
    var p = $("#VisitorScreamerPanel");
    if (p) return p;

    var hud = $.GetContextPanel();
    while (hud && hud.id !== "Hud") hud = hud.GetParent();
    return hud ? hud.FindChildTraverse("VisitorScreamerPanel") : null;
}

function VisitorScreamerTrue() {
    var root = getScreamerRoot_Visitor();
    if (!root) { $.Msg("VisitorScreamer panel not found"); return; }
    root.RemoveAndDeleteChildren();
    var rnd = Math.random() < 0.5 ? 1 : 2;
    var videoSrc = "file://{resources}/videos/visitor_screamer_" + rnd + ".webm";
    var sound = "visitor_screamer_" + rnd;
    Game.EmitSound(sound)
    $.CreatePanel(
        "MoviePanel",
        root,
        "screamer_visitor",
        {
            style: "width:100%;height:100%;align:center center;opacity:0.80;",
            class: "visitor_screamer_webm",
            src: videoSrc,
            repeat: "true",
            hittest: "false",
            autoplay: "onload"
        }
    );
}

function VisitorScreamerFalse() {
    var root = getScreamerRoot_Visitor();
    if (!root) return;
    root.RemoveAndDeleteChildren();
}

function getPeacemakerIntroRoot() {
    var p = $("#PeacemakerIntroPanel");
    if (p) return p;

    var hud = $.GetContextPanel();
    while (hud && hud.id !== "Hud") {
        hud = hud.GetParent();
    }
    return hud ? hud.FindChildTraverse("PeacemakerIntroPanel") : null;
}

function PeacemakerRIntroShow() {
    var root = getPeacemakerIntroRoot();
    if (!root) { $.Msg("PeacemakerIntro panel not found"); return; }
    root.RemoveAndDeleteChildren();

    var container = $.CreatePanel("Panel", root, "PeacemakerIntroContainer");
    container.hittest = false;

    var movie = $.CreatePanel("MoviePanel", container, "PeacemakerIntroVideo", {
        src: "file://{resources}/videos/peacemaker_r_intro.webm",
        repeat: "true",
        hittest: "false",
        autoplay: "onload"
    });

    var closeBtn = $.CreatePanel("Button", container, "PeacemakerIntroClose");
    closeBtn.SetPanelEvent("onactivate", PeacemakerRIntroCloseClicked);

    var lbl = $.CreatePanel("Label", closeBtn, "");
    lbl.text = "ЗАКРЫТЬ";
}

function PeacemakerRIntroHide() {
    var root = getPeacemakerIntroRoot();
    if (!root) return;
    root.RemoveAndDeleteChildren();
}

function PeacemakerRIntroCloseClicked() {
    PeacemakerRIntroHide();
    GameEvents.SendCustomGameEventToServer("peacemaker_r_close_clicked", {});
}

let MisoloRSplitState = null;

function GetMisoloRPriorityUnit() {
    if (!MisoloRSplitState) {
        return -1;
    }

    const order = ["beast", "visage", "arc"];
    for (const key of order) {
        const entindex = Number(MisoloRSplitState[key] || -1);
        if (entindex > -1 && Entities.IsValidEntity(entindex) && Entities.IsAlive(entindex)) {
            return entindex;
        }
    }

    return -1;
}

function TrySelectMisoloRUnits(data, attempt = 0) {
    const unitIds = [];

    ["beast", "visage", "arc"].forEach((key) => {
        const entindex = Number(data[key] || -1);
        if (entindex > -1 && Entities.IsValidEntity(entindex)) {
            unitIds.push(entindex);
        }
    });

    if (unitIds.length <= 0) {
        if (attempt < 10) {
            $.Schedule(0.03, () => TrySelectMisoloRUnits(data, attempt + 1));
        }
        return;
    }

    GameUI.SelectUnit(unitIds[0], false);
    for (let i = 1; i < unitIds.length; i++) {
        GameUI.SelectUnit(unitIds[i], true);
    }
}

function OnMisoloRSelectSplitUnits(data) {
    MisoloRSplitState = {
        caster: Number(data.caster || -1),
        beast: Number(data.beast || -1),
        visage: Number(data.visage || -1),
        arc: Number(data.arc || -1),
    };
    TrySelectMisoloRUnits(data, 0);
}

function OnMisoloRSelectReturnUnit(data) {
    MisoloRSplitState = null;

    const entindex = Number(data.unit_entindex || -1);
    if (entindex > -1 && Entities.IsValidEntity(entindex)) {
        GameUI.SelectUnit(entindex, false);
        return;
    }

    $.Schedule(0.03, () => {
        if (entindex > -1 && Entities.IsValidEntity(entindex)) {
            GameUI.SelectUnit(entindex, false);
        }
    });
}

function OnMisoloRSelectedUnitChanged() {
    if (!MisoloRSplitState) {
        return;
    }

    const selected = Players.GetLocalPlayerPortraitUnit();
    if (selected !== MisoloRSplitState.caster) {
        return;
    }

    const priority = GetMisoloRPriorityUnit();
    if (priority > -1 && priority !== selected) {
        GameUI.SelectUnit(priority, false);
    }
}

(function () {
    GameEvents.Subscribe( "CharaScreamerTrue", CharaScreamerTrue );
    GameEvents.Subscribe( "CharaScreamerFalse", CharaScreamerFalse );
    GameEvents.Subscribe( "VisitorScreamerTrue", VisitorScreamerTrue );
    GameEvents.Subscribe( "VisitorScreamerFalse", VisitorScreamerFalse );
    GameEvents.Subscribe("PeacemakerRIntroShow", PeacemakerRIntroShow);
    GameEvents.Subscribe("PeacemakerRIntroHide", PeacemakerRIntroHide);
    GameEvents.Subscribe("misolo_r_select_split_units", OnMisoloRSelectSplitUnits);
    GameEvents.Subscribe("misolo_r_select_return_unit", OnMisoloRSelectReturnUnit);
    GameEvents.Subscribe("dota_player_update_selected_unit", OnMisoloRSelectedUnitChanged);
})();
