LinkLuaModifier("modifier_royale_innate", "heroes/royale/royale_innate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_royale_innate_buff", "heroes/royale/royale_innate", LUA_MODIFIER_MOTION_NONE)

royale_innate = class({})
function royale_innate:GetIntrinsicModifierName()
    return "modifier_royale_innate"
end

modifier_royale_innate = class({})

function modifier_royale_innate:IsHidden() return true end
function modifier_royale_innate:IsPurgable() return false end

function modifier_royale_innate:OnCreated()
    if not IsServer() then return end
    self.evolved = false
    self:StartIntervalThink(1.0)
end

function modifier_royale_innate:OnIntervalThink()
    if not IsServer() then return end
    if not self.evolved and GameRules:GetGameTime() >= 750 then
        self.evolved = true
        self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_royale_innate_buff", {})
    end
end

modifier_royale_innate_buff = class({})
function modifier_royale_innate_buff:IsHidden() return false end
function modifier_royale_innate_buff:IsPurgable() return false end

function modifier_royale_innate_buff:OnCreated()
    if not IsServer() then return end
    self.health_regen = self:GetParent():GetHealthRegen()
    self.mana_regen = self:GetParent():GetManaRegen()
    self:SetHasCustomTransmitterData(true)
    self:SendBuffRefreshToClients()
    print("Royale's innate buff created with health regen: " .. self.health_regen .. " and mana regen: " .. self.mana_regen)
end

function modifier_royale_innate_buff:AddCustomTransmitterData()
    return {
        health_regen = self.health_regen or 0,
        mana_regen = self.mana_regen or 0
    }
end

function modifier_royale_innate_buff:HandleCustomTransmitterData(data)
    self.health_regen = data.health_regen or 0
    self.mana_regen = data.mana_regen or 0
end

function modifier_royale_innate_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
    }
end

function modifier_royale_innate_buff:GetModifierConstantHealthRegen()
    return self.health_regen or 0
end

function modifier_royale_innate_buff:GetModifierConstantManaRegen()
    return self.mana_regen or 0
end