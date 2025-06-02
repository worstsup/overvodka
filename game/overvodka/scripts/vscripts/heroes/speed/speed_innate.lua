LinkLuaModifier("modifier_speed_innate", "heroes/speed/speed_innate", LUA_MODIFIER_MOTION_NONE)

speed_innate = class({})

function speed_innate:GetIntrinsicModifierName()
    return "modifier_speed_innate"
end

modifier_speed_innate = class({})

function modifier_speed_innate:IsHidden() return false end
function modifier_speed_innate:IsPurgable() return false end

function modifier_speed_innate:OnCreated()
    if not IsServer() then return end
end

function modifier_speed_innate:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_speed_innate:GetModifierMoveSpeedBonus_Percentage()
    if self:GetParent():PassivesDisabled() then return 0 end
    return self:GetAbility():GetSpecialValueFor("ms_pct") * self:GetParent():GetLevel()
end