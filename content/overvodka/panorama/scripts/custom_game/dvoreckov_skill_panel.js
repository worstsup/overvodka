const CustomSkillPanelButton = $("#CustomSkillPanelButton")
const CustomSkillPanel = $("#CustomSkillPanel")
const COMBOS = [
    "dvoreckov_www","dvoreckov_qqq","dvoreckov_eee",
    "dvoreckov_qww","dvoreckov_qqw","dvoreckov_wee",
    "dvoreckov_wwe","dvoreckov_qqe","dvoreckov_qee",
    "dvoreckov_qwe"
  ];
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
    Game.EmitSound("UUI_SOUNDS.ButtonPress");
    CustomSkillPanel.SetHasClass("Show", !CustomSkillPanel.BHasClass("Show"))
    const isHidden = CustomSkillPanel.BHasClass("Hidden");
    if (isHidden) {
        for (let i=0; i<10; i++) {
          const icon = $(`#SkillIcon${i}`);
          const row = Math.floor(i / 3);
          const col = i % 3;

          let x = col * 173;
          let y = row * 57;

          if (i === 9) {
              x = 173;
              y = 169;
          }

          icon.style.x = `${x}px`;
          icon.style.y = `${y}px`;
          const name = COMBOS[i] || "";
          if (name) {
            icon.abilityname = name;
            icon.RemoveClass("Hidden");
            icon.SetPanelEvent("onmouseover", () => {
              $.DispatchEvent("DOTAShowAbilityTooltip", icon, name);
            });
            icon.SetPanelEvent("onmouseout",  () => {
              $.DispatchEvent("DOTAHideAbilityTooltip");
            });
          } else {
            icon.AddClass("Hidden");
          }
        }
        CustomSkillPanel.RemoveClass("Hidden");
      } else {
        CustomSkillPanel.AddClass("Hidden");
        for (let i=0; i<10; i++) {
          const icon = $(`#SkillIcon${i}`);
          icon.AddClass("Hidden");
        }
      }
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