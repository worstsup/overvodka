LinkLuaModifier("modifier_peacemaker_e_facet_magic_poison", "heroes/peacemaker/peacemaker_e_facet_magic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_peacemaker_e_facet_magic_sleep",  "heroes/peacemaker/peacemaker_e_facet_magic", LUA_MODIFIER_MOTION_NONE)

peacemaker_e_facet_magic = class({})

function peacemaker_e_facet_magic:Precache(ctx)
    PrecacheResource("particle", "particles/peacemaker_e_facet2.vpcf", ctx)
    PrecacheResource("particle", "particles/peacemaker_e_facet2_damage.vpcf", ctx)
    PrecacheResource("particle", "particles/peacemaker_e_facet2_sleep.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/peacemaker_sounds.vsndevts", ctx)
end

function peacemaker_e_facet_magic:OnAbilityPhaseStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("Peacemaker.Dart.Cast")
    return true
end

function peacemaker_e_facet_magic:OnAbilityPhaseInterrupted()
    if not IsServer() then return end
    self:GetCaster():StopSound("Peacemaker.Dart.Cast")
end

function peacemaker_e_facet_magic:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if not target or target:IsNull() then return end

    local info = {
        Target = target,
        Source = caster,
        Ability = self,
        EffectName = "particles/peacemaker_e_facet2.vpcf",
        iMoveSpeed = 900,
        bDodgeable = true,
        bProvidesVision = true,
        iVisionRadius = 300,
        iVisionTeamNumber = caster:GetTeamNumber(),
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
    }

    ProjectileManager:CreateTrackingProjectile(info)
end

function peacemaker_e_facet_magic:OnProjectileHit(target, location)
    if not IsServer() then return end
    if not target or target:IsNull() then return end
    if not target:IsAlive() then return end
    if target:TriggerSpellAbsorb(self) then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local status_mult = 1 - target:GetStatusResistance()

    local poison_duration = (self:GetSpecialValueFor("poison_duration") or 0) * status_mult
    local sleep_duration  = (self:GetSpecialValueFor("sleep_duration")  or 0) * status_mult

    target:AddNewModifier(caster, self, "modifier_peacemaker_e_facet_magic_poison", {duration = poison_duration})
    target:AddNewModifier(caster, self, "modifier_peacemaker_e_facet_magic_sleep", {duration = sleep_duration})

    target:EmitSound("Peacemaker.Dart.Hit")
end

modifier_peacemaker_e_facet_magic_poison = class({})

function modifier_peacemaker_e_facet_magic_poison:IsHidden()      return false end
function modifier_peacemaker_e_facet_magic_poison:IsDebuff()      return true end
function modifier_peacemaker_e_facet_magic_poison:IsPurgable()    return true end
function modifier_peacemaker_e_facet_magic_poison:IsBuff()        return false end

function modifier_peacemaker_e_facet_magic_poison:OnCreated(kv)
    self.caster  = self:GetCaster()
    self.parent  = self:GetParent()
    self.ability = self:GetAbility()

    self.tick_interval = 0.5
    self.damage_per_sec = 0

    if self.ability and not self.ability:IsNull() then
        self.tick_interval  = self.ability:GetSpecialValueFor("poison_interval") or 0.5
        self.damage_per_sec = self.ability:GetSpecialValueFor("poison_dps")      or 0
    end

    if not IsServer() then return end
    local p = ParticleManager:CreateParticle("particles/peacemaker_e_facet2_damage.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    self:AddParticle(p, false, false, -1, false, false)
    self:StartIntervalThink(self.tick_interval)
end

function modifier_peacemaker_e_facet_magic_poison:OnIntervalThink()
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

    local dmg = self.damage_per_sec * self.tick_interval
    if dmg <= 0 then return end

    ApplyDamage({
        victim       = self.parent,
        attacker     = self.caster,
        damage       = dmg,
        damage_type  = DAMAGE_TYPE_MAGICAL,
        ability      = self.ability,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
    })
end


modifier_peacemaker_e_facet_magic_sleep = class({})

function modifier_peacemaker_e_facet_magic_sleep:IsHidden()         return false end
function modifier_peacemaker_e_facet_magic_sleep:IsDebuff()         return true end
function modifier_peacemaker_e_facet_magic_sleep:IsPurgable()       return true end
function modifier_peacemaker_e_facet_magic_sleep:IsStunDebuff()     return false end
function modifier_peacemaker_e_facet_magic_sleep:GetAttributes()    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_peacemaker_e_facet_magic_sleep:OnCreated(kv)
    self.rate = 1.0
    if not IsServer() then
        return
    end

    self.ability = self:GetAbility()
    self.parent  = self:GetParent()
    self.caster  = self:GetCaster()

    self.threshold   = 0
    self.damageTaken = 0

    if self.ability and not self.ability:IsNull() then
        self.threshold = self.ability:GetSpecialValueFor("wake_damage") or 0
    end

    if not IsServer() then return end
    self:UpdateRemainingDamageStacks()
end

function modifier_peacemaker_e_facet_magic_sleep:OnRefresh(kv)
    if not IsServer() then return end

    if self.ability and not self.ability:IsNull() then
        self.threshold = self.ability:GetSpecialValueFor("wake_damage") or self.threshold or 0
    end

    if not IsServer() then return end
    self:UpdateRemainingDamageStacks()
end

function modifier_peacemaker_e_facet_magic_sleep:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_peacemaker_e_facet_magic_sleep:GetOverrideAnimation()
    return ACT_DOTA_DISABLED
end

function modifier_peacemaker_e_facet_magic_sleep:GetOverrideAnimationRate()
    return self.rate
end

function modifier_peacemaker_e_facet_magic_sleep:CheckState()
    return {
        [MODIFIER_STATE_NIGHTMARED] = true,
        [MODIFIER_STATE_STUNNED]    = true,
    }
end

function modifier_peacemaker_e_facet_magic_sleep:GetEffectName()
    return "particles/peacemaker_e_facet2_sleep.vpcf"
end

function modifier_peacemaker_e_facet_magic_sleep:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_peacemaker_e_facet_magic_sleep:GetStatusEffectName()
    return "particles/status_fx/status_effect_siren_song.vpcf"
end

function modifier_peacemaker_e_facet_magic_sleep:StatusEffectPriority()
    return MODIFIER_PRIORITY_NORMAL
end

function modifier_peacemaker_e_facet_magic_sleep:UpdateRemainingDamageStacks()
    if not IsServer() then return end

    if not self.threshold or self.threshold <= 0 then
        self:SetStackCount(0)
        return
    end

    local taken = self.damageTaken or 0
    local remaining = self.threshold - taken

    remaining = math.max(0, math.ceil(remaining))

    self:SetStackCount(remaining)
end

function modifier_peacemaker_e_facet_magic_sleep:OnTakeDamage(params)
    if not IsServer() then return end

    if params.unit ~= self:GetParent() then return end
    if params.damage <= 0 then return end
    if params.inflictor == self:GetAbility() then return end

    self.damageTaken = (self.damageTaken or 0) + params.damage

    self:UpdateRemainingDamageStacks()

    if self.threshold > 0 and self.damageTaken > self.threshold then
        self:Destroy()
    end
end
