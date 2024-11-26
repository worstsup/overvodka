function Taa(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage")
	local stack = ability:GetSpecialValueFor("stack")
	local kills = caster:GetKills()
	if target:TriggerSpellAbsorb(ability) then return end
	damage = damage + kills * stack
	ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = ability})
end