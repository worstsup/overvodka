STACK_COUNT = 0

modifier_kachok_abstention = class({})

function modifier_kachok_abstention:IsPurgable()
	return false
end

function modifier_kachok_abstention:IsHidden()
	return false
end

function modifier_kachok_abstention:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_kachok_abstention:OnCreated( kv )
    if not IsServer() then return end
    self.ability = self:GetAbility()
    self.caster = self:GetCaster()
    self.scale = self.caster:GetModelScale()
    self:SetStackCount(STACK_COUNT)
    self:StartIntervalThink(0.1)
    self:OnIntervalThink()
end

function modifier_kachok_abstention:OnRefresh( kv )
    self:OnCreated( kv )
end

function modifier_kachok_abstention:OnIntervalThink()
    if not IsServer() then return end
    local ability_level = self.ability:GetLevel() - 1
    
    if self.caster:IsIllusion() or not self.ability:IsCooldownReady() or self.caster:PassivesDisabled() or not self.caster:IsAlive() then return end

    self:AddAttributes()
    self.ability:UseResources( false, false, false, true )
end

function modifier_kachok_abstention:AddAttributes()
    if not IsServer() then return end
    local caster = self.caster
    local ability = self.ability
    local attribute_gain = ability:GetAttributeGain()
    self.scale = self.scale + 0.01
    if not caster:HasModifier("modifier_kachok_trenbolone") then
        caster:SetModelScale(self.scale)
    end
    if caster:HasScepter() then
        caster:ModifyAgility(attribute_gain)
        caster:ModifyIntellect(attribute_gain)
    end
    caster:ModifyStrength(attribute_gain)
    STACK_COUNT = STACK_COUNT + 1
    self:SetStackCount(STACK_COUNT)
end