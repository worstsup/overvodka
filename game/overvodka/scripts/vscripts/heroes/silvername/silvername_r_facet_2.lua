LinkLuaModifier("modifier_silvername_r_facet_2_transformation", "heroes/silvername/silvername_r_facet_2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_silvername_r_facet_2_buff",           "heroes/silvername/silvername_r_facet_2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_silvername_r_facet_2_aura",           "heroes/silvername/silvername_r_facet_2", LUA_MODIFIER_MOTION_NONE)

silvername_r_facet_2 = class({})

function silvername_r_facet_2:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        caster
    )
    ParticleManager:ReleaseParticleIndex(particle)

    caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)
    caster:EmitSound("silvername_r_facet_2")

    local transform_time = self:GetSpecialValueFor("transformation_time")
    caster:AddNewModifier(caster, self, "modifier_silvername_r_facet_2_transformation", { duration = transform_time })
end

modifier_silvername_r_facet_2_transformation = class({})

function modifier_silvername_r_facet_2_transformation:IsPurgable() return false end
function modifier_silvername_r_facet_2_transformation:IsHidden()   return true  end
function modifier_silvername_r_facet_2_transformation:IsBuff()     return true  end
function modifier_silvername_r_facet_2_transformation:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_silvername_r_facet_2_transformation:OnCreated()
    if not IsServer() then return end

    local parent  = self:GetParent()
    local ability = self:GetAbility()

    if not parent or parent:IsNull() then return end
    if not ability or ability:IsNull() then return end

    local p = ParticleManager:CreateParticle("particles/silvername_r_facet_2_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:ReleaseParticleIndex(p)
    local p2 = ParticleManager:CreateParticle("particles/silvername_r_facet_2_cast2.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    self:AddParticle(p2, false, false, -1, false, false)
end

function modifier_silvername_r_facet_2_transformation:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
    }
end

function modifier_silvername_r_facet_2_transformation:OnDestroy()
    if not IsServer() then return end

    local parent  = self:GetParent()
    local ability = self:GetAbility()

    if not parent or parent:IsNull() then return end
    if not ability or ability:IsNull() then return end

    local duration = ability:GetSpecialValueFor("duration")
    parent:AddNewModifier(parent, ability, "modifier_silvername_r_facet_2_buff", { duration = duration })
end

modifier_silvername_r_facet_2_buff = class({})

function modifier_silvername_r_facet_2_buff:IsPurgable() return false end
function modifier_silvername_r_facet_2_buff:IsHidden()   return false end
function modifier_silvername_r_facet_2_buff:IsBuff()     return true  end
function modifier_silvername_r_facet_2_buff:RemoveOnDeath() return true end
function modifier_silvername_r_facet_2_buff:IsAuraActiveOnDeath() return false end
function modifier_silvername_r_facet_2_buff:IsAura() return true end
function modifier_silvername_r_facet_2_buff:GetAuraRadius() return 10000 end
function modifier_silvername_r_facet_2_buff:GetAuraDuration() return 0.1 end
function modifier_silvername_r_facet_2_buff:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_silvername_r_facet_2_buff:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_silvername_r_facet_2_buff:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED end
function modifier_silvername_r_facet_2_buff:GetModifierAura() return "modifier_silvername_r_facet_2_aura" end

function modifier_silvername_r_facet_2_buff:OnCreated()
    self.parent  = self:GetParent()
    self.ability = self:GetAbility()

    if not IsServer() then return end

    if not self.parent or self.parent:IsNull() then return end

    local p = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_lycan/lycan_shapeshift_buff.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        self.parent
    )
    ParticleManager:SetParticleControlEnt(p, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_head", self.parent:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(p, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_head", self.parent:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(p, 3, self.parent, PATTACH_POINT_FOLLOW, "attach_head", self.parent:GetAbsOrigin(), true)
    self:AddParticle(p, false, false, -1, false, false)
end

function modifier_silvername_r_facet_2_buff:OnDestroy()
    if not IsServer() then return end

    if not self.parent or self.parent:IsNull() then return end

    local revert_particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_lycan/lycan_shapeshift_revert.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        self.parent
    )
    ParticleManager:SetParticleControlEnt(revert_particle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_head", self.parent:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(revert_particle, 3, self.parent, PATTACH_POINT_FOLLOW, "attach_head", self.parent:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(revert_particle)
end

modifier_silvername_r_facet_2_aura = class({})

function modifier_silvername_r_facet_2_aura:IsPurgable()      return false end
function modifier_silvername_r_facet_2_aura:IsHidden()        return self:GetParent() == self:GetCaster() end
function modifier_silvername_r_facet_2_aura:IsBuff()          return true end
function modifier_silvername_r_facet_2_aura:RemoveOnDeath()   return true end
function modifier_silvername_r_facet_2_aura:IsAuraActiveOnDeath() return false end

function modifier_silvername_r_facet_2_aura:OnCreated()
    self.parent  = self:GetParent()
    self.caster  = self:GetCaster()
    self.ability = self:GetAbility()

    if not self.caster or self.caster:IsNull() then return end

    if self.parent:GetPlayerOwnerID() ~= self.caster:GetPlayerOwnerID() then
        if IsServer() then
            self:Destroy()
        end
        return
    end
end

function modifier_silvername_r_facet_2_aura:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
    }
end

function modifier_silvername_r_facet_2_aura:GetModifierPreAttack_CriticalStrike(params)
    local ability = self.ability
    if not ability or ability:IsNull() then return end

    local chance = ability:GetSpecialValueFor("crit_chance")
    local crit   = ability:GetSpecialValueFor("crit_damage")

    if chance <= 0 or crit <= 0 then return end

    if RollPseudoRandomPercentage(chance, DOTA_PSEUDO_RANDOM_WOLF_CRIT, self.parent) then
        return crit
    end
end

function modifier_silvername_r_facet_2_aura:GetModifierMoveSpeed_Limit()
    local ability = self.ability
    if not ability or ability:IsNull() then return 0 end
    return ability:GetSpecialValueFor("speed")
end

function modifier_silvername_r_facet_2_aura:GetModifierMoveSpeed_Absolute()
    local ability = self.ability
    if not ability or ability:IsNull() then return 0 end
    return ability:GetSpecialValueFor("speed")
end

function modifier_silvername_r_facet_2_aura:GetModifierMoveSpeedOverride()
    local ability = self.ability
    if not ability or ability:IsNull() then return 0 end
    return ability:GetSpecialValueFor("speed")
end

function modifier_silvername_r_facet_2_aura:GetEffectName()
    return "particles/silvername_r_facet_2.vpcf"
end

function modifier_silvername_r_facet_2_aura:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end