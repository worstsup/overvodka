function StealDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local buff = "modifier_steal_damage_buff"
	local debuff = "modifier_steal_damage_debuff"
	local buff_ms = "modifier_steal_ms_buff"
	local debuff_ms = "modifier_steal_ms_debuff"
	local dur = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1)
	local stack_value_ms = ability:GetLevelSpecialValueFor("ms", ability:GetLevel() - 1)
	local stack_value = ability:GetLevelSpecialValueFor("damage_steal", ability:GetLevel() - 1)
	local buff_mag = "modifier_steal_resist_buff"
	local debuff_mag = "modifier_steal_resist_debuff"
	local stack_value_mag = ability:GetLevelSpecialValueFor("magresist", ability:GetLevel() - 1)
	local caster_location = caster:GetAbsOrigin()
	local target_location = target:GetAbsOrigin()
	local distance = (target_location - caster_location):Length2D()
	local break_distance = ability:GetLevelSpecialValueFor("break_distance", (ability:GetLevel() - 1))

	if distance >= break_distance then
		target:RemoveModifierByName("modifier_Doljan_RapBattle_debuff")
		return
	end
	if target:HasModifier( debuff_ms ) and caster:HasModifier( buff_ms ) then
		local current_stack_ms = target:GetModifierStackCount( debuff_ms, ability )
		ability:ApplyDataDrivenModifier( caster, caster, buff_ms, { Duration = dur })
		ability:ApplyDataDrivenModifier( caster, target, debuff_ms, { Duration = dur })
		caster:SetModifierStackCount( buff_ms, ability, current_stack_ms + stack_value_ms )
		target:SetModifierStackCount( debuff_ms, ability, current_stack_ms + stack_value_ms )
	end
	if target:HasModifier( debuff_ms ) and caster:HasModifier( buff_ms ) == false then
		ability:ApplyDataDrivenModifier( caster, caster, buff_ms, { Duration = dur })
		ability:ApplyDataDrivenModifier( caster, target, debuff_ms, { Duration = dur })
		caster:SetModifierStackCount( buff_ms, ability, stack_value_ms )
		target:SetModifierStackCount( debuff_ms, ability, current_stack_ms + stack_value_ms )
	end
	if target:HasModifier( debuff_ms ) == false and caster:HasModifier( buff_ms ) then
		ability:ApplyDataDrivenModifier( caster, caster, buff_ms, { Duration = dur })
		ability:ApplyDataDrivenModifier( caster, target, debuff_ms, { Duration = dur })
		caster:SetModifierStackCount( buff_ms, ability, current_stack_ms + stack_value_ms )
		target:SetModifierStackCount( debuff_ms, ability, stack_value_ms )
	end
	if target:HasModifier( debuff_ms ) == false and caster:HasModifier( buff_ms ) == false then
		ability:ApplyDataDrivenModifier( caster, caster, buff_ms, { Duration = dur })
		ability:ApplyDataDrivenModifier( caster, target, debuff_ms, { Duration = dur })
		caster:SetModifierStackCount( buff_ms, ability, stack_value_ms )
		target:SetModifierStackCount( debuff_ms, ability, stack_value_ms )
	end
	
	if target:HasModifier( debuff ) and caster:HasModifier( buff ) then
		local current_stack = target:GetModifierStackCount( debuff, ability )
		ability:ApplyDataDrivenModifier( caster, caster, buff, { Duration = dur })
		ability:ApplyDataDrivenModifier( caster, target, debuff, { Duration = dur })
		caster:SetModifierStackCount( buff, ability, current_stack + stack_value )
		target:SetModifierStackCount( debuff, ability, current_stack + stack_value )
	end
	if target:HasModifier( debuff ) and caster:HasModifier( buff ) == false then
		ability:ApplyDataDrivenModifier( caster, caster, buff, { Duration = dur })
		ability:ApplyDataDrivenModifier( caster, target, debuff, { Duration = dur })
		caster:SetModifierStackCount( buff, ability, stack_value )
		target:SetModifierStackCount( debuff, ability, current_stack + stack_value )
	end
	if target:HasModifier( debuff ) == false and caster:HasModifier( buff ) then
		ability:ApplyDataDrivenModifier( caster, caster, buff, { Duration = dur })
		ability:ApplyDataDrivenModifier( caster, target, debuff, { Duration = dur })
		caster:SetModifierStackCount( buff, ability, current_stack + stack_value )
		target:SetModifierStackCount( debuff, ability, stack_value )
	end
	if target:HasModifier( debuff ) == false and caster:HasModifier( buff ) == false then
		ability:ApplyDataDrivenModifier( caster, caster, buff, { Duration = dur })
		ability:ApplyDataDrivenModifier( caster, target, debuff, { Duration = dur })
		caster:SetModifierStackCount( buff, ability, stack_value )
		target:SetModifierStackCount( debuff, ability, stack_value )
	end

	if target:HasModifier( debuff_mag ) and caster:HasModifier( buff_mag ) then
		local current_stack_mag = target:GetModifierStackCount( debuff_mag, ability )
		ability:ApplyDataDrivenModifier( caster, caster, buff_mag, { Duration = dur })
		ability:ApplyDataDrivenModifier( caster, target, debuff_mag, { Duration = dur })
		caster:SetModifierStackCount( buff_mag, ability, current_stack_mag + stack_value_mag )
		target:SetModifierStackCount( debuff_mag, ability, current_stack_mag + stack_value_mag )
	end
	if target:HasModifier( debuff_mag ) and caster:HasModifier( buff_mag ) == false then
		ability:ApplyDataDrivenModifier( caster, caster, buff_mag, { Duration = dur })
		ability:ApplyDataDrivenModifier( caster, target, debuff_mag, { Duration = dur })
		caster:SetModifierStackCount( buff_mag, ability, stack_value_mag )
		target:SetModifierStackCount( debuff_mag, ability, current_stack_mag + stack_value_mag )
	end
	if target:HasModifier( debuff_mag ) == false and caster:HasModifier( buff_mag ) then
		ability:ApplyDataDrivenModifier( caster, caster, buff_mag, { Duration = dur })
		ability:ApplyDataDrivenModifier( caster, target, debuff_mag, { Duration = dur })
		caster:SetModifierStackCount( buff_mag, ability, current_stack_mag + stack_value_mag )
		target:SetModifierStackCount( debuff_mag, ability, stack_value_mag )
	end
	if target:HasModifier( debuff_mag ) == false and caster:HasModifier( buff_mag ) == false then
		ability:ApplyDataDrivenModifier( caster, caster, buff_mag, { Duration = dur })
		ability:ApplyDataDrivenModifier( caster, target, debuff_mag, { Duration = dur })
		caster:SetModifierStackCount( buff_mag, ability, stack_value_mag )
		target:SetModifierStackCount( debuff_mag, ability, stack_value_mag )
	end
end

function stop_sound( keys )
	local target = keys.target
	local sound = keys.sound

	StopSoundEvent(sound, target)
end

function DealDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage_type = ability:GetAbilityDamageType()
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1)
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1)
	local dps = ability:GetLevelSpecialValueFor("dps", (ability:GetLevel() -1))
	local target_teams = ability:GetAbilityTargetTeam()
	local target_types = ability:GetAbilityTargetType()
	local target_flags = ability:GetAbilityTargetFlags()
	local target_location = target:GetAbsOrigin()
	local units = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, radius, target_teams, target_types, target_flags, 0, false)
	local caster_location = caster:GetAbsOrigin()
	local target_location = target:GetAbsOrigin()
	local distance = (target_location - caster_location):Length2D()
	local break_distance = ability:GetLevelSpecialValueFor("break_distance", (ability:GetLevel() - 1))

	if distance >= break_distance then
		target:RemoveModifierByName("modifier_Doljan_RapBattle_debuff")
		return
	end
	
	ApplyDamage({ victim = target, attacker = caster, damage = dps, damage_type = damage_type })
end