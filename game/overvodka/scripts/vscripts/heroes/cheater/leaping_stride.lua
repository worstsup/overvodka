LinkLuaModifier("modifier_leaping_stride", "heroes/cheater/modifier_leaping_stride.lua", LUA_MODIFIER_MOTION_NONE)

leaping_stride = class({})

function leaping_stride:GetIntrinsicModifierName()
    return "modifier_leaping_stride"
end