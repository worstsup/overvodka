worstsup_e = class({})

function worstsup_e:GetBehavior()
    local caster = self:GetCaster()
    if caster and not caster:IsNull() and caster:HasShard() then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end

    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function worstsup_e:IsRefreshable() return false end

function worstsup_e:GetCooldown(level)
    local caster = self:GetCaster()
    if caster and not caster:IsNull() and caster:HasShard() then
        return self:GetSpecialValueFor("AbilityCooldown")
    end

    return 0
end

function worstsup_e:GetManaCost(level)
    local caster = self:GetCaster()
    if caster and not caster:IsNull() and caster:HasShard() then
        return self:GetSpecialValueFor("AbilityManaCost")
    end

    return 0
end

function worstsup_e:OnUpgrade()
    self:SyncLinkedAbility()
end

function worstsup_e:OnOwnerSpawned()
    self:SyncLinkedAbility()
end

function worstsup_e:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() or not caster:HasShard() then
        self:RefundManaCost()
        self:EndCooldown()
        return
    end

    if not ChaosOrb or not ChaosOrb.BeginSelection or not ChaosOrb:BeginSelection(caster) then
        self:RefundManaCost()
        self:EndCooldown()
    end
end

function worstsup_e:SyncLinkedAbility()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local linkedAbility = caster:FindAbilityByName("rubick_arcane_supremacy")
    if not linkedAbility or linkedAbility:IsNull() then return end

    linkedAbility:SetHidden(true)

    local level = self:GetLevel()
    if linkedAbility:GetLevel() ~= level then
        linkedAbility:SetLevel(level)
    end
end
