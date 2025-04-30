const DotaHUD = GetDotaHud()
let Fixed = false
const HEROES_TO_DELETE = [
    "npc_dota_hero_pudge",
    "npc_dota_hero_kunkka",
    "npc_dota_hero_tinker",
    "npc_dota_hero_invoker",
    "npc_dota_hero_meepo",
    "npc_dota_hero_axe",
    "npc_dota_hero_phoenix",
    "npc_dota_hero_bounty_hunter",
    "npc_dota_hero_ursa",
    "npc_dota_hero_zuus",
    "npc_dota_hero_tidehunter",
    "npc_dota_hero_earthshaker",
    "npc_dota_hero_furion",
    "npc_dota_hero_clinkz",
    "npc_dota_hero_ogre_magi",
    "npc_dota_hero_ancient_apparition",
    "npc_dota_hero_bloodseeker",
    "npc_dota_hero_juggernaut",
    "npc_dota_hero_skeleton_king",
    "npc_dota_hero_rattletrap",
    "npc_dota_hero_storm_spirit",
    "npc_dota_hero_necrolyte",
    "npc_dota_hero_morphling",
    "npc_dota_hero_faceless_void",
    "npc_dota_hero_slark",
    "npc_dota_hero_weaver",
    "npc_dota_hero_riki",
    "npc_dota_hero_brewmaster",
]

function FixModelScene(){
    let StrategyScreen = DotaHUD.FindChildTraverse("StrategyScreen")
    if(StrategyScreen){
        let Preview = StrategyScreen.FindChildTraverse("Preview")
        if(Preview){
            let Preview3DItems = Preview.FindChildTraverse("Preview3DItems")
            if(Preview3DItems){
                let LocalPlayerInfo = Game.GetPlayerInfo( LocalPIDPlayer )
                if(Preview3DItems && Preview3DItems.IsValid() && Preview3DItems.BHasClass("SceneLoaded") && HEROES_TO_DELETE.includes(LocalPlayerInfo.player_selected_hero) && Fixed == false){
                    Fixed = true
                    if(Preview3DItems && Preview3DItems.IsValid()){
                        Preview3DItems.FireEntityInput(
                            "*",
                            "RunScriptCode",
                            `
                            if thisEntity:GetClassname() == 'dota_item_wearable' then
                                thisEntity:SetContextThink('delete',function() UTIL_Remove(thisEntity) end,0)
                            end
                        `
                        );
                        $.Msg("Setted")
                    }
                }
            }
        }
    }
    
    if(!Fixed && Game.GameStateIsBefore( DOTA_GameState.DOTA_GAMERULES_STATE_PRE_GAME )){
        $.Schedule(0, FixModelScene)
    }
}

FixModelScene()