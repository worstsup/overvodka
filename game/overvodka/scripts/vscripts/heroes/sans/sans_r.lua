sans_r = class({})
LinkLuaModifier( "modifier_sans_r", "heroes/sans/sans_r", LUA_MODIFIER_MOTION_NONE )
k = 0

function sans_r:Precache(context)
    PrecacheResource( "soundfile", "soundevents/sans_r_1.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/sans_r_2.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/sans_r_3.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/sans_arcana.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/sans_r_start_1.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/sans_r_start_2.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/sans_r_start_3.vsndevts", context )
    PrecacheResource( "particle", "particles/sans_r.vpcf", context)
    PrecacheResource( "particle", "particles/sans_r_arcana.vpcf", context )
end

function sans_r:GetAbilityTextureName()
    if self:GetCaster():HasArcana() then
        return "sans_r_arcana"
    end
    return "sans_r"
end

function sans_r:OnAbilityPhaseStart()
    if self:GetCaster():HasArcana() then
        if k % 2 == 0 then
            EmitSoundOn( "sans_r_start_2_arcana", self:GetCaster())
        else
            EmitSoundOn( "sans_r_start_1_arcana", self:GetCaster() )
        end
    else
        if k % 3 == 0 then
            EmitSoundOn( "sans_r_start_1", self:GetCaster() )
        elseif k % 3 == 1 then
            EmitSoundOn( "sans_r_start_2", self:GetCaster() )
        elseif k % 3 == 2 then
            EmitSoundOn( "sans_r_start_3", self:GetCaster() )
        end
    end
    return true
end

function sans_r:OnSpellStart()
    if not IsServer() then return end
    if self:GetCaster():HasArcana() then
        if k % 2 == 0 then
            EmitSoundOn( "sans_r_2_arcana", self:GetCaster() )
        else
            EmitSoundOn( "sans_r_1_arcana", self:GetCaster() )
        end
    else
        if k % 3 == 0 then
            EmitSoundOn( "sans_r_1", self:GetCaster() )
        elseif k % 3 == 1 then
            EmitSoundOn( "sans_r_2", self:GetCaster() )
        elseif k % 3 == 2 then
            EmitSoundOn( "sans_r_3", self:GetCaster() )
        end
    end
    k = k + 1
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_sans_r", { duration = self:GetSpecialValueFor( "duration" ) } )
end

modifier_sans_r = class({})

function modifier_sans_r:IsPurgable()
    return false
end

function modifier_sans_r:OnCreated()
    if not IsServer() then return end
    local particle_name = "particles/sans_r.vpcf"
    if self:GetCaster():HasArcana() then
        particle_name = "particles/sans_r_arcana.vpcf"
    end
    self.particle = ParticleManager:CreateParticle( particle_name, PATTACH_CUSTOMORIGIN, self:GetParent() )
    ParticleManager:SetParticleControlEnt( self.particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_eye_l", self:GetParent():GetAbsOrigin(), true )
end

function modifier_sans_r:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
    }
end

function modifier_sans_r:GetModifierMoveSpeedBonus_Percentage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_ms")
    end
    return 0
end

function modifier_sans_r:GetModifierPercentageCooldown()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("cooldown_reduction")
    end
    return 0
end

function modifier_sans_r:OnDestroy()
    if not IsServer() then return end
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end