tartar = {}
function Meteor(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local target = caster:GetCursorPosition() + 5

	local caster_loc = caster:GetAttachmentOrigin(DOTA_PROJECTILE_ATTACHMENT_ATTACK_1)
	local cast_direction = caster:GetForwardVector()
	local meteor_count = 1
	local distince = 1250
	local projectile_direction = (target - caster:GetAbsOrigin()):Normalized()
	caster:EmitSound("penal")
	tartar = {}
	local arrow_projectile = {
		Ability				= ability,
		EffectName			= "particles/invoker_chaos_meteor_new.vpcf",
		vSpawnOrigin		= caster:GetAbsOrigin(),
		fDistance			= distince,
		fStartRadius		= 115,
		fEndRadius			= 120,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting = false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		bDeleteOnHit		= true,
		vVelocity			= projectile_direction * 1000,
		bProvidesVision		= true,
		iVisionRadius		= 200,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	}
	local xx = projectile_direction.x
	local yy = projectile_direction.y
	projectile_direction.x = xx * (3 ^ 0.5) / 2 - (yy / 2)
	projectile_direction.y = (xx / 2) + (yy * (3 ^ 0.5) / 2)
	local arrow_projectile_1 = {
		Ability				= ability,
		EffectName			= "particles/invoker_chaos_meteor_new.vpcf",
		vSpawnOrigin		= caster:GetAbsOrigin(),
		fDistance			= distince,
		fStartRadius		= 115,
		fEndRadius			= 120,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting = false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		bDeleteOnHit		= true,
		vVelocity			= projectile_direction * 1000,
		bProvidesVision		= true,
		iVisionRadius		= 200,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	}
	projectile_direction.x = xx * (3 ^ 0.5) / 2 + (yy / 2)
	projectile_direction.y = -(xx / 2) + (yy * (3 ^ 0.5) / 2)
	local arrow_projectile_2 = {
		Ability				= ability,
		EffectName			= "particles/invoker_chaos_meteor_new.vpcf",
		vSpawnOrigin		= caster:GetAbsOrigin(),
		fDistance			= distince,
		fStartRadius		= 115,
		fEndRadius			= 120,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting = false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		bDeleteOnHit		= true,
		vVelocity			= projectile_direction * 1000,
		bProvidesVision		= true,
		iVisionRadius		= 200,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	}
	ProjectileManager:CreateLinearProjectile(arrow_projectile)
	if caster:GetUnitName() == "npc_dota_hero_brewmaster" then
		local Talented = caster:FindAbilityByName("special_bonus_unique_viper_2")
		if Talented:GetLevel() == 1 then
			ProjectileManager:CreateLinearProjectile(arrow_projectile_1)
			ProjectileManager:CreateLinearProjectile(arrow_projectile_2)
		end
	end
end

function MeteorHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local stun_time = ability:GetLevelSpecialValueFor("meteor_stun", ability_level)
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)
	local gold = ability:GetLevelSpecialValueFor("gold", ability_level)
	for _,v in ipairs(tartar) do  
		if v == target then return end
	end
	target:EmitSound("Hero_WarlockGolem.Attack")
	if target:IsRealHero() then
		caster:ModifyGold(gold, false, 0)
	end
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
	target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_time})
	ability:ApplyDataDrivenModifier( caster, target, "megumin_meteor_fired_debuff", { Duration = 5 } )
	table.insert(tartar, target)
end

function MeteorHitDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local damage = ability:GetLevelSpecialValueFor("think_damage", ability_level)
	ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
end