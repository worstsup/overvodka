drow_ranger_gust_lua = class({})
LinkLuaModifier( "modifier_generic_knockback_lua", "modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_silenced_lua", "modifier_generic_silenced_lua.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_muted_lua", "modifier_generic_muted_lua.lua", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
-- Ability Start
function drow_ranger_gust_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition() + Vector(2, 2, 0)

	-- load data
	local speed = self:GetSpecialValueFor( "wave_speed" )
	local width = self:GetSpecialValueFor( "wave_width" )

	-- create projectile
	local projectile_name = "particles/econ/items/drow/drow_arcana/drow_arcana_silence_wave.vpcf"
	local projectile_distance = self:GetCastRange( point, nil )
	local projectile_direction = point-caster:GetOrigin()
	projectile_direction.z = 0
	projectile_direction = projectile_direction:Normalized()
	local xx = projectile_direction.x
	local yy = projectile_direction.y
	tartar = {}
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = width,
	    fEndRadius = width,
		vVelocity = projectile_direction * speed,
		
		ExtraData = {
			x = caster:GetOrigin().x,
			y = caster:GetOrigin().y,
		}
	}
	local info2 = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = width,
	    fEndRadius = width,
		vVelocity = -projectile_direction * speed,
		
		ExtraData = {
			x = caster:GetOrigin().x,
			y = caster:GetOrigin().y,
		}
	}
	local zam = projectile_direction.x
	projectile_direction.x = -projectile_direction.y
	projectile_direction.y = zam
	local info3 = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = width,
	    fEndRadius = width,
		vVelocity = projectile_direction  * speed,
		
		ExtraData = {
			x = caster:GetOrigin().x,
			y = caster:GetOrigin().y,
		}
	}
	projectile_direction.x = -projectile_direction.x
	projectile_direction.y = -projectile_direction.y
	local info4 = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = width,
	    fEndRadius = width,
		vVelocity = projectile_direction  * speed,
		
		ExtraData = {
			x = caster:GetOrigin().x,
			y = caster:GetOrigin().y,
		}
	}
	projectile_direction.x = xx * (2 ^ 0.5) / 2 - yy * (2 ^ 0.5) / 2
	projectile_direction.y = xx * (2 ^ 0.5) / 2 + yy * (2 ^ 0.5) / 2

	local info5 = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = width,
	    fEndRadius = width,
		vVelocity = projectile_direction  * speed,
		
		ExtraData = {
			x = caster:GetOrigin().x,
			y = caster:GetOrigin().y,
		}
	}
	local info6 = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = width,
	    fEndRadius = width,
		vVelocity = -projectile_direction  * speed,
		
		ExtraData = {
			x = caster:GetOrigin().x,
			y = caster:GetOrigin().y,
		}
	}
	local zamzam = projectile_direction.x
	projectile_direction.x = -projectile_direction.y
	projectile_direction.y = zamzam
	local info7 = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = width,
	    fEndRadius = width,
		vVelocity = projectile_direction  * speed,
		
		ExtraData = {
			x = caster:GetOrigin().x,
			y = caster:GetOrigin().y,
		}
	}
	local info8 = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = width,
	    fEndRadius = width,
		vVelocity = -projectile_direction  * speed,
		
		ExtraData = {
			x = caster:GetOrigin().x,
			y = caster:GetOrigin().y,
		}
	}
	ProjectileManager:CreateLinearProjectile(info)
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
			local Talented = self:GetCaster():FindAbilityByName("special_bonus_unique_oracle_2")
			if Talented:GetLevel() == 1 then
        		ProjectileManager:CreateLinearProjectile(info2)
				ProjectileManager:CreateLinearProjectile(info3)
				ProjectileManager:CreateLinearProjectile(info4)
				ProjectileManager:CreateLinearProjectile(info5)
				ProjectileManager:CreateLinearProjectile(info6)
				ProjectileManager:CreateLinearProjectile(info7)
				ProjectileManager:CreateLinearProjectile(info8)
    		end
    	end

	-- play effects
	local sound_cast = "ebalo"
	EmitSoundOn( sound_cast, caster )
end
tartar = {}
--------------------------------------------------------------------------------
-- Projectile
function drow_ranger_gust_lua:OnProjectileHit_ExtraData( target, location, data )
	for _,v in ipairs(tartar) do  
		if v == target then return end
	end
	if not target then return end

	-- get value
	local silence = 0
	local damage = 0
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		silence = self:GetOrbSpecialValueFor( "silence_duration", "q" )
		damage = self:GetOrbSpecialValueFor( "damage", "e" )
	else
		silence = 3.0
		damage = 400
	end
	local duration = self:GetSpecialValueFor( "knockback_duration" )
	local max_dist = self:GetSpecialValueFor( "knockback_distance_max" )

	-- calculate distance & direction
	local vec = target:GetOrigin()-Vector(data.x,data.y,0)
	vec.z = 0
	local distance = vec:Length2D()
	distance = (1-distance/self:GetCastRange( Vector(0,0,0), nil ))*max_dist
	if max_dist<0 then distance = 0 end
	vec = vec:Normalized()
	-- apply knockback
	target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_generic_knockback_lua", -- modifier name
		{
			duration = duration,
			distance = distance,
			direction_x = vec.x,
			direction_y = vec.y,
		} -- kv
	)
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		local Talented = self:GetCaster():FindAbilityByName("special_bonus_unique_pudge_7")
		if Talented:GetLevel() == 1 then
        	target:AddNewModifier(
				self:GetCaster(), -- player source
				self, -- ability source
				"modifier_generic_muted_lua", -- modifier name
				{ duration = silence } -- kv
			)
    	end
	end
	-- apply silence
	target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_generic_silenced_lua", -- modifier name
		{ duration = silence } -- kv
	)
	ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
	table.insert(tartar, target)
	-- play effects
	self:PlayEffects( target )
end

--------------------------------------------------------------------------------
function drow_ranger_gust_lua:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/econ/items/drow/drow_arcana/drow_arcana_silence_impact_dust.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end