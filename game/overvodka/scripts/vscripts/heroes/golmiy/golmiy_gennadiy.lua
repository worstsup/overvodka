function Damage(event)
	local caster = event.caster
	local ability = event.ability
	local damage = ability:GetSpecialValueFor("damage") * ability:GetSpecialValueFor("damage_tick")
	local dmg_scepter = ability:GetSpecialValueFor("dmg_scepter") * caster:GetStrength() * 0.01 * ability:GetSpecialValueFor("damage_tick")
	local dmg = damage + dmg_scepter
	local targets = FindUnitsInRadius(caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		ability:GetSpecialValueFor("radius"),
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		FIND_ANY_ORDER,
		false) 

	for _,unit in pairs(targets) do
		ApplyDamage({victim = unit, attacker = caster, damage = dmg, damage_type = DAMAGE_TYPE_PURE, ability = ability})
	end
end

function BladeFuryStop( event )
	local caster = event.caster
	caster:StopSound("gennadiy")
end

function GolmiyModifier (keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))
	
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_golmiy_gennadiy", { Duration = duration })
end