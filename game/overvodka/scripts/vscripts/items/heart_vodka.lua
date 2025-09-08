LinkLuaModifier("modifier_item_heart_vodka", "items/heart_vodka", LUA_MODIFIER_MOTION_NONE)

item_heart_vodka = class({})

function item_heart_vodka:GetIntrinsicModifierName()
    return "modifier_item_heart_vodka"
end

modifier_item_heart_vodka = class({})

function modifier_item_heart_vodka:IsHidden() return true end
function modifier_item_heart_vodka:IsPurgable() return false end
function modifier_item_heart_vodka:IsPurgeException() return false end
function modifier_item_heart_vodka:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_heart_vodka:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
    }
    return funcs
end

function modifier_item_heart_vodka:OnCreated()
    if not IsServer() then return end
    self.str = self:GetAbility():GetSpecialValueFor('bonus_strength')
    self.health_regen_pct = self:GetAbility():GetSpecialValueFor('health_regen_pct')
    if self:GetParent():FindAllModifiersByName("modifier_item_heart_vodka")[1] ~= self or self:GetParent():HasItemInInventory("item_kaska") then
        self.health_regen_pct = 0
    end
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(FrameTime())
end

function modifier_item_heart_vodka:OnIntervalThink()
    if not IsServer() then return end
    self.str = self:GetAbility():GetSpecialValueFor('bonus_strength')
    if self:GetParent():FindAllModifiersByName("modifier_item_heart_vodka")[1] ~= self or self:GetParent():HasItemInInventory("item_kaska") then
        self.health_regen_pct = 0
    else
        self.health_regen_pct = self:GetAbility():GetSpecialValueFor('health_regen_pct')
    end
    self:SendBuffRefreshToClients()
end

function modifier_item_heart_vodka:AddCustomTransmitterData()
    return 
    {
        str = self.str,
        health_regen_pct = self.health_regen_pct,
    }
end

function modifier_item_heart_vodka:HandleCustomTransmitterData( data )
    self.str = data.str
    self.health_regen_pct = data.health_regen_pct
end

function modifier_item_heart_vodka:GetModifierBonusStats_Strength()
    if not self:GetAbility() then return end
    return self.str
end

function modifier_item_heart_vodka:GetModifierHealthRegenPercentage()
    if not self:GetAbility() then return end
    return self.health_regen_pct
end