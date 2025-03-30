function RocketsDamage (keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1)
	local gold = ability:GetLevelSpecialValueFor("gold", ability:GetLevel() - 1)
	local damage_type = DAMAGE_TYPE_MAGICAL
	local duration = ability:GetLevelSpecialValueFor("stun_duration", ability:GetLevel() - 1)
	if target:TriggerSpellAbsorb(ability) then return end
	caster:ModifyGold(gold, false, 0)
	ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = damage_type })
	target:AddNewModifier( caster, self, "modifier_stunned", { duration = duration * (1 - target:GetStatusResistance()) } )
end