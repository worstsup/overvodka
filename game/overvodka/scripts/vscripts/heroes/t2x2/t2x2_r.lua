LinkLuaModifier("modifier_t2x2_r_buff", "heroes/t2x2/t2x2_r", LUA_MODIFIER_MOTION_NONE)

t2x2_r = class({})

function t2x2_r:Precache(context)
    PrecacheResource("particle", "particles/t2x2_r_cast.vpcf", context)
    PrecacheResource("model", "models/items/lycan/ultimate/thegreatcalamityti4/thegreatcalamityti4.vmdl", context)
    PrecacheResource("soundfile", "soundevents/t2x2_sounds.vsndevts", context)
end

function t2x2_r:OnAbilityPhaseStart()
    self.particle = ParticleManager:CreateParticle( "particles/t2x2_r_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:SetParticleControl( self.particle, 0, self:GetCaster():GetAbsOrigin() )
	ParticleManager:SetParticleControl( self.particle, 3, self:GetCaster():GetAbsOrigin() )
    EmitSoundOn("t2x2_r_cast", self:GetCaster())
    return true
end

function t2x2_r:OnAbilityPhaseInterrupted()
	ParticleManager:DestroyParticle( self.particle, true )
	ParticleManager:ReleaseParticleIndex( self.particle )
    StopSoundOn("t2x2_r_cast", self:GetCaster())
end

function t2x2_r:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "modifier_t2x2_r_buff", { duration = self:GetSpecialValueFor("duration") })
    EmitSoundOn("t2x2_r_"..RandomInt(1,2), caster)
end


modifier_t2x2_r_buff = class({})

function modifier_t2x2_r_buff:IsHidden() return false end
function modifier_t2x2_r_buff:IsPurgable() return false end

function modifier_t2x2_r_buff:OnCreated()
    if not IsServer() then return end
end

function modifier_t2x2_r_buff:OnDestroy()
    if not IsServer() then return end
end

function modifier_t2x2_r_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_MODEL_SCALE,
    }
end

function modifier_t2x2_r_buff:GetModifierPreAttack_CriticalStrike()
    if (RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("crit_chance"), DOTA_PSEUDO_RANDOM_WOLF_CRIT, self:GetParent())) then
        return self:GetAbility():GetSpecialValueFor("crit_damage")
    end
end

function modifier_t2x2_r_buff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("speed")
end

function modifier_t2x2_r_buff:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_hp")
end

function modifier_t2x2_r_buff:GetModifierModelChange()
    return "models/items/lycan/ultimate/thegreatcalamityti4/thegreatcalamityti4.vmdl"
end

function modifier_t2x2_r_buff:GetModifierModelScale()
    return -20
end