
chillzone = class({})
LinkLuaModifier( "modifier_chillzone_thinker", "heroes/chillguy/modifier_chillzone_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_chillzone_effect", "heroes/chillguy/modifier_chillzone_effect", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function chillzone:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function chillzone:GetCooldown( level )
	return self.BaseClass.GetCooldown( self, level )
end

--------------------------------------------------------------------------------
-- Ability Start
function chillzone:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- load data
	local duration = self:GetSpecialValueFor("duration")
	local vision = self:GetSpecialValueFor("vision_radius")

	-- create thinker
	self.thinker = CreateModifierThinker(
		caster, -- player source
		self, -- ability source
		"modifier_chillzone_thinker", -- modifier name
		{ duration = duration }, -- kv
		point,
		caster:GetTeamNumber(),
		false
	)
	self.thinker = self.thinker:FindModifierByName("modifier_chillzone_thinker")
	
	-- create fov
	AddFOWViewer( self:GetCaster():GetTeamNumber(), point, vision, duration, false)
end