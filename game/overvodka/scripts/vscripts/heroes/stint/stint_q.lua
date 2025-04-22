LinkLuaModifier("modifier_stint_q_barrier", "heroes/stint/stint_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stint_q_nelya",   "heroes/stint/stint_q", LUA_MODIFIER_MOTION_NONE)
stint_q = class({})

function stint_q:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    local barrier_modifier = self:GetCaster():FindModifierByName("modifier_stint_q_barrier")
    if barrier_modifier then
        barrier_modifier:Destroy()
    end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_stint_q_barrier", {duration = duration})
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_stint_q_nelya", {duration = duration})
end

modifier_stint_q_barrier = class({})

function modifier_stint_q_barrier:IsPurgable() return false end

function modifier_stint_q_barrier:OnCreated()
    if IsServer() then
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        self.shield = ability:GetSpecialValueFor("shield") * caster:GetMaxHealth() * 0.01
        self:SetStackCount(self.shield)
    end
end

function modifier_stint_q_barrier:OnRefresh()
    if IsServer() then
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        self.shield = ability:GetSpecialValueFor("shield") * caster:GetMaxHealth() * 0.01
        self:SetStackCount(self.shield)
    end
end

function modifier_stint_q_barrier:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT
    }
end

function modifier_stint_q_barrier:GetModifierIncomingDamageConstant(params)
    if IsClient() then 
        if params.report_max then 
            return self.shield 
        else 
            return self:GetStackCount()
        end 
    end
    if params.damage>=self:GetStackCount() then
        self:Destroy()
        return -self:GetStackCount()
    else
        self:SetStackCount(self:GetStackCount()-params.damage)
        return -params.damage
    end
end

modifier_stint_q_nelya = class({})

function modifier_stint_q_nelya:IsPurgable() return false end

function modifier_stint_q_nelya:OnCreated()
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local base_damage = ability:GetSpecialValueFor("base_damage")
    local level_damage = ability:GetSpecialValueFor("level_damage")
    self.damage = base_damage + level_damage * caster:GetLevel()
    self.as = 0.9 / ability:GetSpecialValueFor("hits")
end

function modifier_stint_q_nelya:OnRefresh()
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local base_damage = ability:GetSpecialValueFor("base_damage")
    local level_damage = ability:GetSpecialValueFor("level_damage")
    self.damage = base_damage + level_damage * caster:GetLevel()
    self.as = 1 / ability:GetSpecialValueFor("hits")
end

function modifier_stint_q_nelya:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
    }
end

function modifier_stint_q_nelya:GetModifierPreAttack_BonusDamage()
    return self.damage
end

function modifier_stint_q_nelya:GetModifierFixedAttackRate()
    return self.as
end

