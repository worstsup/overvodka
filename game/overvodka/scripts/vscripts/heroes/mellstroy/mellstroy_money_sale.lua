LinkLuaModifier("modifier_mellstroy_money_sale", "heroes/mellstroy/mellstroy_money_sale", LUA_MODIFIER_MOTION_NONE)

mellstroy_money_sale = class({})

function mellstroy_money_sale:GetIntrinsicModifierName()
    return "modifier_mellstroy_money_sale"
end

modifier_mellstroy_money_sale = class({})

function modifier_mellstroy_money_sale:IsHidden() return true end
function modifier_mellstroy_money_sale:IsPurgable() return false end
function modifier_mellstroy_money_sale:RemoveOnDeath() return false end

function modifier_mellstroy_money_sale:OnCreated()
    self._txData = self._txData or {}
    self.low_gold = 0
    self._last_low_gold = nil

    if IsServer() then
        self:SetHasCustomTransmitterData(true)
        self:StartIntervalThink(0.1)
        self:OnIntervalThink()
    else
        self:_ApplyFlagToAllAbilities()
    end
end

function modifier_mellstroy_money_sale:OnIntervalThink()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local pid = caster:GetPlayerOwnerID()
    if pid == nil or pid < 0 then return end

    local gold = PlayerResource:GetGold(pid) or 0
    local low = (gold < self:GetAbility():GetSpecialValueFor("gold_max")) and 1 or 0

    if self._last_low_gold == low then
        return
    end
    self._last_low_gold = low
    self.low_gold = low

    self:_ApplyFlagToAllAbilities()

    self:SendBuffRefreshToClients()
end

function modifier_mellstroy_money_sale:_ApplyFlagToAllAbilities()
    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    caster._low_gold = self.low_gold or 0
end

function modifier_mellstroy_money_sale:AddCustomTransmitterData()
    self._txData.low_gold = self.low_gold or 0
    return self._txData
end

function modifier_mellstroy_money_sale:HandleCustomTransmitterData(data)
    if not data then return end

    self.low_gold = tonumber(data.low_gold) or 0
    self:_ApplyFlagToAllAbilities()
end
