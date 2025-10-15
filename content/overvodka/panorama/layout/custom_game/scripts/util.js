let meepo_boss_hero_name = "npc_dota_hero_queenofpain"
let meepo_boss_hero

function FindHeroBoss()
{
    Entities.GetAllHeroEntities().forEach((entity) => {
        if (Entities.GetUnitName( entity ) == meepo_boss_hero_name) {
            meepo_boss_hero = entity
        }
    })
    if (!meepo_boss_hero) {
        $.Schedule(1/144, FindHeroBoss)
    }
}
FindHeroBoss()

function GetDotaHud()
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

function FindDotaHudElement(sId)
{
	return GetDotaHud().FindChildTraverse(sId);
}

function HasModifier(unit, modifier) 
{
    for (var i = 0; i < Entities.GetNumBuffs(unit); i++) 
    {
        if (Buffs.GetName(unit, Entities.GetBuff(unit, i)) == modifier)
        {
            return true
        }
    }
    return false
}

function FindModifier(unit, modifier) 
{
    for (var i = 0; i < Entities.GetNumBuffs(unit); i++) 
    {
        if (Buffs.GetName(unit, Entities.GetBuff(unit, i)) == modifier)
        {
            return Entities.GetBuff(unit, i);
        }
    }
    return null
}

function ConvertTimeMinutes(time)
{
    var min = Math.trunc((time)/60) 
    var sec_n =  (time) - 60*Math.trunc((time)/60) 
    var min = String(min - 60*( Math.trunc(min/60) ))
    var sec = String(sec_n)
    if (sec_n < 10) 
    {
        sec = '0' + sec
    }
    return min + ':' + sec
}

function ShowAbilityDescription(panel, ability)
{
    panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowAbilityTooltip', panel, ability); });
    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideAbilityTooltip', panel);
    });       
}

function ShowAbilityDescriptionForHero(panel, ability, hero)
{
    panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowAbilityTooltipForEntityIndex', panel, ability, hero); });
        
    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideAbilityTooltip', panel);
    });        
}

function ShowAbilityDescriptionLevel(panel, ability, level)
{
    panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowAbilityTooltipForLevel', panel, ability, level); });
    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideAbilityTooltip', panel);
    });       
}

function ShowTextForPanel(panel, text)
{
    panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowTextTooltip', panel, $.Localize(text)); });
    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideTextTooltip', panel);
    });       
}

function Vector_normalize(vec)
{
	const val = 1 / Math.sqrt(Math.pow(vec[0], 2) + Math.pow(vec[1], 2) + Math.pow(vec[2], 2));
	return [vec[0] * val, vec[1] * val, vec[2] * val];
}

function Vector_mult(vec, mult)
{
	return [vec[0] * mult, vec[1] * mult, vec[2] * mult];
}

function Vector_add(vec1, vec2)
{
	return [vec1[0] + vec2[0], vec1[1] + vec2[1], vec1[2] + vec2[2]];
}

function Vector_sub(vec1, vec2)
{
	return [vec1[0] - vec2[0], vec1[1] - vec2[1], vec1[2] - vec2[2]];
}

function Vector_negate(vec)
{
	return [-vec[0], -vec[1], -vec[2]];
}

function Vector_flatten(vec)
{
	return [vec[0], vec[1], 0];
}

function Vector_raiseZ(vec, inc)
{
	return [vec[0], vec[1], vec[2] + inc];
}

function Vector_distance (vec1, vec2) 
{
	return Math.sqrt(((vec2[0] - vec1[0]) ** 2) + ((vec2[1] - vec1[1]) ** 2));
}

function print(...args) {
    args.forEach((element) => {
        $.Msg(element)
    })
}

function GetUniverseSteamID32(PID)
{
    var steamID64 = Game.GetPlayerInfo(PID).player_steamid,
    steamIDPart = Number(steamID64.substring(3)),
    steamID32 = String(steamIDPart - 61197960265728);

    return steamID32;
}