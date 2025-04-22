golovach_innate = class({})
LinkLuaModifier( "modifier_golovach_innate", "heroes/golovach/modifier_golovach_innate", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_golovach_innate_facet_bonus", "heroes/golovach/modifier_golovach_innate", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_golovach_innate_debuff", "heroes/golovach/modifier_golovach_innate_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_arc_lua", "modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_silenced_lua", "modifier_generic_silenced_lua", LUA_MODIFIER_MOTION_BOTH )

function golovach_innate:GetIntrinsicModifierName()
	return "modifier_golovach_innate"
end

function golovach_innate:IsRefreshable()
	return false 
end