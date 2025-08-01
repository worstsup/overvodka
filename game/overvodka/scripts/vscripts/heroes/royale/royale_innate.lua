LinkLuaModifier("modifier_royale_innate", "heroes/royale/royale_innate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_royale_innate_buff", "heroes/royale/royale_innate", LUA_MODIFIER_MOTION_NONE)

royale_innate = class({})

function royale_innate:Precache(context)
    PrecacheResource("soundfile", "soundevents/royale_sounds.vsndevts", context)
end

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
    local time = 750
    if GetMapName() == "overvodka_5x5" then
        time = 1200
    end
    if not self.evolved and GameRules:GetGameTime() >= time and not self:GetParent():HasModifier("modifier_rune_regen") and not self:GetParent():HasModifier("modifier_fountain_aura_effect_lua") then
        self.evolved = true
        self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_royale_innate_buff", {})
        EmitSoundOn("Royale.DoubleElixir", self:GetParent())
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