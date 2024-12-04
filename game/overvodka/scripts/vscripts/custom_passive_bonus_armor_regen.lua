LinkLuaModifier("modifier_custom_passive_bonus_armor_regen", "modifier_custom_passive_bonus_armor_regen.lua", LUA_MODIFIER_MOTION_NONE)

custom_passive_bonus_armor_regen = class({})

function custom_passive_bonus_armor_regen:GetIntrinsicModifierName()
    return "modifier_custom_passive_bonus_armor_regen"
end