function President( keys )
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local caster = keys.caster	
	local target = keys.target
	local duration = ability:GetSpecialValueFor("duration")
	
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_naval_president", { Duration = duration })
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_naval_president_effect2", { Duration = duration })
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_naval_president_effect", { Duration = duration })
	if caster:HasScepter() then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_naval_president_effect_scepter", { Duration = (duration/2) })
	end
end