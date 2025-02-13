modifier_kachok_attribute_gain = class({})

function modifier_kachok_attribute_gain:IsPurgable()
	return false
end

function modifier_kachok_attribute_gain:IsHidden()
	return true
end

function modifier_kachok_attribute_gain:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_kachok_attribute_gain:OnCreated( kv )
    if IsServer() then
        self.ability = self:GetAbility()
        self.caster = self:GetCaster()
    end

    self:StartIntervalThink(0.1)
    self:OnIntervalThink()
end

function modifier_kachok_attribute_gain:OnIntervalThink()
    local caster = self.caster
    local ability = self.ability
    local ability_level = ability:GetLevel() - 1
    local cooldown = ability:GetEffectiveCooldown(ability_level)

    if caster:IsIllusion() or not ability:IsCooldownReady() then return end

    self:AddAttributes()
    ability:StartCooldown( cooldown )
end

function modifier_kachok_attribute_gain:AddAttributes()
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