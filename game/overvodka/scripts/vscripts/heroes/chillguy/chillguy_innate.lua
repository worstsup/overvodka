LinkLuaModifier( "modifier_chillguy_innate", "heroes/chillguy/chillguy_innate", LUA_MODIFIER_MOTION_NONE )

chillguy_innate = class({})

function chillguy_innate:GetIntrinsicModifierName()
    return "modifier_chillguy_innate"
end


modifier_chillguy_innate = class({})

function modifier_chillguy_innate:IsHidden() return true end
function modifier_chillguy_innate:IsPurgable() return false end
function modifier_chillguy_innate:RemoveOnDeath() return false end

function modifier_chillguy_innate:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
    }
end

function modifier_chillguy_innate:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.1)
end

function modifier_chillguy_innate:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    if parent:PassivesDisabled() then
        self:SetStackCount(0)
        return
    end
    local isMoving = parent:IsMoving()
    if not isMoving or (parent:HasScepter() and parent:HasModifier("modifier_chillguy_r")) then
        self:SetStackCount(1)
    else
        self:SetStackCount(0)
    end
end

function modifier_chillguy_innate:GetModifierPhysicalArmorBonus()
    if self:GetStackCount() > 0 then
        return (self:GetAbility():GetSpecialValueFor("armor") * self:GetParent():GetLevel())
    end
    return 0
end

function modifier_chillguy_innate:GetModifierHealthRegenPercentage()
    if self:GetStackCount() > 0 then
        return self:GetAbility():GetSpecialValueFor("hp")
    end
    return 0
end

function modifier_chillguy_innate:GetModifierTotalPercentageManaRegen()
    if self:GetStackCount() > 0 then
        return self:GetAbility():GetSpecialValueFor("hp")
    end
    return 0
end