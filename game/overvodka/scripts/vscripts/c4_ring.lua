c4_ring = class({})
LinkLuaModifier( "modifier_c4_ring", "modifier_c4_ring", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function c4_ring:GetIntrinsicModifierName()
	return "modifier_c4_ring"
end