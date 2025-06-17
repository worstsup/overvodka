LinkLuaModifier("modifier_sahur_innate", "heroes/sahur/sahur_innate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sahur_innate_checker", "heroes/sahur/sahur_innate", LUA_MODIFIER_MOTION_NONE)
sahur_innate = class({})

function sahur_innate:GetIntrinsicModifierName()
    return "modifier_sahur_innate_checker"
end

modifier_sahur_innate_checker = class({})

function modifier_sahur_innate_checker:IsHidden() return true end
function modifier_sahur_innate_checker:IsPurgable() return false end

function modifier_sahur_innate_checker:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.1)
end

function modifier_sahur_innate_checker:OnIntervalThink()
    if not self:GetParent():IsAlive() or self:GetParent():PassivesDisabled() then
        if self:GetParent():HasModifier("modifier_sahur_innate") then
            self:GetParent():RemoveModifierByName("modifier_sahur_innate")
        end
        return
    end
    if self:GetParent():HasModifier("modifier_get_xp") then
        self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_sahur_innate", {})
    else
        if self:GetParent():HasModifier("modifier_sahur_innate") then
            self:GetParent():RemoveModifierByName("modifier_sahur_innate")
        end
    end
end

modifier_sahur_innate = class({})

function modifier_sahur_innate:IsHidden() return false end
function modifier_sahur_innate:IsPurgable() return false end

function modifier_sahur_innate:OnCreated()
end

function modifier_sahur_innate:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_sahur_innate:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("regen")
end

function modifier_sahur_innate:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_sahur_innate:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("damage")
end

function modifier_sahur_innate:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed")
end