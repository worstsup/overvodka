LinkLuaModifier("modifier_kachok_abstention", "heroes/kachok/modifier_kachok_abstention", LUA_MODIFIER_MOTION_NONE)

kachok_abstention = class({})

function kachok_abstention:GetIntrinsicModifierName()
    return "modifier_kachok_abstention"
end

function kachok_abstention:GetAttributeGain()
    return self:GetSpecialValueFor("bonus_attribute")
end