function WeAreNumberOneCast(keys)

	local caster = keys.caster
	local target = keys.target
	local unit = caster:GetUnitName()
	local ability = keys.ability
	local origin = target:GetAbsOrigin() + RandomVector(100)
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
	local attackDelay = ability:GetLevelSpecialValueFor( "attack_delay", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_outgoing_damage", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage", ability:GetLevel() - 1 )
	if caster:HasScepter() then
		incomingDamage = -1000
	end
	local illusion = CreateUnitByName(unit, origin, true, caster, nil, caster:GetTeam())
	illusion:SetPlayerID(caster:GetPlayerID())
	illusion:SetOwner(caster)
	if caster:GetUnitName() == "npc_dota_hero_riki" then
		local Talent = caster:FindAbilityByName("special_bonus_unique_pudge_3")
		if Talent:GetLevel() == 1 then
			duration = duration + 2
		end
	end
	if caster:GetUnitName() == "npc_dota_hero_riki" then
		local Talented = caster:FindAbilityByName("special_bonus_unique_viper_4")
		if Talented:GetLevel() == 1 then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_robi_WeAreNumberOne_root", {duration = 1})
		end
	end
	illusion:SetForwardVector(target:GetAbsOrigin() - illusion:GetAbsOrigin())

	local casterLevel = caster:GetLevel()
	for i=1,casterLevel-1 do
		illusion:HeroLevelUp(false)
	end

	illusion:SetAbilityPoints(0)
	for abilitySlot=0,15 do
		local ability = caster:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			local illusionAbility = illusion:FindAbilityByName(abilityName)
			illusionAbility:SetLevel(abilityLevel)
		end
	end

	for itemSlot=0,5 do
		local item = caster:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = CreateItem(itemName, illusion, illusion)
			illusion:AddItem(newItem)
		end
	end

	illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	illusion:MakeIllusion()
	if caster:HasScepter() then
		ability:ApplyDataDrivenModifier(caster, illusion, "modifier_robi_WeAreNumberOne_buff_scepter", {duration = duration})
	else
		ability:ApplyDataDrivenModifier(caster, illusion, "modifier_robi_WeAreNumberOne_buff", {duration = duration})
	end
	ability:ApplyDataDrivenModifier(caster, illusion, "modifier_robi_WeAreNumberOne_illusion_debuff", {duration = attackDelay})
	illusion:MoveToNPC(target)

	Timers:CreateTimer({
		endTime = attackDelay,
		callback = function()
			illusion:SetForceAttackTarget(target)
		end
	})

	caster.haunting = true

	Timers:CreateTimer({
		endTime = duration,
		callback = function()
			caster.haunting = false
		end
	})
end

function LevelUpWeAreNumberOne (keys)

	local caster = keys.caster
	local ability_reality = caster:FindAbilityByName("Robi_WeAreNumberOneTeleport")
	if ability_reality ~= nil then
		ability_reality:SetLevel(1)
	end

	caster.haunting = false

end