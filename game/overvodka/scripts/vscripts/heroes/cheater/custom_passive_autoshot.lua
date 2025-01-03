LinkLuaModifier("modifier_custom_passive_autoshot", "heroes/cheater/modifier_custom_passive_autoshot", LUA_MODIFIER_MOTION_NONE)

custom_passive_autoshot = class({})

function custom_passive_autoshot:GetIntrinsicModifierName()
    return "modifier_custom_passive_autoshot"
end