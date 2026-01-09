silvername_shard = class({})
LinkLuaModifier( "modifier_silvername_shard", "heroes/silvername/silvername_shard", LUA_MODIFIER_MOTION_NONE )

function silvername_shard:GetIntrinsicModifierName()
	return "modifier_silvername_shard"
end

modifier_silvername_shard = class({})

function modifier_silvername_shard:IsHidden()   return false end
function modifier_silvername_shard:IsDebuff()   return false end
function modifier_silvername_shard:IsPurgable() return false end

function modifier_silvername_shard:OnCreated()
    self.spell_amp = self:GetAbility():GetSpecialValueFor( "spell_amp" )
    if not IsServer() then return end
    self:UpdateDamageStacks()
    self:StartIntervalThink(0.5)
end

function modifier_silvername_shard:OnIntervalThink()
    self:UpdateDamageStacks()
end

function modifier_silvername_shard:OnDestroy()
    if not IsServer() then return end
    self:StartIntervalThink(-1)
end

function modifier_silvername_shard:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_silvername_shard:GetModifierSpellAmplify_Percentage()
    if not IsServer() then
        return self:GetStackCount() * self.spell_amp
    end
    if not self:GetCaster():HasShard() then
        return 0
    end
    return self:GetStackCount() * self.spell_amp
end

function modifier_silvername_shard:UpdateDamageStacks()
    if not IsServer() then return end
    self:SetStackCount(self:GetParent():GetKills())
end

function modifier_silvername_shard:OnDeath(params)
    if not IsServer() then return end
    if params.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then return end
    if params.unit:GetTeamNumber() == self:GetParent():GetTeamNumber() then return end
    if params.unit:IsRealHero() and not params.unit:IsIllusion() and RandomInt(1, 2) == 1 then
        self:GetParent():EmitSound("silvername_shard_facet_3")
    end
end