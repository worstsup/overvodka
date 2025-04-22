const DotaHUD = GetDotaHud()
let Fixed = false
const HEROES_TO_DELETE = [
    "npc_dota_hero_riki"
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