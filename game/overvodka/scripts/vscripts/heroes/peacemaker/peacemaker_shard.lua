peacemaker_shard = class({})
LinkLuaModifier( "modifier_peacemaker_shard", "heroes/peacemaker/peacemaker_shard", LUA_MODIFIER_MOTION_NONE )

function peacemaker_shard:GetIntrinsicModifierName()
	return "modifier_peacemaker_shard"
end

modifier_peacemaker_shard = class({})

function modifier_peacemaker_shard:IsHidden()   return false end
function modifier_peacemaker_shard:IsDebuff()   return false end
function modifier_peacemaker_shard:IsPurgable() return false end

function modifier_peacemaker_shard:OnCreated()
    self.dmg_per_kill = self:GetAbility():GetSpecialValueFor("dmg_reduction")
    if not IsServer() then return end
    self:UpdateDamageStacks()
    self:StartIntervalThink(0.5)
end

function modifier_peacemaker_shard:OnIntervalThink()
    self:UpdateDamageStacks()
end

function modifier_peacemaker_shard:OnDestroy()
    if not IsServer() then return end
    self:StartIntervalThink(-1)
end

function modifier_peacemaker_shard:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_peacemaker_shard:GetModifierIncomingDamage_Percentage()
    return -self:GetStackCount() * self.dmg_per_kill
end

function modifier_peacemaker_shard:UpdateDamageStacks()
    if not IsServer() then return end
    self:SetStackCount(self:GetParent():GetKills())
end

function modifier_peacemaker_shard:OnDeath(params)
    if not IsServer() then return end
    if params.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then return end
    if params.unit:GetTeamNumber() == self:GetParent():GetTeamNumber() then return end
    if params.unit:IsRealHero() and not params.unit:IsIllusion() and RandomInt(1, 2) == 1 then
        self:GetParent():EmitSound("Peacemaker.Shard.Death")
    end
end