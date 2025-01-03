serega_radiance = class({})
LinkLuaModifier( "modifier_serega_radiance", "heroes/pirat/modifier_serega_radiance", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_serega_radiance_debuff", "heroes/pirat/modifier_serega_radiance_debuff", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function serega_radiance:GetIntrinsicModifierName()
	return "modifier_serega_radiance"
end