LinkLuaModifier("modifier_epstein_e_active", "heroes/epstein/epstein_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_e_damage", "heroes/epstein/epstein_e", LUA_MODIFIER_MOTION_NONE)

epstein_e = class({})

function epstein_e:OnToggle()
    local caster = self:GetCaster()
    local toggle = self:GetToggleState()

    if toggle then
        self.modifier = caster:AddNewModifier(caster, self, "modifier_epstein_e_active", {})
        self:EndCooldown()
    else
        if self.modifier and not self.modifier:IsNull() then
            self.modifier:Destroy()
        end
        self.modifier = nil
        self:UseResources(false, false, false, true)
    end
end

modifier_epstein_e_active = class({})

function modifier_epstein_e_active:IsHidden() return false end
function modifier_epstein_e_active:IsDebuff() return false end
function modifier_epstein_e_active:IsPurgable() return false end

function modifier_epstein_e_active:OnCreated()
    local ability = self:GetAbility()
    if not ability then
        self:Destroy()
        return
    end

    self.move_speed_bonus_pct = ability:GetSpecialValueFor("move_speed_bonus_pct")
    self.damage_per_sec = ability:GetSpecialValueFor("damage_per_sec")
    self.max_bonus_damage = ability:GetSpecialValueFor("max_bonus_damage")
    self.hold_duration = ability:GetSpecialValueFor("hold_duration")

    if not IsServer() then return end

    self:SetStackCount(0)
    self:StartIntervalThink(1.0)
    self:OnIntervalThink()

    self:GetParent():EmitSound("epstein_dance")
end

function modifier_epstein_e_active:OnIntervalThink()
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not parent or parent:IsNull() or not IsValidEntity(parent) then
        self:Destroy()
        return
    end
    if not ability then
        self:Destroy()
        return
    end

    local add = self.damage_per_sec or 0
    local cap = self.max_bonus_damage or 0
    if add <= 0 or cap <= 0 then return end

    local new = self:GetStackCount() + add
    if new > cap then new = cap end
    self:SetStackCount(new)
end

function modifier_epstein_e_active:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_epstein_e_active:GetModifierMoveSpeedBonus_Percentage()
    return self.move_speed_bonus_pct or 0
end

function modifier_epstein_e_active:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount()
end

function modifier_epstein_e_active:GetOverrideAnimation()
    return ACT_DOTA_DANCE
end

function modifier_epstein_e_active:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true,
    }
end

function modifier_epstein_e_active:OnDestroy()
    if not IsServer() then return end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not parent or parent:IsNull() or not IsValidEntity(parent) then return end
    if not ability then return end

    parent:StopSound("epstein_dance")

    if not parent:IsAlive() then return end

    local stacks = self:GetStackCount()
    if stacks <= 0 then return end

    local buff = parent:AddNewModifier(parent, ability, "modifier_epstein_e_damage", { duration = self.hold_duration })
    if buff and not buff:IsNull() then
        buff:SetStackCount(stacks)
    end
end

modifier_epstein_e_damage = class({})

function modifier_epstein_e_damage:IsHidden() return false end
function modifier_epstein_e_damage:IsDebuff() return false end
function modifier_epstein_e_damage:IsPurgable() return false end

function modifier_epstein_e_damage:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_epstein_e_damage:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_epstein_e_damage:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount()
end
