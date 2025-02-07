modifier_topor = class({})
--------------------------------------------------------------------------------
function modifier_topor:IsPurgable()
	return false
end

function modifier_topor:OnCreated( kv )
	self.as = 1000
	self.bat = self:GetAbility():GetSpecialValueFor( "bat" )
	self.speed = self:GetAbility():GetSpecialValueFor( "bonus_speed" )
	self.projectile = 900
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_dmg" )
	self.range = self:GetAbility():GetSpecialValueFor( "range" )
	self.attack = self:GetParent():GetAttackCapability()
	if self.attack == DOTA_UNIT_CAP_RANGED_ATTACK then
		-- no bonus for originally ranged enemies
		self.range = 0
		self.projectile = 0
	end
	self.slow = self:GetAbility():GetSpecialValueFor( "slow_max" )
	self.slow_radius = self:GetAbility():GetSpecialValueFor( "slow_radius" )
	self:GetParent():SetAttackCapability( DOTA_UNIT_CAP_RANGED_ATTACK )
	self:StartIntervalThink( 0.4 )
	self:OnIntervalThink()
end

--------------------------------------------------------------------------------
function modifier_topor:OnIntervalThink()
	self:PlayEffects()
	local enemies = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.slow_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_razor_plasma_field_lua", -- modifier name
			{
				duration = 1,
				slow = self.slow,
			} -- kv
		)
	end
	local projectile_direction =  (self:GetParent():GetCursorPosition() + 5 - self:GetParent():GetAbsOrigin()):Normalized()
	local arrow_projectile = {
		Ability				= self,
		EffectName			= "particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_ranged.vpcf",
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
		EffectName			= "particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_ranged.vpcf",
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
		EffectName			= "particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_ranged.vpcf",
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
		EffectName			= "particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_ranged.vpcf",
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
		EffectName			= "particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_ranged.vpcf",
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
		EffectName			= "particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_ranged.vpcf",
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
		EffectName			= "particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_ranged.vpcf",
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
		EffectName			= "particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_ranged.vpcf",
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

function modifier_topor:OnRemoved()
	
end
function modifier_topor:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_topor:OnRemoved()
end

function modifier_topor:OnDestroy()
	if not IsServer() then return end
	self:GetParent():SetAttackCapability( self.attack )
end

--------------------------------------------------------------------------------

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
	return "particles/units/heroes/hero_troll_warlord/troll_warlord_base_attack.vpcf"
end

function modifier_topor:GetAttackSound()
	return "Hero_TrollWarlord.Attack"
end
--------------------------------------------------------------------------------

function modifier_topor:GetModifierAttackSpeedBonus_Constant( params )
	return self.as
end
function modifier_topor:PlayEffects()
	local particle_cast = "particles/ti9_jungle_axe_attack_blur_counterhelix_new.vpcf"
	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end