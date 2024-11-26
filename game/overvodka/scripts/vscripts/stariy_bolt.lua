stariy_bolt = class({})
LinkLuaModifier( "modifier_stariy_bolt", "modifier_stariy_bolt", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stariy_bolt_debuff", "modifier_stariy_bolt_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function stariy_bolt:GetIntrinsicModifierName()
	return "modifier_stariy_bolt"
end