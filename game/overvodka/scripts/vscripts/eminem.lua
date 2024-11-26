function Eminem(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage = ability:GetSpecialValueFor("damagess")
	local typedamage = DAMAGE_TYPE_MAGICAL
	ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = typedamage, ability = ability})
end

function Immunov(keys)
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")
	if caster:HasScepter() then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_rootec", { Duration = duration })
		ability:ApplyDataDrivenModifier( caster, caster, "Modifier_immunov", { Duration = duration })
	else
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_stunchik", { Duration = duration })
	end
end