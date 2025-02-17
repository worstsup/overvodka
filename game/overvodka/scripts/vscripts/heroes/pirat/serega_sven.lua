serega_sven = class({})
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_knockback_lua", "modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_serega_sven", "heroes/pirat/modifier_serega_sven", LUA_MODIFIER_MOTION_NONE )
tartar = {}

--------------------------------------------------------------------------------
-- Ability Start
function serega_sven:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local point = self:GetCursorPosition()
	tartar = {}
	-- load data
	if target then
		point = target:GetOrigin()
	end

	local projectile_name = "particles/econ/items/nyx_assassin/nyx_assassin_ti6/nyx_assassin_impale_ti6.vpcf"
	local projectile_distance = self:GetCastRange( point, target )
	local projectile_radius = self:GetSpecialValueFor( "width" )
	local projectile_speed = self:GetSpecialValueFor( "speed" )
	local projectile_direction = (point-caster:GetOrigin()):Normalized()
	if target:IsRealHero() then
		target:AddNewModifier(
			self:GetCaster(), -- player source
			self, -- ability source
			"modifier_serega_sven", -- modifier name
			{ duration = 3 } -- kv
		)
	end
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
	    fStartRadius = projectile_radius,
	    fEndRadius = projectile_radius,
		vVelocity = projectile_direction * projectile_speed,
	}
	ProjectileManager:CreateLinearProjectile(info)
	local xx = projectile_direction.x
	local yy = projectile_direction.y
	projectile_direction.x = xx * (3 ^ 0.5) / 2 - (yy / 2)
	projectile_direction.y = (xx / 2) + (yy * (3 ^ 0.5) / 2)
	info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = projectile_radius,
	    fEndRadius = projectile_radius,
		vVelocity = projectile_direction * projectile_speed,
	}
	ProjectileManager:CreateLinearProjectile(info)
	info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = projectile_radius,
	    fEndRadius = projectile_radius,
		vVelocity = projectile_direction * projectile_speed,
	}
	projectile_direction.x = xx * (3 ^ 0.5) / 2 + (yy / 2)
	projectile_direction.y = -(xx / 2) + (yy * (3 ^ 0.5) / 2)
	info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = projectile_radius,
	    fEndRadius = projectile_radius,
		vVelocity = projectile_direction * projectile_speed,
	}
	ProjectileManager:CreateLinearProjectile(info)
	-- play effects
	local sound_cast = "serega_sven"
	EmitSoundOn( sound_cast, caster )
end

--------------------------------------------------------------------------------
-- Projectile
function serega_sven:OnProjectileHit( target, location )
	if not target then return end
	for _,v in ipairs(tartar) do  
		if v == target then return end
	end
	if target:TriggerSpellAbsorb( self ) then return end

	local stun = self:GetSpecialValueFor( "duration" )
	local damage = self:GetAbilityDamage()

	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
	}

	-- stun
	target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_generic_stunned_lua", -- modifier name
		{ duration = stun } -- kv
	)

	-- knockback
	local knockback = target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_knockback",
			{
				center_x = 0,
				center_y = 0,
				center_z = 0,
				duration = 0.5,
				knockback_duration = 0.5,
				knockback_distance = 0,
				knockback_height = 350
			}
	)
	local callback = function()
		-- damage on landed
		local damageTable = {
			victim = target,
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self, --Optional.
		}
		ApplyDamage(damageTable)

		-- play effects
		local sound_cast = "Hero_Lion.ImpaleTargetLand"
		EmitSoundOn( sound_cast, target )
	end
	knockback:SetEndCallback( callback )
	table.insert(tartar, target)
	-- play effects
	self:PlayEffects( target )
end

--------------------------------------------------------------------------------
function serega_sven:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/econ/items/nyx_assassin/nyx_assassin_ti6/nyx_assassin_impale_hit_ti6.vpcf"
	local sound_cast = "Hero_Lion.ImpaleHitTarget"

	-- Get Data

	-- -- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, target )
end