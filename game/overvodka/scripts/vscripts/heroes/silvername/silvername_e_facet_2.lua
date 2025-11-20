LinkLuaModifier("modifier_silvername_e_facet_2",        "heroes/silvername/silvername_e_facet_2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_silvername_e_facet_2_aura",   "heroes/silvername/silvername_e_facet_2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_silvername_e_facet_2_buff",   "heroes/silvername/silvername_e_facet_2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_silvername_e_facet_2_double", "heroes/silvername/silvername_e_facet_2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_silvername_e_facet_2_slow",   "heroes/silvername/silvername_e_facet_2", LUA_MODIFIER_MOTION_NONE)

silvername_e_facet_2 = class({})

function silvername_e_facet_2:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    caster:AddNewModifier(caster, self, "modifier_silvername_e_facet_2", { duration = self:GetSpecialValueFor("duration") })

    caster:EmitSound("Hero_Windrunner.Windrun")
end


modifier_silvername_e_facet_2 = class({})

function modifier_silvername_e_facet_2:IsPurgable()      return true end
function modifier_silvername_e_facet_2:IsDebuff()        return false end
function modifier_silvername_e_facet_2:IsBuff()          return true end
function modifier_silvername_e_facet_2:IsHidden()        return false end

function modifier_silvername_e_facet_2:IsAura()          return true end
function modifier_silvername_e_facet_2:IsAuraActiveOnDeath() return false end

function modifier_silvername_e_facet_2:GetAuraRadius()
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return 0 end
    return ability:GetSpecialValueFor("aura_radius")
end

function modifier_silvername_e_facet_2:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_silvername_e_facet_2:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_silvername_e_facet_2:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED
end

function modifier_silvername_e_facet_2:GetModifierAura()
    return "modifier_silvername_e_facet_2_aura"
end

function modifier_silvername_e_facet_2:GetAuraEntityReject(target)
    if not IsServer() then return false end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then
        return true
    end

    if target:IsBuilding() or target:IsOther() or target:IsWard() then
        return true
    end

    if target:GetPlayerOwnerID() ~= caster:GetPlayerOwnerID() then
        return true
    end

    return false
end

modifier_silvername_e_facet_2_aura = class({})

function modifier_silvername_e_facet_2_aura:IsHidden()   return true end
function modifier_silvername_e_facet_2_aura:IsPurgable() return false end

function modifier_silvername_e_facet_2_aura:OnCreated()
    if not IsServer() then return end

    local parent  = self:GetParent()
    local caster  = self:GetCaster()
    local ability = self:GetAbility()

    if not parent or parent:IsNull() then return end
    if not caster or caster:IsNull() then return end
    if not ability or ability:IsNull() then return end

    if not parent:HasModifier("modifier_silvername_e_facet_2_buff") then
        parent:AddNewModifier(caster, ability, "modifier_silvername_e_facet_2_buff", {})
    end
end

function modifier_silvername_e_facet_2_aura:OnDestroy()
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    parent:RemoveModifierByName("modifier_silvername_e_facet_2_buff")
end

modifier_silvername_e_facet_2_buff = class({})

function modifier_silvername_e_facet_2_buff:IsHidden()   return self:GetParent() == self:GetCaster() end
function modifier_silvername_e_facet_2_buff:IsPurgable() return false end
function modifier_silvername_e_facet_2_buff:IsDebuff()   return false end
function modifier_silvername_e_facet_2_buff:IsBuff()     return true end

function modifier_silvername_e_facet_2_buff:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_silvername_e_facet_2_buff:OnAttackLanded(params)
    if not IsServer() then return end

    local parent  = self:GetParent()
    if params.attacker ~= parent then
        return
    end

    local ability = self:GetAbility()
    if not ability or ability:IsNull() then
        return
    end
    
    local target  = params.target
    if not target or target:IsNull() then return end

    local chance = ability:GetSpecialValueFor("chance") or 0
    if chance <= 0 then return end
    if RollPercentage(chance) then
        parent:AddNewModifier(parent, ability, "modifier_silvername_e_facet_2_double", { duration = 2 })
        parent:AttackNoEarlierThan(0, 100)
    end
end


modifier_silvername_e_facet_2_double = class({})

function modifier_silvername_e_facet_2_double:IsHidden()   return true end
function modifier_silvername_e_facet_2_double:IsPurgable() return false end

function modifier_silvername_e_facet_2_double:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK,
    }
end

function modifier_silvername_e_facet_2_double:GetModifierAttackSpeedBonus_Constant()
    if IsClient() then return 0 end
    return 1000
end

function modifier_silvername_e_facet_2_double:OnAttack(params)
    if params.attacker == self:GetParent() then
        local parent  = self:GetParent()
        local ability = self:GetAbility()
        local target  = params.target
        if not ability or ability:IsNull() then return end
        if not target or target:IsNull() then return end

        local bonus_damage = ability:GetSpecialValueFor("bonus_damage") or 0

        if bonus_damage > 0 then
            ApplyDamage({victim = target, attacker = parent, damage = bonus_damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
        end

        local duration = ability:GetSpecialValueFor("slow_duration")

        if duration > 0 then
            target:AddNewModifier(parent, ability, "modifier_silvername_e_facet_2_slow", { duration = duration * (1 - target:GetStatusResistance()) })
        end
        self:Destroy()
    end
end


modifier_silvername_e_facet_2_slow = class({})

function modifier_silvername_e_facet_2_slow:IsHidden()   return false end
function modifier_silvername_e_facet_2_slow:IsPurgable() return true end
function modifier_silvername_e_facet_2_slow:IsDebuff()   return true end

function modifier_silvername_e_facet_2_slow:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_silvername_e_facet_2_slow:GetModifierMoveSpeedBonus_Percentage()
    return -self:GetAbility():GetSpecialValueFor("slow")
end
