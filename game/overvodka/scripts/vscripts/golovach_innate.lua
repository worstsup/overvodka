golovach_innate = class({})
LinkLuaModifier( "modifier_golovach_innate", "modifier_golovach_innate", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_golovach_innate_debuff", "modifier_golovach_innate_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_arc_lua", "modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_silenced_lua", "modifier_generic_silenced_lua", LUA_MODIFIER_MOTION_BOTH )
--------------------------------------------------------------------------------
-- Passive Modifier
function golovach_innate:GetIntrinsicModifierName()
	return "modifier_golovach_innate"
end