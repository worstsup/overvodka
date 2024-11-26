LinkLuaModifier("modifier_leaping_stride", "modifier_leaping_stride.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_motion", "modifier_generic_motion.lua", LUA_MODIFIER_MOTION_BOTH)

leaping_stride = class({})

function leaping_stride:GetIntrinsicModifierName()
    return "modifier_leaping_stride"
end