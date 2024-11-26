enchantress_untouchable_lua = class({})
LinkLuaModifier( "modifier_enchantress_untouchable_lua", "modifier_enchantress_untouchable_lua.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_enchantress_untouchable_lua_debuff", "modifier_enchantress_untouchable_lua_debuff.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function enchantress_untouchable_lua:GetIntrinsicModifierName()
	return "modifier_enchantress_untouchable_lua"
end