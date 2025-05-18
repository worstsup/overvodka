function GameUpdater()
{
    let hero = Players.GetLocalPlayerPortraitUnit()
    UpdateLevelPanel(hero)
    $.Schedule(1/144, GameUpdater)
}

function UpdateLevelPanelMax(ability_panel, hero)
{
    let ButtonSize = ability_panel.FindChildTraverse("ButtonSize")
    if (ButtonSize)
    {
        let max_effect = ButtonSize.FindChildTraverse("max_effect")
        if (max_effect == null)
        {
            max_effect = $.CreatePanel("DOTAScenePanel", ButtonSize, "max_effect", { style: "width:100%;height:100%;opacity:0;z-index:1;", map: "maps/max_level.vmap", particleonly:"false", hittest:"false", camera:"camera_1" });
        }
        let ability_name = ability_panel.FindChildTraverse("AbilityImage").abilityname
        let ability = Entities.GetAbilityByName( hero, ability_name )
        if (ability && FindModifierByName(hero, "modifier_sans_r") != "none")
        {
            max_effect.style.opacity = "1"
        }
        else
        {
            max_effect.style.opacity = "0"
        }
    }
}
function FindModifierByName(EntityIndex, BuffName)
{
    for (let i = 0; i <= Entities.GetNumBuffs(EntityIndex) - 1; i++)
    {
        const BuffIndex = Entities.GetBuff(EntityIndex, i )
        if(Buffs.GetName(EntityIndex, BuffIndex) == BuffName)
        {
            return BuffIndex
        }
    }
    return "none"
}
function GetDotaHudZ()
{
	let hPanel = $.GetContextPanel();

	while ( hPanel && hPanel.id !== 'Hud')
	{
        hPanel = hPanel.GetParent();
	}

	if (!hPanel)
	{
        throw new Error('Could not find Hud root from panel with id: ' + $.GetContextPanel().id);
	}

	return hPanel;
}

function FindDotaHudElementZ(sId)
{
	return GetDotaHudZ().FindChildTraverse(sId);
}

function UpdateLevelPanel(hero)
{
    let AbilitiesAndStatBranch = FindDotaHudElementZ("AbilitiesAndStatBranch")
    if (AbilitiesAndStatBranch == null) { return }
    let abilities = AbilitiesAndStatBranch.FindChildTraverse("abilities")
    if (abilities == null) { return }
    for (var i = 0; i < 3; i++)
    {
        let ability_panel = abilities.GetChild(i)
        if (ability_panel)
        {
            UpdateLevelPanelMax(ability_panel, hero)
        }
    }
    current_selected_hero = hero
}

GameUpdater()