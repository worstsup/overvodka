
--------------------------------------------------------------------------------
hamster = class({})
LinkLuaModifier( "modifier_hamster", "modifier_hamster", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function hamster:GetIntrinsicModifierName()
	return "modifier_hamster"
end