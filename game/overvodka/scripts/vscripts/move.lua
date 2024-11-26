function TricksMaster(keys)
	local caster = keys.caster	
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local cooldown = ability:GetCooldown(level)
	local duration = ability:GetSpecialValueFor("duration")
	if caster:HasModifier("modifier_silver_edge_debuff") then return end
	if caster:HasModifier("modifier_break") then return end
	if caster:IsIllusion() == false then
		if ability:GetCooldownTimeRemaining() == 0 then
			ability:StartCooldown(cooldown)
			ability:ApplyDataDrivenModifier( caster, caster, "modifier_movement_speed", { Duration = duration })
			ability:ApplyDataDrivenModifier( caster, caster, "modifier_eff", { Duration = duration })
		end
	end
end 