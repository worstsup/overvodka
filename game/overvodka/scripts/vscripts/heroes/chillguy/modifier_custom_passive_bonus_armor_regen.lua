modifier_custom_passive_bonus_armor_regen = class({})

function modifier_custom_passive_bonus_armor_regen:IsHidden() return true end
function modifier_custom_passive_bonus_armor_regen:IsPurgable() return false end
function modifier_custom_passive_bonus_armor_regen:RemoveOnDeath() return false end

function modifier_custom_passive_bonus_armor_regen:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
    }
end

function modifier_custom_passive_bonus_armor_regen:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.1)
end

function modifier_custom_passive_bonus_armor_regen:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    local isMoving = parent:IsMoving()
    
    if isMoving then
        self:SetStackCount(0) -- Not moving
    else
        self:SetStackCount(1) -- Moving
    end
end

function modifier_custom_passive_bonus_armor_regen:GetModifierPhysicalArmorBonus()
    if self:GetStackCount() > 0 then
        return self:GetParent():GetLevel() -- +1 armor per hero level while not moving
    end
    return 0
end

function modifier_custom_passive_bonus_armor_regen:GetModifierHealthRegenPercentage()
    if self:GetStackCount() > 0 then
        return 3 -- +3% HP regen while not moving
    end
    return 0
end

function modifier_custom_passive_bonus_armor_regen:GetModifierTotalPercentageManaRegen()
    if self:GetStackCount() > 0 then
        return 3 -- +3% mana regen while not moving
    end
    return 0
end