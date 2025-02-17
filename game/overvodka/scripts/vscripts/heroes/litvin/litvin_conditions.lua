litvin_conditions = class({})
LinkLuaModifier( "modifier_litvin_conditions", "heroes/litvin/modifier_litvin_conditions", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_generic_arc_lua", "modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function litvin_conditions:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------
-- Ability Cast Filter
function litvin_conditions:CastFilterResultTarget( hTarget )
	if self:GetCaster() == hTarget then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function litvin_conditions:GetCustomCastErrorTarget( hTarget )
	if self:GetCaster() == hTarget then
		return "#dota_hud_error_cant_cast_on_self"
	end

	return "#dota_hud_error_nothing_to_toss"
end


--------------------------------------------------------------------------------
-- Ability Start
function litvin_conditions:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(self) then return end
	-- local point = self:GetCursorPosition()

	-- add modifier
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_litvin_conditions", -- modifier name
		{
			target = target:entindex(),
		} -- kv
	)

end