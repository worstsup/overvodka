function GameUpdater()
{
    let hero = Players.GetLocalPlayerPortraitUnit()
    UpdateLevelPanel(hero)
    $.Schedule(1/144, GameUpdater)
}

function EnsureScenePanel(parent, panelId, mapName)
{
    if (!parent || !mapName)
    {
        return null
    }

    let panel = parent.FindChildTraverse(panelId)
    if (panel && panel._mapName !== mapName)
    {
        panel.DeleteAsync(0)
        panel = null
    }

    if (panel == null)
    {
        panel = $.CreatePanel("DOTAScenePanel", parent, panelId, {
            style: "width:100%;height:100%;opacity:0;z-index:1;",
            map: mapName,
            particleonly: "false",
            hittest: "false",
            camera: "camera_1"
        })
        panel._mapName = mapName
    }

    return panel
}

function UpdateLevelPanelMax(ability_panel, hero)
{
    let ButtonSize = ability_panel.FindChildTraverse("ButtonSize")
    if (ButtonSize)
    {
        let playerId = Players.GetLocalPlayer()
        let max_effect = ButtonSize.FindChildTraverse("max_effect")
        if (max_effect == null)
        {
            if (IsPlayerSubscribed(playerId)){
                max_effect = $.CreatePanel("DOTAScenePanel", ButtonSize, "max_effect", { style: "width:100%;height:100%;opacity:0;z-index:1;", map: "maps/sans_arcana.vmap", particleonly:"false", hittest:"false", camera:"camera_1" });
            }
            else
            {
                max_effect = $.CreatePanel("DOTAScenePanel", ButtonSize, "max_effect", { style: "width:100%;height:100%;opacity:0;z-index:1;", map: "maps/max_level.vmap", particleonly:"false", hittest:"false", camera:"camera_1" });
            }
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

function UpdateNixPanel(ability_panel, hero)
{
    let ButtonSize = ability_panel.FindChildTraverse("ButtonSize")
    if (!ButtonSize)
    {
        return
    }

    let abilityImage = ability_panel.FindChildTraverse("AbilityImage")
    if (abilityImage == null || !abilityImage.abilityname)
    {
        return
    }

    let nix_effect = ButtonSize.FindChildTraverse("nix_effect")

    if (hero == null || hero === -1 || Entities.GetUnitName(hero) !== "npc_dota_hero_furion")
    {
        if (nix_effect)
        {
            nix_effect.style.opacity = "0"
        }
        return
    }

    let showLevin = FindModifierByName(hero, "modifier_nix_swap_levin_updater") != "none"
    let showPravin = FindModifierByName(hero, "modifier_nix_swap_pravin_updater") != "none"
    let mapName = ""

    if (showPravin)
    {
        mapName = "maps/nix_pravin.vmap"
    }
    else if (showLevin)
    {
        mapName = "maps/nix_levin.vmap"
    }

    if (mapName != "")
    {
        nix_effect = EnsureScenePanel(ButtonSize, "nix_effect", mapName)
        if (nix_effect)
        {
            nix_effect.style.opacity = "1"
        }
    }
    else if (nix_effect)
    {
        nix_effect.style.opacity = "0"
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
    let childCount = abilities.GetChildCount ? abilities.GetChildCount() : 0
    for (var i = 0; i < 3; i++)
    {
        let ability_panel = abilities.GetChild(i)
        if (ability_panel)
        {
            UpdateLevelPanelMax(ability_panel, hero)
        }
    }
    for (var i = 0; i < childCount; i++)
    {
        let ability_panel = abilities.GetChild(i)
        if (ability_panel)
        {
            UpdateNixPanel(ability_panel, hero)
        }
    }
    current_selected_hero = hero
}

GameUpdater()
