function NewSong(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor( "duration" , ability:GetLevel() - 1  )
	caster:SetModelScale(1.8)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_mell_amam", {duration = duration })
end

function Damage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local bonus_gold = ability:GetSpecialValueFor("bonus_gold")
	local damage = ability:GetSpecialValueFor("damage")
	local radius = ability:GetSpecialValueFor("radius")
	local targets = FindUnitsInRadius(caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false)

	for _,unit in pairs(targets) do
		if caster:HasScepter() then
			damage = damage + unit:GetHealth() / 100 * 2
		end
		if unit:IsRealHero() then 
			caster:ModifyGold(bonus_gold, true, 0)
		end
		ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
	end
end

function Back(keys)
	local caster = keys.caster
	caster:SetModelScale(1.2)
end