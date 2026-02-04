LinkLuaModifier("modifier_amor_innate_handler", "heroes/amor/amor_innate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_amor_innate_buff",    "heroes/amor/amor_innate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_amor_innate_charges", "heroes/amor/amor_innate", LUA_MODIFIER_MOTION_NONE)

amor_innate = class({})

function amor_innate:GetIntrinsicModifierName()
    return "modifier_amor_innate_handler"
end

modifier_amor_innate_handler = class({})

function modifier_amor_innate_handler:IsHidden() return true end
function modifier_amor_innate_handler:IsPurgable() return false end
function modifier_amor_innate_handler:RemoveOnDeath() return false end

function modifier_amor_innate_handler:OnCreated()
    if not IsServer() then return end

    self.ability = self:GetAbility()
    self.parent  = self:GetParent()
    self.last_level = (self:GetAbility() and self:GetAbility():GetLevel()) or 0
    self.was_below = false
    self:StartIntervalThink(0.1)
end

function modifier_amor_innate_handler:OnIntervalThink()
    if not IsServer() then return end

    local ability = self:GetAbility()
    local parent = self:GetParent()
    if not ability or ability:IsNull() then return end
    if not parent or parent:IsNull() then return end
    if not parent:IsRealHero() or parent:IsIllusion() then return end
    local lvl = ability:GetLevel() or 0
    if lvl ~= (self.last_level or 0) then
        self.last_level = lvl
        local mod_f = parent:FindModifierByName("modifier_amor_f")
        if mod_f and not mod_f:IsNull() then
            mod_f:_SyncFromInnate(true)
        end
    end
    if not parent:IsAlive() then return end
    if parent:PassivesDisabled() then
        self.was_below = (parent:GetHealthPercent() <= (ability:GetSpecialValueFor("hp_threshold_pct") or 40))
        return
    end

    local threshold = ability:GetSpecialValueFor("hp_threshold_pct") or 40
    local below = (parent:GetHealthPercent() <= threshold)

    if not below then
        self.was_below = false
        return
    end

    if self.was_below then return end
    self.was_below = true

    if not ability:IsCooldownReady() then return end

    parent:Purge(false, true, false, false, false)

    local dur = ability:GetSpecialValueFor("buff_duration")
    if dur <= 0 then dur = 4 end

    parent:AddNewModifier(parent, ability, "modifier_amor_innate_buff", { duration = dur })

    local charges = parent:FindModifierByName("modifier_amor_innate_charges")
    if not charges or charges:IsNull() then
        charges = parent:AddNewModifier(parent, ability, "modifier_amor_innate_charges", {})
    end
    if charges and not charges:IsNull() then
        charges:AddCharge()
    end

    local p = ParticleManager:CreateParticle("particles/jugg_fall20_immortal_healing_ward_death_sparks_flash.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:ReleaseParticleIndex(p)
    ability:UseResources(false, false, false, true)
    parent:EmitSound("amor_innate")
end

modifier_amor_innate_buff = class({})

function modifier_amor_innate_buff:IsHidden() return false end
function modifier_amor_innate_buff:IsPurgable() return false end

function modifier_amor_innate_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_amor_innate_buff:GetModifierConstantHealthRegen()
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return 0 end
    return ability:GetSpecialValueFor("bonus_regen")
end

function modifier_amor_innate_buff:GetModifierMoveSpeedBonus_Percentage()
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return 0 end
    return ability:GetSpecialValueFor("bonus_ms_pct")
end

function modifier_amor_innate_buff:GetEffectName()
    return "particles/units/heroes/hero_largo/largo_catchy_lick_heal.vpcf"
end

function modifier_amor_innate_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


modifier_amor_innate_charges = class({})

function modifier_amor_innate_charges:IsHidden() return false end
function modifier_amor_innate_charges:IsPurgable() return false end
function modifier_amor_innate_charges:RemoveOnDeath() return false end
function modifier_amor_innate_charges:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_amor_innate_charges:AllowIllusionDuplicate() return true end

function modifier_amor_innate_charges:OnCreated()
    self._total_gold = self._total_gold or 0
    self._total_dmg = self._total_dmg or 0
    self._total_as = self._total_as or 0

    if not IsServer() then return end
    self._txData = self._txData or {}
    self:SetHasCustomTransmitterData(true)
    self:SendBuffRefreshToClients()
end

function modifier_amor_innate_charges:AddCustomTransmitterData()
    self._txData.tg = self._total_gold or 0
    self._txData.td = self._total_dmg or 0
    self._txData.ta = self._total_as or 0
    return self._txData
end

function modifier_amor_innate_charges:HandleCustomTransmitterData(data)
    if not data then return end
    self._total_gold = tonumber(data.tg) or 0
    self._total_dmg = tonumber(data.td) or 0
    self._total_as = tonumber(data.ta) or 0
end

function modifier_amor_innate_charges:AddCharge()
    if not IsServer() then return end

    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return end

    local add_gold = ability:GetSpecialValueFor("bonus_gold_per_charge") or 0
    local add_dmg = ability:GetSpecialValueFor("bonus_damage_per_charge") or 0
    local add_as = ability:GetSpecialValueFor("bonus_as_per_charge") or 0

    if GetMapName() == "overvodka_5x5" then
        add_gold = math.floor(add_gold / 2)
        add_dmg = math.floor(add_dmg / 2)
        add_as = math.floor(add_as / 2)
    end

    self._total_gold = (self._total_gold or 0) + add_gold
    self._total_dmg = (self._total_dmg or 0) + add_dmg
    self._total_as = (self._total_as or 0) + add_as

    self:IncrementStackCount()
    self:SendBuffRefreshToClients()
end

function modifier_amor_innate_charges:GetGoldBonusTotal()
    return self._total_gold or 0
end

function modifier_amor_innate_charges:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_amor_innate_charges:GetModifierPreAttack_BonusDamage()
    return self._total_dmg or 0
end

function modifier_amor_innate_charges:GetModifierAttackSpeedBonus_Constant()
    return self._total_as or 0
end

function modifier_amor_innate_charges:OnTooltip()
    return self._total_gold or 0
end

function modifier_amor_innate_charges:OnStackCountChanged(iOldCount)
    if not IsServer() then return end
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    local mod_f = parent:FindModifierByName("modifier_amor_f")
    if mod_f and not mod_f:IsNull() then
        mod_f:_SyncFromInnate(true)
    end
end
