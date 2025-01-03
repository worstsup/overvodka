litvin_zhishi = class({})
LinkLuaModifier( "modifier_dark_seer_vacuum_lit", "heroes/litvin/modifier_dark_seer_vacuum_lit", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_litvin_enrage", "heroes/litvin/modifier_litvin_enrage", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_litvin_litenergy", "heroes/litvin/modifier_litvin_litenergy", LUA_MODIFIER_MOTION_NONE )

function litvin_zhishi:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dark_seer.vsndevts", context )
	PrecacheResource( "particle", "particles/dark_seer_vacuum_new.vpcf", context )
end

function litvin_zhishi:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end
--------------------------------------------------------------------------------
function litvin_zhishi:OnAbilityPhaseStart()
	local point = self:GetCursorPosition()

	local sound_cast = "zhishi_start"
	EmitSoundOnLocationWithCaster( point, sound_cast, self:GetCaster() )

	return true -- if success
end
-- Ability Start
function litvin_zhishi:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local origin = caster:GetOrigin()
	local lit_dur = self:GetSpecialValueFor("lit_dur")
	-- load data
	local max_range = self:GetSpecialValueFor("blink_range")
	local radius = self:GetSpecialValueFor( "radius" )
	local tree = self:GetSpecialValueFor( "radius_tree" )
	local duration = self:GetSpecialValueFor( "duration" )
	local buff_dur = self:GetSpecialValueFor( "buff_dur" )
	-- determine target position
	local direction = (point - origin)
	if direction:Length2D() > max_range then
		direction = direction:Normalized() * max_range
	end
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		point,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		-- add modifier
		enemy:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_dark_seer_vacuum_lit", -- modifier name
			{
				duration = duration,
				x = point.x,
				y = point.y,
			} -- kv
		)
	end
	GridNav:DestroyTreesAroundPoint( point, tree, false )

	-- teleport
	-- caster:SetOrigin( origin + direction )
	FindClearSpaceForUnit( caster, origin + direction, true )
	self:GetCaster():AddNewModifier(
		self:GetCaster(),
		self,
		"modifier_litvin_enrage",
		{ duration = buff_dur }
	)
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_litvin_litenergy", { duration = self:GetSpecialValueFor( "lit_dur" ) } )
	end
	-- Play effects
	self:PlayEffects( origin, direction, point, radius )
end

--------------------------------------------------------------------------------
function litvin_zhishi:PlayEffects( origin, direction, point, radius )
	-- Get Resources
	local particle_cast_a = "particles/units/heroes/hero_queenofpain/queen_blink_start.vpcf"
	local particle_cast_b = "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf"

	-- At original position
	local effect_cast_a = ParticleManager:CreateParticle( particle_cast_a, PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast_a, 0, origin )
	ParticleManager:SetParticleControlForward( effect_cast_a, 0, direction:Normalized() )
	ParticleManager:SetParticleControl( effect_cast_a, 1, origin + direction )
	ParticleManager:ReleaseParticleIndex( effect_cast_a )

	-- At original position
	local effect_cast_b = ParticleManager:CreateParticle( particle_cast_b, PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast_b, 0, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast_b, 0, direction:Normalized() )
	ParticleManager:ReleaseParticleIndex( effect_cast_b )
	local particle_cast = "particles/dark_seer_vacuum_new.vpcf"
	local sound_cast = "zhishi"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOnLocationWithCaster( point, sound_cast, self:GetCaster() )
end
