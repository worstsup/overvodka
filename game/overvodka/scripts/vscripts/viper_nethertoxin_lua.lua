-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
viper_nethertoxin_lua = class({})
LinkLuaModifier( "modifier_viper_nethertoxin_lua", "modifier_viper_nethertoxin_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function viper_nethertoxin_lua:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------
-- Ability Start
function viper_nethertoxin_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = caster:GetAbsOrigin()
	local targets = FindUnitsInRadius(caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		1200,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_CLOSEST,
		false)
	for _,unit in pairs(targets) do
		point = unit:GetAbsOrigin()
		break
	end
	local vector = point-caster:GetOrigin()

	-- load data
	local projectile_name = ""
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
	local projectile_distance = vector:Length2D()
	local projectile_direction = vector
	projectile_direction.z = 0
	projectile_direction = projectile_direction:Normalized()

	-- create projectile
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_NONE,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = 0,
	    fEndRadius = 0,
		vVelocity = projectile_direction * projectile_speed,
	}
	ProjectileManager:CreateLinearProjectile(info)

	-- play effects
	Chance = RandomInt(1,2)
	if Chance == 1 then
		self:PlayEffects( point )
	elseif Chance == 2 then
		self:PlayEffects2( point )
	end
end
--------------------------------------------------------------------------------
-- Projectile
function viper_nethertoxin_lua:OnProjectileHit( target, location )
	-- should be no target
	if target then return false end
	-- references
	if Chance == 1 then
		local duration = self:GetSpecialValueFor( "duration" )

		-- create thinker
		CreateModifierThinker(
			self:GetCaster(), -- player source
			self, -- ability source
			"modifier_viper_nethertoxin_lua", -- modifier name
			{ duration = duration }, -- kv
			location,
			self:GetCaster():GetTeamNumber(),
			false
		)
	elseif Chance == 2 then
		local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
			location,
			nil,
			self:GetSpecialValueFor( "radius" ),
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false)
		for _,unit in pairs(targets) do
			ApplyDamage({victim = unit, attacker = self:GetCaster(), damage = self:GetSpecialValueFor( "damage_exp" ), damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
		end
		 EmitSoundOnLocationWithCaster(location, "grenade_explosion", self:GetCaster())
		 self:PlayEffects3( location )
	end

end

------------------------------------------------------------------------------
function viper_nethertoxin_lua:PlayEffects( point )
	-- Get Resources
	local particle_cast = "particles/viper_immortal_ti8_nethertoxin_proj_new.vpcf"
	local sound_cast = "molotov_throw"

	-- Get Data
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( projectile_speed, 0, 0 ) )
	ParticleManager:SetParticleControl( effect_cast, 5, point )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
end

function viper_nethertoxin_lua:PlayEffects2( point )
	-- Get Resources
	local particle_cast = "particles/grenade_proj.vpcf"
	local sound_cast = "grenade_throw"

	-- Get Data
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( projectile_speed, 0, 0 ) )
	ParticleManager:SetParticleControl( effect_cast, 5, point )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
end
function viper_nethertoxin_lua:PlayEffects3( point )
    -- Get Resources
    local particle_cast = "particles/grenade_explosion.vpcf"

    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:ReleaseParticleIndex( effect_cast )

    -- Release Particle
    ParticleManager:ReleaseParticleIndex(effect_cast)
end