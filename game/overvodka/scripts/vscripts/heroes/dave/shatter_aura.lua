LinkLuaModifier("modifier_shatter_aura", "heroes/dave/shatter_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shatter_aura_debuff", "heroes/dave/shatter_aura.lua", LUA_MODIFIER_MOTION_NONE)

shatter_aura = class({})

function shatter_aura:GetIntrinsicModifierName()
    return "modifier_shatter_aura"
end

modifier_shatter_aura = class({})

function modifier_shatter_aura:IsHidden()
    return true
end

function modifier_shatter_aura:IsPurgable()
    return false
end

function modifier_shatter_aura:IsAura()
    return true
end

function modifier_shatter_aura:GetAuraRadius()
    return 900
end

function modifier_shatter_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_shatter_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_shatter_aura:GetModifierAura()
    return "modifier_shatter_aura_debuff"
end

modifier_shatter_aura_debuff = class({})

function modifier_shatter_aura_debuff:IsHidden()
    return false
end

function modifier_shatter_aura_debuff:IsPurgable()
    return false
end

function modifier_shatter_aura_debuff:OnCreated(kv)
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end

function modifier_shatter_aura_debuff:OnIntervalThink()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local parent = self:GetParent()
    local radius = 900

    local friendly_units = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    local base_reduction = 3
    local bonus_reduction = #friendly_units
    local total_reduction = math.min(base_reduction + bonus_reduction, 15)

    self:SetStackCount(total_reduction)
end

function modifier_shatter_aura_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end

function modifier_shatter_aura_debuff:GetModifierPhysicalArmorBonus()
    return -self:GetStackCount()
end
