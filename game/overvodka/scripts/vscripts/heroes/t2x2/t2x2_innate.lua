LinkLuaModifier("modifier_t2x2_innate", "heroes/t2x2/t2x2_innate", LUA_MODIFIER_MOTION_NONE)

t2x2_innate = class({})

function t2x2_innate:GetIntrinsicModifierName()
    return "modifier_t2x2_innate"
end

modifier_t2x2_innate = class({})

function modifier_t2x2_innate:IsHidden() return true  end
function modifier_t2x2_innate:IsPurgable() return false end
function modifier_t2x2_innate:RemoveOnDeath() return false end

function modifier_t2x2_innate:OnCreated()
    if not IsServer() then return end
end

function modifier_t2x2_innate:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_STATUS_RESISTANCE,
        MODIFIER_PROPERTY_MODEL_SCALE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_t2x2_innate:GetModifierPreAttack_BonusDamage()
    return self:GetParent():GetLevel() * self:GetAbility():GetSpecialValueFor("lvl_damage")
end

function modifier_t2x2_innate:GetModifierStatusResistance()
    return self:GetParent():GetLevel() * self:GetAbility():GetSpecialValueFor("lvl_status_resistance")
end

function modifier_t2x2_innate:GetModifierModelScale()
    return self:GetParent():GetLevel() * 2
end

function modifier_t2x2_innate:GetModifierMoveSpeedBonus_Percentage()
    return self:GetParent():GetLevel() * self:GetAbility():GetSpecialValueFor("lvl_slow")
end
