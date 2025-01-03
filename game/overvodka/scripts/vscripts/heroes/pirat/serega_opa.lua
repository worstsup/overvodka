serega_opa = class({})
LinkLuaModifier( "modifier_serega_opa", "heroes/pirat/modifier_serega_opa", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_silenced_lua", "modifier_generic_silenced_lua", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function serega_opa:GetIntrinsicModifierName()
	return "modifier_serega_opa"
end

--------------------------------------------------------------------------------
