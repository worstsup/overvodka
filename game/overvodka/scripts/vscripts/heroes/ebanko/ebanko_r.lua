function ebanko_r( keys )
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local caster = keys.caster	
	local target = keys.target
	local duration = ability:GetSpecialValueFor("duration")
	
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_ebanko_r", { Duration = duration })
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_ebanko_r_effect2", { Duration = duration })
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_ebanko_r_effect", { Duration = duration })
	if caster:HasScepter() then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_ebanko_r_effect_scepter", { Duration = (duration/2) })
	end
end