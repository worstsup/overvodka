LinkLuaModifier("modifier_shatter_aura", "heroes/dave/shatter_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shatter_aura_debuff", "heroes/dave/shatter_aura.lua", LUA_MODIFIER_MOTION_NONE)

shatter_aura = class({})

function shatter_aura:GetIntrinsicModifierName()
    return "modifier_shatter_aura"
end

modifier_shatter_aura = class({})

function modifier_shatter_aura:IsHidden() return true end
function modifier_shatter_aura:IsPurgable() return false end
function modifier_shatter_aura:IsAura() return true end
function modifier_shatter_aura:GetAuraRadius() return 900 end
function modifier_shatter_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_shatter_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_shatter_aura:GetModifierAura() return "modifier_shatter_aura_debuff" end

modifier_shatter_aura_debuff = class({})

function modifier_shatter_aura_debuff:IsHidden() return false end
function modifier_shatter_aura_debuff:IsPurgable() return false end

function modifier_shatter_aura_debuff:OnCreated(kv)
    self.caster = self:GetCaster()
    self.base_reduction = self:GetAbility():GetSpecialValueFor( "base_tooltip" )
    self.unit_reduction = self:GetAbility():GetSpecialValueFor( "unit_tooltip" )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius_tooltip" )
    self.max_reduction = self:GetAbility():GetSpecialValueFor( "max_tooltip" )
    self:StartIntervalThink(0.25)
end

function modifier_shatter_aura_debuff:OnIntervalThink()
    if not IsServer() then return end

    local friendly_units = FindUnitsInRadius(self.caster:GetTeamNumber(), self.caster:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    local bonus_reduction = #friendly_units * self.unit_reduction
    local total_reduction = math.min(self.base_reduction + bonus_reduction, 35)

    self:SetStackCount(total_reduction)
end

function modifier_shatter_aura_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
end

function modifier_shatter_aura_debuff:GetModifierMagicalResistanceBonus()
    return -self:GetStackCount()
end
