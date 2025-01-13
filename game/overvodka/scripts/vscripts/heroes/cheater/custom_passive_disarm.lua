LinkLuaModifier("modifier_custom_passive_disarm", "heroes/cheater/modifier_custom_passive_disarm.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)

custom_passive_disarm = class({})

function custom_passive_disarm:GetIntrinsicModifierName()
    return "modifier_custom_passive_disarm"
end