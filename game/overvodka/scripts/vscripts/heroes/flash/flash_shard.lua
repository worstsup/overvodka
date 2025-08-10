flash_shard = class({})
LinkLuaModifier( "modifier_flash_shard", "heroes/flash/flash_shard", LUA_MODIFIER_MOTION_NONE )

function flash_shard:GetIntrinsicModifierName()
	return "modifier_flash_shard"
end

modifier_flash_shard = class({})

function modifier_flash_shard:IsHidden()   return false end
function modifier_flash_shard:IsDebuff()   return false end
function modifier_flash_shard:IsPurgable() return false end

function modifier_flash_shard:OnCreated(kv)
    if not IsServer() then return end
    self.agi_per_kill = self:GetAbility():GetSpecialValueFor("agi_gain")
    self:UpdateAgilityStacks()
    self:StartIntervalThink(1.0)
end

function modifier_flash_shard:OnIntervalThink()
    self:UpdateAgilityStacks()
end

function modifier_flash_shard:OnDestroy()
    if not IsServer() then return end
    self:StartIntervalThink(-1)
end

function modifier_flash_shard:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }
end

function modifier_flash_shard:GetModifierBonusStats_Agility()
    return self:GetStackCount()
end

function modifier_flash_shard:UpdateAgilityStacks()
    if not IsServer() then return end
    local kills = self:GetParent():GetKills()
    local bonus = kills * self.agi_per_kill
    self:SetStackCount(math.floor(bonus))
end
