LinkLuaModifier("modifier_peacemaker_e_facet_deagle",        "heroes/peacemaker/peacemaker_e_facet_deagle", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_peacemaker_e_facet_deagle_bleed",  "heroes/peacemaker/peacemaker_e_facet_deagle", LUA_MODIFIER_MOTION_NONE)

peacemaker_e_facet_deagle = class({})

function peacemaker_e_facet_deagle:Precache(ctx)
    PrecacheResource( "particle", "particles/peacemaker_e_facet1.vpcf", ctx )
    PrecacheResource( "particle", "particles/bloodseeker_rupture_new.vpcf", ctx )
    PrecacheResource( "soundfile", "soundevents/peacemaker_sounds.vsndevts", ctx )
end

function peacemaker_e_facet_deagle:GetIntrinsicModifierName()
    return "modifier_peacemaker_e_facet_deagle"
end

modifier_peacemaker_e_facet_deagle = class({})

function modifier_peacemaker_e_facet_deagle:IsHidden()   return true end
function modifier_peacemaker_e_facet_deagle:IsPurgable() return false end
function modifier_peacemaker_e_facet_deagle:IsDebuff()   return false end
function modifier_peacemaker_e_facet_deagle:IsBuff()     return true end

function modifier_peacemaker_e_facet_deagle:OnCreated()
    if not IsServer() then return end
    self.critProc            = false
    self.in_extra_attack     = false
    self.pending_bleed_targets = {}
end

function modifier_peacemaker_e_facet_deagle:OnRefresh()
    if not IsServer() then return end
    self.critProc            = false
    self.in_extra_attack     = false
    self.pending_bleed_targets = self.pending_bleed_targets or {}
end

function modifier_peacemaker_e_facet_deagle:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_peacemaker_e_facet_deagle:GetModifierPreAttack_CriticalStrike(params)
    if not IsServer() then return end

    local parent = self:GetParent()
    if parent:PassivesDisabled() then
        self.critProc = false
        return
    end

    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return end
    if params.attacker ~= parent then return end

    local target = params.target
    if not target or target:IsNull() then
        self.critProc = false
        return
    end
    if target:IsBuilding() or target:IsOther() or target:IsWard() then
        self.critProc = false
        return
    end

    if self.in_extra_attack then
        return
    end

    local chance = ability:GetSpecialValueFor("chance") or 0
    if chance <= 0 then
        self.critProc = false
        return
    end

    if RollPercentage(chance) then
        self.critProc = true
        local crit_mult = ability:GetSpecialValueFor("crit") or 100
        return crit_mult
    end

    self.critProc = false
end

function modifier_peacemaker_e_facet_deagle:OnAttack(params)
    if not IsServer() then return end

    local parent  = self:GetParent()
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return end
    if params.attacker ~= parent then return end

    if params.no_attack_cooldown then return end
    if not params.process_procs then return end
    if parent:PassivesDisabled() then return end
    if self.in_extra_attack then return end

    if not self.critProc then return end

    if not parent:HasTalent("special_bonus_unique_peacemaker_7") then return end

    local main_target = params.target
    if not main_target or main_target:IsNull() then return end

    local team   = parent:GetTeamNumber()
    local origin = parent:GetAbsOrigin()
    local range  = parent:Script_GetAttackRange()

    local enemies = FindUnitsInRadius(
        team,
        origin,
        nil,
        range,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
        FIND_CLOSEST,
        false
    )

    local extra_target = nil
    for _,enemy in ipairs(enemies) do
        if enemy ~= main_target
            and not enemy:IsNull()
            and enemy:IsAlive()
            and not enemy:IsOther()
            and not enemy:IsBuilding()
            and not enemy:IsWard()
        then
            extra_target = enemy
            break
        end
    end

    if not extra_target then return end

    self.pending_bleed_targets = self.pending_bleed_targets or {}
    local idx = extra_target:entindex()
    self.pending_bleed_targets[idx] = (self.pending_bleed_targets[idx] or 0) + 1

    self.in_extra_attack = true
    parent:PerformAttack(extra_target, false, true, true, false, true, false, false)
    self.in_extra_attack = false
end

function modifier_peacemaker_e_facet_deagle:OnAttackLanded(params)
    if not IsServer() then return end

    local parent  = self:GetParent()
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return end
    if params.attacker ~= parent then return end

    local target = params.target
    if not target or target:IsNull() then
        self.critProc = false
        return
    end
    if target:IsBuilding() or target:IsOther() or target:IsWard() then
        self.critProc = false
        return
    end

    local should_bleed_from_extra = false
    if self.pending_bleed_targets then
        local idx = target:entindex()
        local c = self.pending_bleed_targets[idx]
        if c and c > 0 then
            should_bleed_from_extra = true
            c = c - 1
            if c <= 0 then
                self.pending_bleed_targets[idx] = nil
            else
                self.pending_bleed_targets[idx] = c
            end
        end
    end

    if self.critProc or should_bleed_from_extra then
        self.critProc = false

        local base_duration = ability:GetSpecialValueFor("bleed_duration") or 0
        if base_duration <= 0 then return end

        local duration = base_duration * (1 - target:GetStatusResistance())
        if duration <= 0 then return end

        target:EmitSound("Peacemaker.Deagle.Crit")
        target:AddNewModifier(parent, ability, "modifier_peacemaker_e_facet_deagle_bleed", {duration = duration})

        local p = ParticleManager:CreateParticle("particles/peacemaker_e_facet1.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(p, 0, target:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(p)
    end
end

modifier_peacemaker_e_facet_deagle_bleed = class({})

function modifier_peacemaker_e_facet_deagle_bleed:IsHidden()   return false end
function modifier_peacemaker_e_facet_deagle_bleed:IsPurgable() return true end
function modifier_peacemaker_e_facet_deagle_bleed:IsDebuff()   return true end
function modifier_peacemaker_e_facet_deagle_bleed:IsBuff()     return false end

function modifier_peacemaker_e_facet_deagle_bleed:GetEffectName()
    return "particles/bloodseeker_rupture_new.vpcf"
end

function modifier_peacemaker_e_facet_deagle_bleed:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_peacemaker_e_facet_deagle_bleed:OnCreated(kv)
    self.caster  = self:GetCaster()
    self.parent  = self:GetParent()
    self.ability = self:GetAbility()

    self.interval = 0.5
    self.damage_per_tick = 0

    if self.ability and not self.ability:IsNull() then
        self.interval        = self.ability:GetSpecialValueFor("bleed_interval") or 0.5
        self.damage_per_tick = self.ability:GetSpecialValueFor("bleed_damage")   or 0
    end

    if self.interval <= 0 then
        self.interval = 0.5
    end

    if not IsServer() then return end

    self:StartIntervalThink(self.interval)
end

function modifier_peacemaker_e_facet_deagle_bleed:OnIntervalThink()
    if not IsServer() then return end

    if not self.ability or self.ability:IsNull() then
        self:Destroy()
        return
    end

    if not self.caster or self.caster:IsNull() then
        self:Destroy()
        return
    end

    if not self.parent or self.parent:IsNull() then
        self:Destroy()
        return
    end

    if not self.parent:IsAlive() then
        self:Destroy()
        return
    end

    local dmg = self.damage_per_tick * self.interval
    if dmg <= 0 then return end

    ApplyDamage({
        victim      = self.parent,
        attacker    = self.caster,
        damage      = dmg,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        ability     = self.ability,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
    })
end
