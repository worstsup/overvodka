LinkLuaModifier("modifier_item_nikes",        "items/nikes", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_nikes_active", "items/nikes", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_nikes_cold",   "items/nikes", LUA_MODIFIER_MOTION_NONE)

item_nikes = class({})

function item_nikes:GetIntrinsicModifierName()
    return "modifier_item_nikes"
end

function item_nikes:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local duration = self:GetSpecialValueFor("phase_duration")

    caster:AddNewModifier(caster, self, "modifier_item_nikes_active", { duration = duration })
    caster:EmitSound("DOTA_Item.PhaseBoots.Activate")
end

modifier_item_nikes = class({})

function modifier_item_nikes:IsHidden() return true end
function modifier_item_nikes:IsPurgable() return false end
function modifier_item_nikes:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_nikes:OnCreated()
    self.ability = self:GetAbility()
    if not self.ability or self.ability:IsNull() then return end

    self.bonus_movement_speed = self.ability:GetSpecialValueFor("bonus_movement_speed")
    self.bonus_damage         = self.ability:GetSpecialValueFor("bonus_damage")
    self.bonus_all_stats      = self.ability:GetSpecialValueFor("bonus_all_stats")
    self.bonus_as             = self.ability:GetSpecialValueFor("bonus_as")
    self.bonus_armor          = self.ability:GetSpecialValueFor("bonus_armor")
    self.bonus_health         = self.ability:GetSpecialValueFor("bonus_health")
    self.bonus_mana           = self.ability:GetSpecialValueFor("bonus_mana")

    self.cold_duration_melee  = self.ability:GetSpecialValueFor("cold_duration_melee")
    self.cold_duration_ranged = self.ability:GetSpecialValueFor("cold_duration_ranged")
end

function modifier_item_nikes:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_item_nikes:GetModifierMoveSpeedBonus_Special_Boots()
    if self:GetAbility() then
        return self.bonus_movement_speed
    end
end

function modifier_item_nikes:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
        return self.bonus_damage
    end
end

function modifier_item_nikes:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self.bonus_all_stats
    end
end

function modifier_item_nikes:GetModifierBonusStats_Agility()
    if self:GetAbility() then
        return self.bonus_all_stats
    end
end

function modifier_item_nikes:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self.bonus_all_stats
    end
end

function modifier_item_nikes:GetModifierHealthBonus()
    if self:GetAbility() then
        return self.bonus_health
    end
end

function modifier_item_nikes:GetModifierManaBonus()
    if self:GetAbility() then
        return self.bonus_mana
    end
end

function modifier_item_nikes:GetModifierPhysicalArmorBonus()
    if self:GetAbility() then
        return self.bonus_armor
    end
end

function modifier_item_nikes:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
        return self.bonus_as
    end
end

function modifier_item_nikes:OnAttackLanded(params)
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end
    if parent ~= params.attacker then return end

    local target = params.target
    if not target or target:IsNull() then return end
    if target:IsOutOfGame() or not target:IsAlive() then return end
    if target:IsBuilding() or target:IsOther() then return end

    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return end

    if parent:HasItemInInventory("item_skadi") then return end

    local dur = 0
    if parent:IsRangedAttacker() then
        dur = self.cold_duration_ranged or 0
    else
        dur = self.cold_duration_melee or 0
    end
    if dur <= 0 then return end

    target:AddNewModifier(parent, ability, "modifier_item_nikes_cold", { duration = dur * (1 - target:GetStatusResistance()) })
end

modifier_item_nikes_active = class({})

function modifier_item_nikes_active:IsHidden() return false end
function modifier_item_nikes_active:IsPurgable() return true end

function modifier_item_nikes_active:OnCreated()
    self.ability = self:GetAbility()
    if not self.ability or self.ability:IsNull() then return end
    self.phase_movement_speed = self.ability:GetSpecialValueFor("phase_movement_speed")
end

function modifier_item_nikes_active:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_item_nikes_active:GetModifierMoveSpeedBonus_Percentage()
    return self.phase_movement_speed or 0
end

function modifier_item_nikes_active:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_item_nikes_active:GetEffectName()
    return "particles/item_nikes.vpcf"
end

function modifier_item_nikes_active:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_item_nikes_cold = class({})

function modifier_item_nikes_cold:IsHidden() return false end
function modifier_item_nikes_cold:IsDebuff() return true end
function modifier_item_nikes_cold:IsPurgable() return true end

function modifier_item_nikes_cold:OnCreated()
    self.ability = self:GetAbility()
    if not self.ability or self.ability:IsNull() then return end

    self.cold_attack_speed   = self.ability:GetSpecialValueFor("cold_attack_speed")
    self.cold_movement_speed = self.ability:GetSpecialValueFor("cold_movement_speed")
    self.cold_regen          = self.ability:GetSpecialValueFor("cold_regen")
end

function modifier_item_nikes_cold:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
    }
end

function modifier_item_nikes_cold:GetModifierAttackSpeedBonus_Constant()
    return self.cold_attack_speed or 0
end

function modifier_item_nikes_cold:GetModifierMoveSpeedBonus_Percentage()
    return self.cold_movement_speed or 0
end

function modifier_item_nikes_cold:GetModifierHealAmplify_PercentageTarget()
    return self.cold_regen or 0
end

function modifier_item_nikes_cold:GetModifierHPRegenAmplify_Percentage()
    return self.cold_regen or 0
end

function modifier_item_nikes_cold:GetModifierLifestealRegenAmplify_Percentage()
    return self.cold_regen or 0
end

function modifier_item_nikes_cold:GetModifierSpellLifestealRegenAmplify_Percentage()
    return self.cold_regen or 0
end

function modifier_item_nikes_cold:GetStatusEffectName()
    return "particles/econ/items/drow/drow_arcana/drow_arcana_status_effect_frost_arrow.vpcf"
end

function modifier_item_nikes_cold:GetEffectName()
    return "particles/econ/items/drow/drow_ti9_immortal/drow_ti9_frost_arrow_debuff.vpcf"
end

function modifier_item_nikes_cold:StatusEffectPriority()
    return 10
end