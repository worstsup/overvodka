const CustomSkillPanelButton = $("#CustomSkillPanelButton")
const CustomSkillPanel = $("#CustomSkillPanel")

function GetDotaHud() {
    var rootUI = $.GetContextPanel();
    while (rootUI.id != "Hud" && rootUI.GetParent() != null) {
        rootUI = rootUI.GetParent();
    }
    return rootUI;
}
function SafeDeleteAsync(p){
    if(p && p.IsValid()){
        p.DeleteAsync(0)
    }
}
function Start(){
    let LocalPlayer = Players.GetLocalPlayer()
    let HeroName = Players.GetPlayerSelectedHero( LocalPlayer )
    if (HeroName == "npc_dota_hero_invoker"){
        let DotaHud = GetDotaHud()
        let Abilities = DotaHud.FindChildTraverse("abilities")
        CreatePanel(Abilities)
    }
}
function CreatePanel(Abilities){
    let ability6 = Abilities.FindChildTraverse("Ability5")
    if (ability6 == undefined){
        $.Schedule(0.1, function(){
            CreatePanel(Abilities)
        })
    }
    else{
        let findPanel = ability6.FindChildTraverse("CustomSkillPanelButton");
        if (findPanel) {
            SafeDeleteAsync(findPanel)
        }
        CustomSkillPanelButton.RemoveClass("Hidden")
        CustomSkillPanelButton.SetParent(ability6);
    }
}
function TogglePanel(){
    CustomSkillPanel.SetHasClass("Show", !CustomSkillPanel.BHasClass("Show"))
}
function UpdatePanel(){
    let queryUnit = Players.GetLocalPlayerPortraitUnit();
    let UnitName = Entities.GetUnitName(queryUnit);
    if (UnitName == "npc_dota_hero_invoker"){
        CustomSkillPanelButton.RemoveClass("Hidden")
    }
    else{
         CustomSkillPanelButton.AddClass("Hidden")
    }
}
Start();
GameEvents.Subscribe('dota_player_update_query_unit', UpdatePanel);
GameEvents.Subscribe('dota_player_update_hero_selection', UpdatePanel);
GameEvents.Subscribe('dota_player_update_selected_unit', UpdatePanel);