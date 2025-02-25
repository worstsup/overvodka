const LocalPIDPlayer = Players.GetLocalPlayer()

function GetDotaHud() {
	var rootUI = $.GetContextPanel();
	while (rootUI.id != "Hud" && rootUI.GetParent() != null) {
		rootUI = rootUI.GetParent();
	}
	return rootUI;
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
            min: 9000,
            max: 20000,
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
    if (HeroName == "npc_dota_hero_undying")
    {
        OvervodkaName = "npc_dota_hero_dmb"
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
    if (HeroName == "npc_dota_hero_monkey_king")
    {
        OvervodkaName = "npc_dota_hero_loban"
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
        OvervodkaName = "npc_dota_hero_sans"
    }
    if (HeroName == "npc_dota_hero_faceless_void")
    {
        OvervodkaName = "npc_dota_hero_evelone"
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