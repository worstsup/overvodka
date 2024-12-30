LinkLuaModifier("modifier_sasavot_r_new", "sasavot_r_new.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sasavot_r_new_secondary", "sasavot_r_new.lua", LUA_MODIFIER_MOTION_NONE)

sasavot_r_new = class({})

function sasavot_r_new:OnSpellStart()
    local target = self:GetCursorTarget()
    local caster = self:GetCaster()

    if target:TriggerSpellAbsorb(self) then return end
    EmitSoundOnClient("sasavot_r_new_start", self:GetCaster():GetPlayerOwner())
    target:AddNewModifier(caster, self, "modifier_sasavot_r_new", {duration = -1})
end

modifier_sasavot_r_new = class({})

function modifier_sasavot_r_new:IsDebuff() return true end
function modifier_sasavot_r_new:IsPurgable() return false end
function modifier_sasavot_r_new:IsHidden()
    return true
end
function modifier_sasavot_r_new:OnCreated()
    if not IsServer() then return end

    self.caster = self:GetCaster()
    self.target = self:GetParent()
    self:PlayEffects()
    self:StartIntervalThink(0.5)
end

function modifier_sasavot_r_new:OnIntervalThink()
    if not IsServer() then return end

    if self.target:IsAlive() and self.caster:IsAlive() then
        AddFOWViewer(self.caster:GetTeamNumber(), self.target:GetAbsOrigin(), 300, 0.5, false)
        AddFOWViewer(self.target:GetTeamNumber(), self.caster:GetAbsOrigin(), 300, 0.5, false)
    else
        self:Destroy()
    end
end

function modifier_sasavot_r_new:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end

function modifier_sasavot_r_new:OnTakeDamage(params)
    if params.attacker == self.target and params.unit ~= self.caster and params.unit:IsRealHero() then
        self.target:AddNewModifier(self.caster, self:GetAbility(), "modifier_sasavot_r_new_secondary", {duration = 30})
        self:Destroy()
    end
end

function modifier_sasavot_r_new:PlayEffects()
    local particle_cast = "particles/venomancer_noxious_contagion_buff_overhead_virus_new.vpcf"

    -- Create Particle
    local effect_cast = ParticleManager:CreateParticleForTeam( particle_cast, PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber() )

    -- buff particle
    self:AddParticle(
        effect_cast,
        false, -- bDestroyImmediately
        false, -- bStatusEffect
        -1, -- iPriority
        false, -- bHeroEffect
        false -- bOverheadEffect
    )
end

modifier_sasavot_r_new_secondary = class({})

function modifier_sasavot_r_new_secondary:IsDebuff() return true end
function modifier_sasavot_r_new_secondary:IsPurgable() return false end

function modifier_sasavot_r_new_secondary:OnCreated()
    self.Pct = 0
    self.t = 0
    self.radius = self:GetAbility():GetSpecialValueFor("radius")

    self:StartIntervalThink(0.5)

    if not IsServer() then return end

    self.caster = self:GetCaster()
    self.target = self:GetParent()
    self.durationPassed = 0
    self.damageDealt = false
    EmitSoundOn("sasavot_r_tick", self.target)
end
function modifier_sasavot_r_new_secondary:OnRefresh()
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
end
function modifier_sasavot_r_new_secondary:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }
    return funcs
end

function modifier_sasavot_r_new_secondary:GetModifierDamageOutgoing_Percentage()
    return self.Pct
end

function modifier_sasavot_r_new_secondary:GetBonusVisionPercentage( params )
    return self.Pct
end

function modifier_sasavot_r_new_secondary:OnTakeDamage(params)
    if params.attacker == self.target and params.unit == self.caster then
        self.damageDealt = true
        self:Destroy()
    end
end

function modifier_sasavot_r_new_secondary:OnIntervalThink()
    self.t = self.t + 1
    if self.t == 10 then
        self.Pct = self.Pct - 20
        self.t = 0
    end
    if not IsServer() then return end
    if not self.target:IsAlive() or not self.caster:IsAlive() then
        self:Destroy()
        return
    end
    AddFOWViewer(self.target:GetTeamNumber(), self.caster:GetAbsOrigin(), 300, 0.5, false)
    AddFOWViewer(self.caster:GetTeamNumber(), self.target:GetAbsOrigin(), 300 + self.durationPassed * 10, 0.5, false)
    self.durationPassed = self.durationPassed + 0.5
    local distance = (self.target:GetAbsOrigin() - self.caster:GetAbsOrigin()):Length2D()
    if distance > self.radius then
        self:Destroy()
    end
end

function modifier_sasavot_r_new_secondary:OnDestroy()
    if not IsServer() then return end
    StopSoundOn("sasavot_r_tick", self.target)
    local distance = (self.target:GetAbsOrigin() - self.caster:GetAbsOrigin()):Length2D()
    if self.durationPassed >= 29 and distance <= self.radius and not self.damageDealt then
        self.target:Kill(self:GetAbility(), self.caster)
        EmitGlobalSound("sasavot_r_success")
    end
end
function modifier_sasavot_r_new_secondary:GetEffectName()
    return "particles/units/heroes/hero_demonartist/hero_demonartist_track_shield.vpcf"
end

function modifier_sasavot_r_new_secondary:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end