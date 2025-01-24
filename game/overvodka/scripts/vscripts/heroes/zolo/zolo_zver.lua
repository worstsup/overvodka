zolo_zver = class({})
LinkLuaModifier( "modifier_zolo_zver", "heroes/zolo/modifier_zolo_zver", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zolo_disarm", "heroes/zolo/modifier_zolo_disarm", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_knockback_lua", "modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH )

--------------------------------------------------------------------------------
function zolo_zver:OnAbilityPhaseStart()
	self:PlayEffects3()
end

function zolo_zver:OnAbilityPhaseInterrupted()
	self:StopEffects3()
end

function zolo_zver:OnSpellStart()
	local caster = self:GetCaster()
	local point = caster:GetOrigin()
	local radius = self:GetSpecialValueFor("radius")
	local disarm_duration = self:GetSpecialValueFor( "disarm_duration" )
	local angle = self:GetSpecialValueFor("angle")/2
	local duration = self:GetSpecialValueFor("knockback_duration")
	local distance = self:GetSpecialValueFor("knockback_distance")
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	local buff = caster:AddNewModifier(
		caster, 
		self, 
		"modifier_zolo_zver", 
		{  }
	)
	local origin = caster:GetOrigin()
	local cast_direction = (point-origin+Vector(50,50,0)):Normalized()
	local cast_angle = VectorToAngles( cast_direction ).y
	local caught = false
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(
			caster, 
			self, 
			"modifier_zolo_disarm", 
			{duration = disarm_duration}
		)
		local enemy_direction = (enemy:GetOrigin() - origin):Normalized()
		local enemy_angle = VectorToAngles( enemy_direction ).y
		local angle_diff = math.abs( AngleDiff( cast_angle, enemy_angle ) )
		if angle_diff<=angle then
			caster:PerformAttack(
				enemy,
				true,
				true,
				true,
				true,
				true,
				false,
				true
			)
			enemy:AddNewModifier(
				caster, 
				self, 
				"modifier_generic_knockback_lua", 
				{
					duration = duration,
					distance = distance,
					height = 30,
					direction_x = enemy_direction.x,
					direction_y = enemy_direction.y,
				}
			)
			caught = true
			self:PlayEffects2( enemy, origin, cast_direction )
		end
	end

	buff:Destroy()

	self:PlayEffects1( caught, (point-origin):Normalized() )
end

function zolo_zver:PlayEffects1( caught, direction )
	local particle_cast = "particles/huskar_inner_fire_new.vpcf"
	local sound_cast = "zolo_zver"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 0, direction )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), sound_cast, self:GetCaster() )
end

function zolo_zver:PlayEffects2( target, origin, direction )
	local particle_cast = "particles/mars_shield_bash_crit_new.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, target )
	ParticleManager:SetParticleControl( effect_cast, 0, target:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 1, direction )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function zolo_zver:PlayEffects3()
	self.effect_cast = ParticleManager:CreateParticle( "particles/primal_beast_2022_prestige_onslaught_chargeup_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	EmitSoundOn( "zolo_zver_start", self:GetCaster() )
end

function zolo_zver:StopEffects3()
	if self.effect_cast then
		ParticleManager:DestroyParticle(self.effect_cast, false)
		ParticleManager:ReleaseParticleIndex(self.effect_cast)
		self.effect_cast = nil
	end
	StopSoundOn( "zolo_zver_start", self:GetCaster() )
end