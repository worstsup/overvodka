modifier_kachok_abstention = class({})

function modifier_kachok_abstention:IsPurgable()
	return false
end

function modifier_kachok_abstention:IsHidden()
	return true
end

function modifier_kachok_abstention:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_kachok_abstention:OnCreated( kv )
    if not IsServer() then return end
    self.ability = self:GetAbility()
    self.caster = self:GetCaster()

    self:StartIntervalThink(0.1)
    self:OnIntervalThink()
end

function modifier_kachok_abstention:OnRefresh( kv )
    self:OnCreated( kv )
end

function modifier_kachok_abstention:OnIntervalThink()
    if not IsServer() then return end
    local ability_level = self.ability:GetLevel() - 1
    local cooldown = self.ability:GetCooldown(ability_level)
    
    if self.caster:IsIllusion() or not self.ability:IsCooldownReady() or self.caster:PassivesDisabled() then return end

    self:AddAttributes()
    self.ability:StartCooldown( cooldown )
end

function modifier_kachok_abstention:AddAttributes()
    if not IsServer() then return end
    local caster = self.caster
    local ability = self.ability
    local attribute_gain = ability:GetAttributeGain()

    if caster:HasScepter() then
        caster:ModifyAgility(attribute_gain)
        caster:ModifyIntellect(attribute_gain)
    end

    caster:ModifyStrength(attribute_gain)
    -- TODO: Добавить эффект и звуки?
end