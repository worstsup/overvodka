LinkLuaModifier("modifier_sasavot_r_new", "sasavot_r_new.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sasavot_r_new_secondary", "sasavot_r_new.lua", LUA_MODIFIER_MOTION_NONE)

sasavot_r_new = class({})

function sasavot_r_new:OnSpellStart()
    local target = self:GetCursorTarget()
    local caster = self:GetCaster()

    if target:TriggerSpellAbsorb(self) then return end
    target:AddNewModifier(caster, self, "modifier_sasavot_r_new", {duration = -1})
    EmitSoundOn("Hero_BountyHunter.Track", target)
end

modifier_sasavot_r_new = class({})

function modifier_sasavot_r_new:IsDebuff() return true end
function modifier_sasavot_r_new:IsPurgable() return false end

function modifier_sasavot_r_new:OnCreated()
    if not IsServer() then return end

    self.caster = self:GetCaster()
    self.target = self:GetParent()
    EmitSoundOn("sasavot_r_new_start", self.target)
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
    if params.attacker == self.target and params.unit ~= self.caster and params.unit:IsOpposingTeam(self.caster:GetTeamNumber()) then
        self.target:AddNewModifier(self.caster, self:GetAbility(), "modifier_sasavot_r_new_secondary", {duration = 60})
        self:Destroy()
    end
end
function modifier_sasavot_r_new:GetEffectName()
    return "particles/venomancer_noxious_contagion_buff_overhead_virus_new.vpcf"
end

function modifier_sasavot_r_new:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

modifier_sasavot_r_new_secondary = class({})

function modifier_sasavot_r_new_secondary:IsDebuff() return true end
function modifier_sasavot_r_new_secondary:IsPurgable() return false end

function modifier_sasavot_r_new_secondary:OnCreated()
    if not IsServer() then return end

    self.caster = self:GetCaster()
    self.target = self:GetParent()
    self.durationPassed = 0
    self.damageDealt = false
    self:StartIntervalThink(0.5)
    self.vision = 0
    t = 0
    EmitSoundOn("sasavot_r_tick", self.target)
    self:SetHasCustomTransmitterData(true)
    self.slow = 50
end
function modifier_sasavot_r_new_secondary:OnRefresh()
    if (not IsServer()) then
        return
    end
    self.bonusDmgPct = -10
end
function modifier_sasavot_r_new_secondary:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end
function modifier_sasavot_r_new_secondary:GetModifierMoveSpeedBonus_Percentage()
    return -self.slow
end
function modifier_sasavot_r_new_secondary:AddCustomTransmitterData()
    local data = {
        slow = self.slow
    }

    return data
end

function modifier_sasavot_r_new_secondary:HandleCustomTransmitterData(data)
    self.slow = data.slow
end

function modifier_sasavot_r_new_secondary:GetBonusDayVision( params )
    return self.vision
end

function modifier_sasavot_r_new_secondary:GetBonusNightVision( params )
    return self.vision
end 

function modifier_sasavot_r_new_secondary:OnTakeDamage(params)
    if params.attacker == self.target and params.unit == self.caster then
        self.damageDealt = true
        self:Destroy()
    end
end

function modifier_sasavot_r_new_secondary:OnIntervalThink()
    if not IsServer() then return end
    if not self.target:IsAlive() or not self.caster:IsAlive() then
        self:Destroy()
        return
    end
    t = t + 1
    AddFOWViewer(self.caster:GetTeamNumber(), self.target:GetAbsOrigin(), 300 + self.durationPassed * 10, 0.5, false)
    self.durationPassed = self.durationPassed + 0.5
    if t == 10 then
        self.vision = self.vision - 100
        t = 0
    end
    local distance = (self.target:GetAbsOrigin() - self.caster:GetAbsOrigin()):Length2D()
    if distance > 3000 then
        self:Destroy()
    end
end

function modifier_sasavot_r_new_secondary:OnDestroy()
    if not IsServer() then return end
    StopSoundOn("sasavot_r_tick", self.target)
    local distance = (self.target:GetAbsOrigin() - self.caster:GetAbsOrigin()):Length2D()
    if self.durationPassed >= 59 and distance <= 3000 and not self.damageDealt then
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