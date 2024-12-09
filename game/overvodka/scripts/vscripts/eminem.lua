function Eminem(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage = ability:GetSpecialValueFor("damagess")
	local typedamage = DAMAGE_TYPE_MAGICAL
	if target:HasModifier("modifier_black_king_bar_immune") then damage = damage * 0.2 end
	if target:IsMagicImmune() then damage = damage * 0.2 end
	ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = typedamage, ability = ability})
end

function Immunov(keys)
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")
	if caster:HasScepter() then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_rootec", { Duration = duration })
	else
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_stunchik", { Duration = duration })
	end
end