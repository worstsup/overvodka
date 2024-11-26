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
mars_gods_rebuke_lua = class({})
LinkLuaModifier( "modifier_mars_gods_rebuke_lua", "modifier_mars_gods_rebuke_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zolo_disarm", "modifier_zolo_disarm", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_knockback_lua", "modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH )

--------------------------------------------------------------------------------
-- Ability Start
function mars_gods_rebuke_lua:OnAbilityPhaseStart()
	self:PlayEffects3()
end

function mars_gods_rebuke_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = caster:GetOrigin()

	-- load data
	local radius = self:GetSpecialValueFor("radius")
	local disarm_duration = self:GetSpecialValueFor( "disarm_duration" )
	local angle = self:GetSpecialValueFor("angle")/2
	local duration = self:GetSpecialValueFor("knockback_duration")
	local distance = self:GetSpecialValueFor("knockback_distance")

	-- find units
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

	-- add buff modifier
	local buff = caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_mars_gods_rebuke_lua", -- modifier name
		{  } -- kv
	)
	-- precache
	local origin = caster:GetOrigin()
	local cast_direction = (point-origin+Vector(50,50,0)):Normalized()
	local cast_angle = VectorToAngles( cast_direction ).y
	-- for each units
	local caught = false
	for _,enemy in pairs(enemies) do
		-- check within cast angle
		enemy:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_zolo_disarm", -- modifier name
			{duration = disarm_duration} -- kv
		)
		local enemy_direction = (enemy:GetOrigin() - origin):Normalized()
		local enemy_angle = VectorToAngles( enemy_direction ).y
		local angle_diff = math.abs( AngleDiff( cast_angle, enemy_angle ) )
		if angle_diff<=angle then
			-- attack
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
				caster, -- player source
				self, -- ability source
				"modifier_generic_knockback_lua", -- modifier name
				{
					duration = duration,
					distance = distance,
					height = 30,
					direction_x = enemy_direction.x,
					direction_y = enemy_direction.y,
				} -- kv
			)
			caught = true
			-- play effects
			self:PlayEffects2( enemy, origin, cast_direction )
		end
	end

	-- destroy buff modifier
	buff:Destroy()

	-- play effects
	self:PlayEffects1( caught, (point-origin):Normalized() )
end

--------------------------------------------------------------------------------
-- Play Effects
function mars_gods_rebuke_lua:PlayEffects1( caught, direction )
	-- Get Resources
	local particle_cast = "particles/huskar_inner_fire_new.vpcf"
	local sound_cast = "zolo_zver"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 0, direction )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), sound_cast, self:GetCaster() )
end

function mars_gods_rebuke_lua:PlayEffects2( target, origin, direction )
	-- Get Resources
	local particle_cast = "particles/mars_shield_bash_crit_new.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, target )
	ParticleManager:SetParticleControl( effect_cast, 0, target:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 1, direction )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function mars_gods_rebuke_lua:PlayEffects3()
	-- Get Resources
	local particle_cast = "particles/primal_beast_2022_prestige_onslaught_chargeup_new.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	EmitSoundOn( "zolo_zver_start", self:GetCaster() )
end