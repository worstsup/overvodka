batya_radiance = class({})
LinkLuaModifier( "modifier_batya_radiance", "heroes/zolo/modifier_batya_radiance", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_batya_radiance_debuff", "heroes/zolo/modifier_batya_radiance_debuff", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function batya_radiance:GetIntrinsicModifierName()
	return "modifier_batya_radiance"
end