function LinkenCheck( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if target:TriggerSpellAbsorb(ability) then 
		target:RemoveModifierByName("modifier_golmiy_golbet")
		target:RemoveModifierByName("modifier_track_aura_datadriven")
		return
	end
end

function Track( keys )
	local caster = keys.caster
	local target = keys.target
	local targetLocation = target:GetAbsOrigin() 
	local ability = keys.ability
	local player_id = caster:GetPlayerID()
	local bonus_gold_self = ability:GetLevelSpecialValueFor("bonus_gold_self", (ability:GetLevel() - 1))
	local bonus_gold = ability:GetLevelSpecialValueFor("bonus_gold", (ability:GetLevel() - 1))
	local bonus_gold_radius = ability:GetLevelSpecialValueFor("bonus_gold_radius", (ability:GetLevel() - 1))
	if not target:IsAlive() then
		caster:ModifyGold(bonus_gold_self, true, 0)
		local bonus_gold_targets = FindUnitsInRadius(caster:GetTeam() , targetLocation, nil, bonus_gold_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY , DOTA_UNIT_TARGET_HERO, 0, 0, false)
		for i,v in ipairs(bonus_gold_targets) do
			if not (v == caster) then
				v:ModifyGold(bonus_gold, true, 0)
			end
		end
	else
		PlayerResource:SpendGold(player_id, bonus_gold, 4)
	end
	target:RemoveModifierByName("modifier_track_aura_datadriven") 
end