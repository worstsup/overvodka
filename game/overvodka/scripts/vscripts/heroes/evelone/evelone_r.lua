LinkLuaModifier("modifier_evelone_r", "heroes/evelone/evelone_r.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_evelone_r_debuff", "heroes/evelone/evelone_r.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_evelone_r_aura", "heroes/evelone/evelone_r.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_silenced_lua", "modifier_generic_silenced_lua.lua", LUA_MODIFIER_MOTION_NONE)

num = 0

evelone_r = class({})

function evelone_r:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_night_stalker/nightstalker_ulti.vpcf", context)
    PrecacheResource("particle", "particles/evelone_r_aura.vpcf", context)
    PrecacheResource("particle", "particles/evelone_r_effect.vpcf", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_nightstalker.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/evelone_r_1.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/evelone_r_2.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/evelone_r_3.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/evelone_r_ambient.vsndevts", context)
end

function evelone_r:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")

    local cast_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_ulti.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:ReleaseParticleIndex(cast_particle)
    
    caster:AddNewModifier(caster, self, "modifier_evelone_r", {duration = duration})
    EmitGlobalSound("Hero_Nightstalker.Darkness")
    EmitGlobalSound("evelone_r_ambient")
    if num % 3 == 0 then
        EmitGlobalSound("evelone_r_1")
    end
    if num % 3 == 1 then
        EmitGlobalSound("evelone_r_2")
    end
    if num % 3 == 2 then
        EmitGlobalSound("evelone_r_3")
    end
    num = num + 1
end

function evelone_r:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level)
end

function evelone_r:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

modifier_evelone_r = class({})

function modifier_evelone_r:IsHidden() return false end
function modifier_evelone_r:IsPurgable() return false end
function modifier_evelone_r:RemoveOnDeath() return false end

function modifier_evelone_r:OnCreated()
    if IsServer() then
        GameRules:SetTimeOfDay(0)
        self:StartIntervalThink(0.5)
        self.particle = ParticleManager:CreateParticle("particles/evelone_r_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        self.particle_2 = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(self.particle_2, 2, Vector(self.radius, self.radius, self.radius))
        self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_evelone_r_aura", {duration = self:GetDuration()})
    end
end

function modifier_evelone_r:OnIntervalThink()
    if IsServer() then
        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            self:GetCaster():GetAbsOrigin(),
            nil,
            FIND_UNITS_EVERYWHERE,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )
        
        for _, enemy in pairs(enemies) do
            enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_evelone_r_debuff", {duration = 0.75})
        end
    end
end

function modifier_evelone_r:OnDestroy()
    if IsServer() then
        GameRules:SetTimeOfDay(0.5)
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
        ParticleManager:DestroyParticle(self.particle_2, false)
        ParticleManager:ReleaseParticleIndex(self.particle_2)
    end
end

function modifier_evelone_r:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_evelone_r:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_movespeed")
end

function modifier_evelone_r:CheckState()
    return {
        [MODIFIER_STATE_FLYING] = true
    }
end

function modifier_evelone_r:GetEffectName()
    return "particles/evelone_r_aura.vpcf"
end

function modifier_evelone_r:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_evelone_r_aura = class({})

function modifier_evelone_r_aura:IsHidden() return true end
function modifier_evelone_r_aura:IsPurgable() return false end
function modifier_evelone_r_aura:IsAura() return true end
function modifier_evelone_r_aura:OnCreated()
    if IsServer() then
        self.radius = self:GetAbility():GetSpecialValueFor("silence_radius")
    end
end

function modifier_evelone_r_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_evelone_r_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_evelone_r_aura:GetModifierAura()
    return "modifier_generic_silenced_lua"
end

function modifier_evelone_r_aura:GetAuraRadius()
    return self.radius
end

function modifier_evelone_r_aura:OnDestroy()
end

modifier_evelone_r_debuff = class({})

function modifier_evelone_r_debuff:IsHidden() return true end
function modifier_evelone_r_debuff:IsPurgable() return false end

function modifier_evelone_r_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION
    }
end

function modifier_evelone_r_debuff:GetBonusDayVision()
    return -self:GetAbility():GetSpecialValueFor("vision_reduction")
end

function modifier_evelone_r_debuff:GetBonusNightVision()
    return -self:GetAbility():GetSpecialValueFor("vision_reduction")
end