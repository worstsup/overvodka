rivendare_lua = class({})
LinkLuaModifier( "modifier_rivendare_lua", "modifier_rivendare_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rivendare_lua_debuff", "modifier_rivendare_lua_debuff", LUA_MODIFIER_MOTION_NONE )

function rivendare_lua:GetIntrinsicModifierName()
	return "modifier_rivendare_lua"
end