function TwentyThree(keys)
	local caster = keys.caster	
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local duration = ability:GetSpecialValueFor("duration")
	if caster:PassivesDisabled() then return end
	if caster:IsIllusion() == false then
		if ability:GetCooldownTimeRemaining() == 0 then
			ability:UseResources( false, false, false, true )
			ability:ApplyDataDrivenModifier( caster, caster, "modifier_movement_speed", { Duration = duration })
			ability:ApplyDataDrivenModifier( caster, caster, "modifier_eff", { Duration = duration })
		end
	end
end 