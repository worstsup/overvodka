LinkLuaModifier("modifier_item_octarine_vodka", "items/octarine_vodka", LUA_MODIFIER_MOTION_NONE)

item_octarine_vodka = class({})

function item_octarine_vodka:GetIntrinsicModifierName()
    return "modifier_item_octarine_vodka"
end

modifier_item_octarine_vodka = class({})

function modifier_item_octarine_vodka:IsHidden()
	return true
end

function modifier_item_octarine_vodka:IsPurgable()
    return false
end

function modifier_item_octarine_vodka:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
    return funcs
end

function modifier_item_octarine_vodka:GetModifierPercentageCooldown()
    if self:GetAbility() then
        if self:GetParent():HasItemInInventory("item_magic_aegis") then self.cd = 0 return 0 end
        self.cd = self:GetAbility():GetSpecialValueFor('cd')
        return self.cd
    end
end

function modifier_item_octarine_vodka:GetModifierManaBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('mp')
    end
end

function modifier_item_octarine_vodka:GetModifierHealthBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('hp')
    end
end

function modifier_item_octarine_vodka:GetModifierConstantManaRegen()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('mana_regen')
    end
end