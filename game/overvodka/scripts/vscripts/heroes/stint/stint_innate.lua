LinkLuaModifier("modifier_stint_innate", "heroes/stint/stint_innate.lua", LUA_MODIFIER_MOTION_NONE)

stint_innate = class({})

function stint_innate:GetIntrinsicModifierName()
    return "modifier_stint_innate"
end

modifier_stint_innate = class({})

function modifier_stint_innate:IsHidden()
    return true
end

function modifier_stint_innate:IsPurgable()
    return false
end

function modifier_stint_innate:RemoveOnDeath()
    return false
end

function modifier_stint_innate:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
    }
    return funcs
end

function modifier_stint_innate:GetModifierPercentageCooldown()
    if not self:GetAbility() then return 0 end
    if self:GetCaster():PassivesDisabled() then return 0 end
    local str_pct = self:GetAbility():GetSpecialValueFor("str_pct")
    local strength = self:GetCaster():GetStrength()
    return str_pct * strength
end
