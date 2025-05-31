sasavot_w = class({})
LinkLuaModifier( "modifier_sasavot_w", "heroes/sasavot/modifier_sasavot_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sasavot_w_stack", "heroes/sasavot/modifier_sasavot_w", LUA_MODIFIER_MOTION_NONE )

function sasavot_w:GetIntrinsicModifierName()
	return "modifier_sasavot_w"
end