LinkLuaModifier("modifier_custom_passive_disarm", "modifier_custom_passive_disarm.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_disarmed_lua", "modifier_generic_disarmed_lua", LUA_MODIFIER_MOTION_NONE)

custom_passive_disarm = class({})

-- Intrinsic modifier for the passive ability
function custom_passive_disarm:GetIntrinsicModifierName()
    return "modifier_custom_passive_disarm"
end