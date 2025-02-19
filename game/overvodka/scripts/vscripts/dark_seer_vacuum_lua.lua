dark_seer_vacuum_lua = class({})
LinkLuaModifier( "modifier_dark_seer_vacuum_lua", "modifier_dark_seer_vacuum_lua", LUA_MODIFIER_MOTION_HORIZONTAL )

function dark_seer_vacuum_lua:Precache( context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dark_seer/dark_seer_vacuum.vpcf", context )
end

--------------------------------------------------------------------------------
function dark_seer_vacuum_lua:GetAOERadius()
	local base_radius = self:GetSpecialValueFor("radius")
    if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
        local orb_ability = self:GetCaster():FindAbilityByName("dvoreckov_w")
        if orb_ability then
            return base_radius + (orb_ability:GetLevel() * 60)
        end
    end
    
    return 700
end

function dark_seer_vacuum_lua:GetCooldown( level )

	return self.BaseClass.GetCooldown( self, level )
end

--------------------------------------------------------------------------------
-- Ability Start
function dark_seer_vacuum_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- load data
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		radius = self:GetOrbSpecialValueFor( "radius", "w" )
	else
		radius = 700
	end
	local tree = self:GetSpecialValueFor( "radius_tree" )
	local duration = self:GetSpecialValueFor( "duration" )

	-- find units
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
			"modifier_dark_seer_vacuum_lua", -- modifier name
			{
				duration = duration,
				x = point.x,
				y = point.y,
			} -- kv
		)
	end

	-- destroy trees
	GridNav:DestroyTreesAroundPoint( point, tree, false )

	-- play effects
	self:PlayEffects( point, radius )
end

--------------------------------------------------------------------------------
function dark_seer_vacuum_lua:PlayEffects( point, radius )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_dark_seer/dark_seer_vacuum.vpcf"
	local sound_cast = "unitazik"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOnLocationWithCaster( point, sound_cast, self:GetCaster() )
end