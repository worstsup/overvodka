golovach_q = class({})
LinkLuaModifier( "modifier_golovach_q", "modifier_golovach_q", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function golovach_q:GetIntrinsicModifierName()
	return "modifier_golovach_q"
end