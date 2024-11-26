function Stunned( keys )
	local ability = keys.ability
	local caster = keys.caster	
	local target = keys.target
	local duration = ability:GetSpecialValueFor("crush_extra_slow_duration")
	if caster:HasScepter() then
		ability:ApplyDataDrivenModifier( caster, target, "modifier_ns_disarmed", { Duration = duration})
	end
end