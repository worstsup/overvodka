LinkLuaModifier("modifier_kachok_attribute_gain", "heroes/kachok/modifier_kachok_attribute_gain", LUA_MODIFIER_MOTION_NONE)

kachok_e = class({})

function kachok_e:GetIntrinsicModifierName()
    return "modifier_kachok_attribute_gain"
end

function kachok_e:GetAttributeGain()
    return self:GetSpecialValueFor("bonus_attribute")
end