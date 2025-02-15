k = 0
function Meteor_start(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	k = 0
	caster:EmitSound("fruits")
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_mell", { Duration = 7} )
end

function Meteor(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local player = caster:GetPlayerOwnerID()
	local gold = PlayerResource:GetGold(player)
	local target = caster:GetCursorPosition() + 5
	tartar = {}
	k = k + 1
	local caster_loc = caster:GetAttachmentOrigin(DOTA_PROJECTILE_ATTACHMENT_ATTACK_1)
	local cast_direction = caster:GetForwardVector()
	local meteor_count = 1
	local distince = 800
	local eff = "particles/invoker_chaos_meteor_mell_1.vpcf"
	if k == 2 then
		eff = "particles/invoker_chaos_meteor_mell_2.vpcf"
	end
	if k == 3 then
		eff = "particles/invoker_chaos_meteor_mell_3.vpcf"
	end
	if k == 4 then
		eff = "particles/invoker_chaos_meteor_mell_4.vpcf"
	end
	if k == 5 then
		eff = "particles/invoker_chaos_meteor_mell_5.vpcf"
	end
	local projectile_direction = (target - caster:GetAbsOrigin()):Normalized()
	local arrow_projectile = {
		Ability				= ability,
		EffectName			= eff,
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
		vVelocity			= projectile_direction * 1500,
		bProvidesVision		= true,
		iVisionRadius		= 200,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	}
	local xx = projectile_direction.x
	local yy = projectile_direction.y
	projectile_direction.x = xx * (2 ^ 0.5) / 2 - (yy * (2 ^ 0.5) / 2)
	projectile_direction.y = (xx * (2 ^ 0.5) / 2) + (yy * (2 ^ 0.5) / 2)
	local arrow_projectile_1 = {
		Ability				= ability,
		EffectName			= eff,
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
		vVelocity			= projectile_direction * 1500,
		bProvidesVision		= true,
		iVisionRadius		= 200,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	}
	projectile_direction.x = xx * (2 ^ 0.5) / 2 + (yy * (2 ^ 0.5) / 2)
	projectile_direction.y = -(xx * (2 ^ 0.5) / 2) + (yy * (2 ^ 0.5) / 2)
	local arrow_projectile_2 = {
		Ability				= ability,
		EffectName			= eff,
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
		vVelocity			= projectile_direction * 1500,
		bProvidesVision		= true,
		iVisionRadius		= 200,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	}
	projectile_direction.x = -xx * (2 ^ 0.5) / 2 - (yy * (2 ^ 0.5) / 2)
	projectile_direction.y = (xx * (2 ^ 0.5) / 2) - (yy * (2 ^ 0.5) / 2)
	local arrow_projectile_3 = {
		Ability				= ability,
		EffectName			= eff,
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
		vVelocity			= projectile_direction * 1500,
		bProvidesVision		= true,
		iVisionRadius		= 200,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	}
	projectile_direction.x = -xx * (2 ^ 0.5) / 2 + (yy * (2 ^ 0.5) / 2)
	projectile_direction.y = -(xx * (2 ^ 0.5) / 2) - (yy * (2 ^ 0.5) / 2)
	local arrow_projectile_4 = {
		Ability				= ability,
		EffectName			= eff,
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
		vVelocity			= projectile_direction * 1500,
		bProvidesVision		= true,
		iVisionRadius		= 200,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	}
	projectile_direction.x = -xx
	projectile_direction.y = -yy
	local arrow_projectile_5 = {
		Ability				= ability,
		EffectName			= eff,
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
		vVelocity			= projectile_direction * 1500,
		bProvidesVision		= true,
		iVisionRadius		= 200,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	}
	projectile_direction.x = -yy
	projectile_direction.y = xx
	local arrow_projectile_6 = {
		Ability				= ability,
		EffectName			= eff,
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
		vVelocity			= projectile_direction * 1500,
		bProvidesVision		= true,
		iVisionRadius		= 200,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	}
	projectile_direction.x = yy
	projectile_direction.y = -xx
	local arrow_projectile_7 = {
		Ability				= ability,
		EffectName			= eff,
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
		vVelocity			= projectile_direction * 1500,
		bProvidesVision		= true,
		iVisionRadius		= 200,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	}
	ProjectileManager:CreateLinearProjectile(arrow_projectile)
	ProjectileManager:CreateLinearProjectile(arrow_projectile_1)
	ProjectileManager:CreateLinearProjectile(arrow_projectile_2)
	ProjectileManager:CreateLinearProjectile(arrow_projectile_3)
	ProjectileManager:CreateLinearProjectile(arrow_projectile_4)
	ProjectileManager:CreateLinearProjectile(arrow_projectile_5)
	ProjectileManager:CreateLinearProjectile(arrow_projectile_6)
	ProjectileManager:CreateLinearProjectile(arrow_projectile_7)
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
	if target:IsRealHero() and not target:IsIllusion() then
		caster:ModifyGold(gold, false, 0)
	end
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
	ability:ApplyDataDrivenModifier( caster, target, "mellstroy_meteor_slowed_debuff", { Duration = stun_time } )
	ability:ApplyDataDrivenModifier( caster, target, "mellstroy_meteor_fired_debuff", { Duration = 4 } )
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