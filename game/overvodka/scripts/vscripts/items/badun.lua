LinkLuaModifier("modifier_item_badun",          "items/badun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_badun_ethereal", "items/badun", LUA_MODIFIER_MOTION_NONE)

item_badun = class({})

function item_badun:GetIntrinsicModifierName()
    return "modifier_item_badun"
end

function item_badun:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if not caster or caster:IsNull() then return end
    if not target or target:IsNull() then return end

    local projectile_speed = self:GetSpecialValueFor("projectile_speed")

    local info = {
        Target = target,
        Source = caster,
        Ability = self,
        EffectName = "particles/badun_blade.vpcf",
        iMoveSpeed = projectile_speed,
        bDodgeable = true,
        bProvidesVision = false,
        bReplaceExisting = false,
    }

    ProjectileManager:CreateTrackingProjectile(info)

    caster:EmitSound("badun_cast_start")
end

function item_badun:OnProjectileHit(hTarget, vLocation)
    if not IsServer() then return true end

    local caster = self:GetCaster()
    local target = hTarget

    if not caster or caster:IsNull() then return true end
    if not target or target:IsNull() then return true end

    if target:GetTeamNumber() ~= caster:GetTeamNumber() then
        if target:TriggerSpellAbsorb(self) then
            return true
        end
    end

    local is_ally = (target:GetTeamNumber() == caster:GetTeamNumber())

    local duration = self:GetSpecialValueFor("duration")
    local duration_ally = self:GetSpecialValueFor("duration_ally")
    local final_duration = is_ally and duration_ally or duration

    if (not is_ally) and target.GetStatusResistance then
        final_duration = final_duration * (1 - target:GetStatusResistance())
    end

    target:AddNewModifier(caster, self, "modifier_item_badun_ethereal",{duration = final_duration, is_ally = is_ally and 1 or 0 })
    target:EmitSound("badun_hit")

    if not is_ally then
        local mult = self:GetSpecialValueFor("blast_agility_multiplier")
        local base = self:GetSpecialValueFor("blast_damage_base")
        local attr_value = 0
        target:EmitSound("badun_birds")
        if target.GetPrimaryAttribute ~= nil then
            local pa = target:GetPrimaryAttribute()
            if pa == DOTA_ATTRIBUTE_STRENGTH then
                attr_value = target:GetStrength()
            elseif pa == DOTA_ATTRIBUTE_AGILITY then
                attr_value = target:GetAgility()
            elseif pa == DOTA_ATTRIBUTE_INTELLECT then
                attr_value = target:GetIntellect(false)
            elseif pa == DOTA_ATTRIBUTE_ALL then
                attr_value = (target:GetStrength() + target:GetAgility() + target:GetIntellect(false)) / 3
            else
                attr_value = target:GetAgility()
            end
        end
        local damage = (mult * attr_value) + base
        ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
    end

    return true
end

modifier_item_badun = class({})

function modifier_item_badun:IsHidden() return true end
function modifier_item_badun:IsPurgable() return false end
function modifier_item_badun:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_badun:OnCreated()
    self.ability = self:GetAbility()
    if not self.ability or self.ability:IsNull() then return end

    self.bonus_agi = self.ability:GetSpecialValueFor("bonus_agility")
    self.bonus_str = self.ability:GetSpecialValueFor("bonus_strength")
    self.bonus_int = self.ability:GetSpecialValueFor("bonus_intellect")
    self.bonus_mana = self.ability:GetSpecialValueFor("bonus_mana")

    if not IsServer() then return end

    self.bonus_mana_regen_pct = self.ability:GetSpecialValueFor("bonus_mana_regen_pct")
    self.spell_amp            = self.ability:GetSpecialValueFor("spell_amp")

    if self:GetParent():FindAllModifiersByName("modifier_item_badun")[1] ~= self or self:GetParent():HasItemInInventory("item_kaya") or self:GetParent():HasItemInInventory("item_jordan") then
        self.spell_amp = 0
        self.bonus_mana_regen_pct = 0
    end

    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(FrameTime())
end

