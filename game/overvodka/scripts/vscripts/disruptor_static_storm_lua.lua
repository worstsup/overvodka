disruptor_static_storm_lua = class({})
LinkLuaModifier( "modifier_disruptor_static_storm_lua", "modifier_disruptor_static_storm_lua.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function disruptor_static_storm_lua:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------
-- Ability Start
function disruptor_static_storm_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- create thinker
	CreateModifierThinker(
		caster, -- player source
		self, -- ability source
		"modifier_disruptor_static_storm_lua", -- modifier name
		{}, -- kv
		point,
		caster:GetTeamNumber(),
		false
	)

	-- effects
	local sound_cast_2 = "komp"
	EmitSoundOn( sound_cast_2, caster )
end