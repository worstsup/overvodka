function Dmg (keys)
	local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local dadada = caster:GetStrength()
    if caster:GetUnitName() == "npc_dota_hero_pudge" then
		local Talent = caster:FindAbilityByName("special_bonus_unique_pugna_5")
		if Talent:GetLevel() == 1 then
        	dadada = caster:GetStrength() * 2
    	end
    end
    

    local damage_table = {}

    damage_table.damage = dadada
    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    ApplyDamage(damage_table)
end



function LevelUpAbility( event )
	local caster = event.caster
	local this_ability = event.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name = event.ability_name
	local ability_handle = caster:FindAbilityByName(ability_name)	
	local ability_level = ability_handle:GetLevel()

	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end
end