function modifier_item_badun:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():FindAllModifiersByName("modifier_item_badun")[1] ~= self or self:GetParent():HasItemInInventory("item_kaya") or self:GetParent():HasItemInInventory("item_jordan") then
        self.spell_amp = 0
        self.bonus_mana_regen_pct = 0
    else
        self.bonus_mana_regen_pct = self.ability:GetSpecialValueFor("bonus_mana_regen_pct")
        self.spell_amp            = self.ability:GetSpecialValueFor("spell_amp")
    end
    self:SendBuffRefreshToClients()
end

function modifier_item_badun:AddCustomTransmitterData()
    self._txData = self._txData or {}
    self._txData.bonus_mana_regen_pct   = self.bonus_mana_regen_pct or 0
    self._txData.spell_amp = self.spell_amp or 0
    return self._txData
end

function modifier_item_badun:HandleCustomTransmitterData( data )
    self.bonus_mana_regen_pct = data.bonus_mana_regen_pct
    self.spell_amp = data.spell_amp
end

function modifier_item_badun:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }
end

function modifier_item_badun:GetModifierBonusStats_Strength()
    if not self:GetAbility() then return end
    return self.bonus_str or 0
end

function modifier_item_badun:GetModifierBonusStats_Agility()
    if not self:GetAbility() then return end
    return self.bonus_agi or 0
end

function modifier_item_badun:GetModifierBonusStats_Intellect()
    if not self:GetAbility() then return end
    return self.bonus_int or 0
end

function modifier_item_badun:GetModifierManaBonus()
    if not self:GetAbility() then return end
    return self.bonus_mana or 0
end

function modifier_item_badun:GetModifierMPRegenAmplify_Percentage()
    if not self:GetAbility() then return end
    return self.bonus_mana_regen_pct
end

function modifier_item_badun:GetModifierSpellAmplify_Percentage()
    if not self:GetAbility() then return end
    return self.spell_amp or 0
end

modifier_item_badun_ethereal = class({})

function modifier_item_badun_ethereal:IsHidden() return false end
function modifier_item_badun_ethereal:IsPurgable() return true end
function modifier_item_badun_ethereal:RemoveOnDeath() return true end

function modifier_item_badun_ethereal:OnCreated(kv)
    self.parent  = self:GetParent()
    self.ability = self:GetAbility()
    self.caster  = self:GetCaster()

    if not self.ability or self.ability:IsNull() then return end

    self.is_ally = (kv and tonumber(kv.is_ally) == 1) or false

    self.move_slow = self.ability:GetSpecialValueFor("blast_movement_slow")
    self.ethereal_damage_bonus = self.ability:GetSpecialValueFor("ethereal_damage_bonus")

    if self.ethereal_damage_bonus == nil then self.ethereal_damage_bonus = 0 end
    self.incoming_spell_damage_pct = (self.ethereal_damage_bonus < 0) and (-self.ethereal_damage_bonus) or self.ethereal_damage_bonus
end

function modifier_item_badun_ethereal:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
    }
end

function modifier_item_badun_ethereal:GetAbsoluteNoDamagePhysical()
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return 0 end

    if parent:IsDebuffImmune() then
        return 0
    end

    return 1
end

function modifier_item_badun_ethereal:GetModifierMoveSpeedBonus_Percentage()
    if self.is_ally then return 0 end
    return self.move_slow or 0
end

function modifier_item_badun_ethereal:GetModifierIncomingDamage_Percentage(params)
    if not params then return 0 end

    local parent = self:GetParent()
    if not parent or parent:IsNull() then return 0 end
    if parent:IsDebuffImmune() then return 0 end

    if params.damage_type == DAMAGE_TYPE_MAGICAL then
        return self.incoming_spell_damage_pct or 0
    end
    return 0
end

function modifier_item_badun_ethereal:CheckState()
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return {} end

    if parent:IsDebuffImmune() then
        return {}
    end

    return {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
    }
end

function modifier_item_badun_ethereal:GetEffectName()
    return "particles/badun_effect.vpcf"
end

function modifier_item_badun_ethereal:GetStatusEffectName()
    return "particles/status_effect_badun.vpcf"
end

function modifier_item_badun_ethereal:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
