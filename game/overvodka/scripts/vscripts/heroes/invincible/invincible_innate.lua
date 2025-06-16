LinkLuaModifier("modifier_invincible_innate_aura",    "heroes/invincible/invincible_innate.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invincible_innate_debuff", "heroes/invincible/invincible_innate.lua", LUA_MODIFIER_MOTION_NONE)

invincible_innate = class({})
function invincible_innate:GetAbilityTextureName()
    if self:GetCaster():HasArcana() then
        return "invincible_innate_arcana"
    end
    return "invincible_innate"
end
function invincible_innate:GetIntrinsicModifierName()
    return "modifier_invincible_innate_aura"
end

modifier_invincible_innate_aura = class({})

function modifier_invincible_innate_aura:IsHidden()       return true  end
function modifier_invincible_innate_aura:IsPurgable()     return false end
function modifier_invincible_innate_aura:IsAura()         return true  end
function modifier_invincible_innate_aura:IsAuraActiveOnDeath() return false end

function modifier_invincible_innate_aura:GetAuraRadius()
    if self:GetParent():PassivesDisabled() then return 0 end
    return self:GetAbility():GetSpecialValueFor("radius") 
end

function modifier_invincible_innate_aura:GetAuraSearchTeam() 
    return DOTA_UNIT_TARGET_TEAM_ENEMY 
end

function modifier_invincible_innate_aura:GetAuraSearchType() 
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC 
end

function modifier_invincible_innate_aura:GetAuraSearchFlags() 
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_invincible_innate_aura:GetModifierAura() 
    return "modifier_invincible_innate_debuff" 
end

modifier_invincible_innate_debuff = class({})

function modifier_invincible_innate_debuff:IsHidden() return false end
function modifier_invincible_innate_debuff:IsDebuff() return true end
function modifier_invincible_innate_debuff:IsPurgable() return false end

function modifier_invincible_innate_debuff:OnCreated()
    if not IsServer() then return end
end

function modifier_invincible_innate_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
    }
end

function modifier_invincible_innate_debuff:GetModifierHPRegenAmplify_Percentage()
    return self:GetAbility():GetSpecialValueFor("heal_pct")
end
