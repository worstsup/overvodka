stariy_bolt = class({})
LinkLuaModifier( "modifier_stariy_bolt", "heroes/stariy/modifier_stariy_bolt", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stariy_bolt_debuff", "heroes/stariy/modifier_stariy_bolt_debuff", LUA_MODIFIER_MOTION_NONE )

function stariy_bolt:GetIntrinsicModifierName()
	return "modifier_stariy_bolt"
end