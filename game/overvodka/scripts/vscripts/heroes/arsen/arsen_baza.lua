arsen_baza = class({})
LinkLuaModifier( "modifier_generic_orb_effect_lua", "modifier_generic_orb_effect_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_arsen_baza", "heroes/arsen/modifier_arsen_baza", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function arsen_baza:GetIntrinsicModifierName()
	return "modifier_generic_orb_effect_lua"
end

--------------------------------------------------------------------------------
-- Ability Start
function arsen_baza:OnSpellStart()
end

--------------------------------------------------------------------------------
-- Orb Effects
function arsen_baza:OnOrbImpact( params )
	-- get reference
	local duration = self:GetSpecialValueFor( "burn_duration" )
	local bash = self:GetSpecialValueFor( "ministun_duration" )
	local break_duration = self:GetSpecialValueFor( "break_duration" )
	-- add debuff
	params.target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_arsen_baza", -- modifier name
		{ duration = duration } -- kv
	)

	-- add ministun
	params.target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_generic_stunned_lua", -- modifier name
		{ duration = bash } -- kv
	)
	params.target:AddNewModifier(self:GetCaster(), self, "modifier_silver_edge_debuff", {duration = break_duration})
end