LinkLuaModifier("modifier_item_jordan",        "items/jordan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_jordan_active", "items/jordan", LUA_MODIFIER_MOTION_NONE)

item_jordan = class({})

function item_jordan:GetIntrinsicModifierName()
    return "modifier_item_jordan"
end

function item_jordan:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local duration = self:GetSpecialValueFor("phase_duration")

    caster:AddNewModifier(caster, self, "modifier_item_jordan_active", { duration = duration })
    caster:EmitSound("DOTA_Item.PhaseBoots.Activate")
end

modifier_item_jordan = class({})

function modifier_item_jordan:IsHidden() return true end
function modifier_item_jordan:IsPurgable() return false end
function modifier_item_jordan:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_jordan:OnCreated()
    self.ability = self:GetAbility()
    if not self.ability or self.ability:IsNull() then return end

    self.bonus_movement_speed = self.ability:GetSpecialValueFor("bonus_movement_speed")
    self.bonus_damage         = self.ability:GetSpecialValueFor("bonus_damage")
    self.bonus_all_stats      = self.ability:GetSpecialValueFor("bonus_all_stats")
    self.bonus_int            = self.ability:GetSpecialValueFor("bonus_int")
    self.bonus_health         = self.ability:GetSpecialValueFor("bonus_health")
    self.bonus_armor          = self.ability:GetSpecialValueFor("bonus_armor")
    self.bonus_as             = self.ability:GetSpecialValueFor("bonus_as")
    self.bonus_mregen         = self.ability:GetSpecialValueFor("bonus_mregen")
    self.bonus_mana_pct_regen = self.ability:GetSpecialValueFor("bonus_mana")
    self.spell_amp            = self.ability:GetSpecialValueFor("spell_amp")
end

function modifier_item_jordan:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }
end

function modifier_item_jordan:GetModifierMoveSpeedBonus_Special_Boots()
    if self:GetAbility() then
        return self.bonus_movement_speed
    end
end

function modifier_item_jordan:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
        return self.bonus_damage
    end
end

function modifier_item_jordan:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self.bonus_all_stats
    end
end

function modifier_item_jordan:GetModifierBonusStats_Agility()
    if self:GetAbility() then
        return self.bonus_all_stats
    end
end

function modifier_item_jordan:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self.bonus_int
    end
end

function modifier_item_jordan:GetModifierHealthBonus()
    if self:GetAbility() then
        return self.bonus_health
    end
end

function modifier_item_jordan:GetModifierTotalPercentageManaRegen()
    if self:GetAbility() then
        return self.bonus_mana_pct_regen
    end
end

function modifier_item_jordan:GetModifierPhysicalArmorBonus()
    if self:GetAbility() then
        return self.bonus_armor
    end
end

function modifier_item_jordan:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
        return self.bonus_as
    end
end

function modifier_item_jordan:GetModifierConstantManaRegen()
    if self:GetAbility() then
        return self.bonus_mregen
    end
end

function modifier_item_jordan:GetModifierSpellAmplify_Percentage()
    if self:GetAbility() then
        return self.spell_amp
    end
end

modifier_item_jordan_active = class({})

function modifier_item_jordan_active:IsHidden() return false end
function modifier_item_jordan_active:IsPurgable() return false end

function modifier_item_jordan_active:OnCreated()
    self.ability = self:GetAbility()
    if not self.ability or self.ability:IsNull() then return end

    self.phase_movement_speed = self.ability:GetSpecialValueFor("phase_movement_speed")
    self.cast_amp             = self.ability:GetSpecialValueFor("cast_amp")
end

function modifier_item_jordan_active:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
    }
end

function modifier_item_jordan_active:GetModifierMoveSpeedBonus_Percentage()
    return self.phase_movement_speed or 0
end

function modifier_item_jordan_active:GetModifierPercentageCasttime()
    return self.cast_amp or 0
end

function modifier_item_jordan_active:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_item_jordan_active:GetEffectName()
    return "particles/econ/events/ti9/phase_boots_ti9.vpcf"
end

function modifier_item_jordan_active:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end