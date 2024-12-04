function LinkenCheck( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if target:TriggerSpellAbsorb(ability) then 
		target:RemoveModifierByName("modifier_ns_fullcounter_debuff")
		caster:RemoveModifierByName("modifier_ns_fullcounter_buff")
		return
	end
end