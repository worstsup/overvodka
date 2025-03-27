LinkLuaModifier("modifier_item_magic_aegis", "items/magic_aegis", LUA_MODIFIER_MOTION_NONE)

item_magic_aegis = class({})

function item_magic_aegis:GetIntrinsicModifierName()
    return "modifier_item_magic_aegis"
end

modifier_item_magic_aegis = class({})

function modifier_item_magic_aegis:IsHidden() return true end
function modifier_item_magic_aegis:IsPurgable() return false end
function modifier_item_magic_aegis:IsPurgeException() return false end

function modifier_item_magic_aegis:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
    return funcs
end

function modifier_item_magic_aegis:GetModifierPercentageCooldown()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('cd')
    end
end

function modifier_item_magic_aegis:GetModifierManaBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('mp')
    end
end

function modifier_item_magic_aegis:GetModifierHealthBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('hp')
    end
end

function modifier_item_magic_aegis:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('int')
    end
end

function modifier_item_magic_aegis:GetModifierSpellAmplify_Percentage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('dmg')
    end
end

function modifier_item_magic_aegis:GetModifierConstantManaRegen()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('mana_regen')
    end
end