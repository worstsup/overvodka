modifier_topor = class({})

function modifier_topor:IsPurgable()
	return false
end

function modifier_topor:OnCreated( kv )
	if not IsServer() then return end
	self.as = 1000
	self.bat = self:GetAbility():GetSpecialValueFor( "bat" )
	self.speed = self:GetAbility():GetSpecialValueFor( "bonus_speed" )
	self.projectile = 900
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_dmg" )
	self.range = self:GetAbility():GetSpecialValueFor( "range" )
	if self:GetParent():GetUnitName() == "npc_dota_hero_rubick" then
		self.range = 0
		self.projectile = 0
	end
	self.slow = self:GetAbility():GetSpecialValueFor( "slow_max" )
	self.slow_radius = self:GetAbility():GetSpecialValueFor( "slow_radius" )
	self:GetParent():SetAttackCapability( DOTA_UNIT_CAP_RANGED_ATTACK )
	self:StartIntervalThink( 0.4 )
	self:OnIntervalThink()
end

function modifier_topor:OnIntervalThink()
	self:PlayEffects()
	local enemies = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),
		self:GetParent():GetOrigin(),
		nil,
		self.slow_radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		0,
		false
	)
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(
			caster,
			self,
			"modifier_razor_plasma_field_lua",
			{
				duration = 1,
				slow = self.slow,
			}
		)
	end
	local projectile_direction =  (self:GetParent():GetCursorPosition() + 5 - self:GetParent():GetAbsOrigin()):Normalized()
	projectile_direction.z = 0
	local arrow_projectile = {
		Ability				= self,
		EffectName			= "particles/pirat_r_axe.vpcf",
		vSpawnOrigin		= self:GetParent():GetAbsOrigin(),
		fDistance			= 600,
		fStartRadius		= 115,
		fEndRadius			= 120,
		Source				= self:GetParent(),
		bHasFrontalCone		= false,
		bReplaceExisting = false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		bDeleteOnHit		= true,
		vVelocity			= projectile_direction * 1500,
		bProvidesVision		= true,
		iVisionRadius		= 200,
		iVisionTeamNumber	= self:GetParent():GetTeamNumber(),
	}
	local xx = projectile_direction.x
	local yy = projectile_direction.y
	projectile_direction.x = xx * (2 ^ 0.5) / 2 - (yy * (2 ^ 0.5) / 2)
	projectile_direction.y = (xx * (2 ^ 0.5) / 2) + (yy * (2 ^ 0.5) / 2)
	local arrow_projectile_1 = {
		Ability				= self,
		EffectName			= "particles/pirat_r_axe.vpcf",
		vSpawnOrigin		= self:GetParent():GetAbsOrigin(),
		fDistance			= 600,
		fStartRadius		= 115,
		fEndRadius			= 120,
		Source				= self:GetParent(),
		bHasFrontalCone		= false,
		bReplaceExisting = false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		bDeleteOnHit		= true,
		vVelocity			= projectile_direction * 1500,
		bProvidesVision		= true,
		iVisionRadius		= 200,
		iVisionTeamNumber	= self:GetParent():GetTeamNumber(),
	}
	projectile_direction.x = xx * (2 ^ 0.5) / 2 + (yy * (2 ^ 0.5) / 2)
	projectile_direction.y = -(xx * (2 ^ 0.5) / 2) + (yy * (2 ^ 0.5) / 2)
	local arrow_projectile_2 = {
		Ability				= self,
		EffectName			= "particles/pirat_r_axe.vpcf",
		vSpawnOrigin		= self:GetParent():GetAbsOrigin(),
		fDistance			= 600,
		fStartRadius		= 115,
		fEndRadius			= 120,
		Source				= self:GetParent(),
		bHasFrontalCone		= false,
		bReplaceExisting = false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		bDeleteOnHit		= true,
		vVelocity			= projectile_direction * 1500,
		bProvidesVision		= true,
		iVisionRadius		= 200,
		iVisionTeamNumber	= self:GetParent():GetTeamNumber(),
	}
	projectile_direction.x = -xx * (2 ^ 0.5) / 2 - (yy * (2 ^ 0.5) / 2)
	projectile_direction.y = (xx * (2 ^ 0.5) / 2) - (yy * (2 ^ 0.5) / 2)
	local arrow_projectile_3 = {
		Ability				= self,
		EffectName			= "particles/pirat_r_axe.vpcf",
		vSpawnOrigin		= self:GetParent():GetAbsOrigin(),
		fDistance			= 600,
		fStartRadius		= 115,
		fEndRadius			= 120,
		Source				= self:GetParent(),
		bHasFrontalCone		= false,
		bReplaceExisting = false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		bDeleteOnHit		= true,
		vVelocity			= projectile_direction * 1500,
		bProvidesVision		= true,
		iVisionRadius		= 200,
		iVisionTeamNumber	= self:GetParent():GetTeamNumber(),
	}
	projectile_direction.x = -xx * (2 ^ 0.5) / 2 + (yy * (2 ^ 0.5) / 2)
	projectile_direction.y = -(xx * (2 ^ 0.5) / 2) - (yy * (2 ^ 0.5) / 2)
	local arrow_projectile_4 = {
		Ability				= self,
		EffectName			= "particles/pirat_r_axe.vpcf",
		vSpawnOrigin		= self:GetParent():GetAbsOrigin(),
		fDistance			= 600,
		fStartRadius		= 115,
		fEndRadius			= 120,
		Source				= self:GetParent(),
		bHasFrontalCone		= false,
		bReplaceExisting = false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		bDeleteOnHit		= true,
		vVelocity			= projectile_direction * 1500,
		bProvidesVision		= true,
		iVisionRadius		= 200,
		iVisionTeamNumber	= self:GetParent():GetTeamNumber(),
	}
	projectile_direction.x = -xx
	projectile_direction.y = -yy
	local arrow_projectile_5 = {
		Ability				= self,
		EffectName			= "particles/pirat_r_axe.vpcf",
		vSpawnOrigin		= self:GetParent():GetAbsOrigin(),
		fDistance			= 600,
		fStartRadius		= 115,
		fEndRadius			= 120,
		Source				= self:GetParent(),
		bHasFrontalCone		= false,
		bReplaceExisting = false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		bDeleteOnHit		= true,
		vVelocity			= projectile_direction * 1500,
		bProvidesVision		= true,
		iVisionRadius		= 200,
		iVisionTeamNumber	= self:GetParent():GetTeamNumber(),
	}
	projectile_direction.x = -yy
	projectile_direction.y = xx
	local arrow_projectile_6 = {
		Ability				= self,
		EffectName			= "particles/pirat_r_axe.vpcf",
		vSpawnOrigin		= self:GetParent():GetAbsOrigin(),
		fDistance			= 600,
		fStartRadius		= 115,
		fEndRadius			= 120,
		Source				= self:GetParent(),
		bHasFrontalCone		= false,
		bReplaceExisting = false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		bDeleteOnHit		= true,
		vVelocity			= projectile_direction * 1500,
		bProvidesVision		= true,
		iVisionRadius		= 200,
		iVisionTeamNumber	= self:GetParent():GetTeamNumber(),
	}
	projectile_direction.x = yy
	projectile_direction.y = -xx
	local arrow_projectile_7 = {
		Ability				= self,
		EffectName			= "particles/pirat_r_axe.vpcf",
		vSpawnOrigin		= self:GetParent():GetAbsOrigin(),
		fDistance			= 600,
		fStartRadius		= 115,
		fEndRadius			= 120,
		Source				= self:GetParent(),
		bHasFrontalCone		= false,
		bReplaceExisting = false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		bDeleteOnHit		= true,
		vVelocity			= projectile_direction * 1500,
		bProvidesVision		= true,
		iVisionRadius		= 200,
		iVisionTeamNumber	= self:GetParent():GetTeamNumber(),
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

function modifier_topor:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_topor:OnDestroy()
	if not IsServer() then return end
	if self:GetParent():GetUnitName() ~= "npc_dota_hero_rubick" then
		self:GetParent():SetAttackCapability( DOTA_UNIT_CAP_MELEE_ATTACK )
	end
end

function modifier_topor:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}
	return funcs
end
function modifier_topor:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
	}

	return state
end
function modifier_topor:GetModifierTotalDamageOutgoing_Percentage()
    return self.bonus_dmg
end
function modifier_topor:GetModifierBaseAttackTimeConstant()
	return self.bat
end

function modifier_topor:GetModifierMoveSpeedBonus_Percentage()
	return self.speed
end

function modifier_topor:GetModifierProjectileSpeedBonus()
	return self.projectile
end

function modifier_topor:GetModifierAttackRangeBonus()
	return self.range
end

function modifier_topor:GetModifierModelChange()
	return "models/heroes/troll_warlord/troll_warlord.vmdl"
end

function modifier_topor:GetModifierModelScale()
	return 30
end

function modifier_topor:GetModifierProjectileName()
	return "particles/pirat_r_attack.vpcf"
end

function modifier_topor:GetAttackSound()
	return "Hero_TrollWarlord.Attack"
end

function modifier_topor:GetModifierAttackSpeedBonus_Constant( params )
	return self.as
end
function modifier_topor:PlayEffects()
	local particle_cast = "particles/ti9_jungle_axe_attack_blur_counterhelix_new.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end