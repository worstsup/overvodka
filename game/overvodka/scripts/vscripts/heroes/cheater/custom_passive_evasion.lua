LinkLuaModifier("modifier_custom_evasion", "heroes/cheater/modifier_custom_evasion.lua", LUA_MODIFIER_MOTION_NONE)

custom_passive_evasion = class({})

function custom_passive_evasion:GetIntrinsicModifierName()
    return "modifier_custom_evasion"
end