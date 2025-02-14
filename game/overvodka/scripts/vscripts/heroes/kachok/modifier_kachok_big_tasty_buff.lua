PARTICLE_BUFF = "particles/units/heroes/hero_lycan/lycan_shapeshift_buff.vpcf"
PARTICLE_REVERT = "particles/units/heroes/hero_lycan/lycan_shapeshift_revert.vpcf"

modifier_kachok_big_tasty_buff = class({})

function modifier_kachok_big_tasty_buff:GetAttributes()
    return MODIFIER_ATTRIBUTE_NONE
end

function modifier_kachok_big_tasty_buff:IsPurgable()
    return false
end

function modifier_kachok_big_tasty_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
    }
end

function modifier_kachok_big_tasty_buff:OnCreated()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    if not IsServer() then return end
    self.particle = ParticleManager:CreateParticle(PARTICLE_BUFF, PATTACH_ABSORIGIN_FOLLOW, self.parent)
end

function modifier_kachok_big_tasty_buff:OnDestroy()
    if not IsServer() then return end
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
    local revert_particle = ParticleManager:CreateParticle(PARTICLE_REVERT, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:ReleaseParticleIndex(revert_particle)
end

function modifier_kachok_big_tasty_buff:GetModifierPreAttack_CriticalStrike()
    if (RollPseudoRandomPercentage(self.ability:GetSpecialValueFor("crit_chance"), DOTA_PSEUDO_RANDOM_WOLF_CRIT, self.parent)) then
        return self.ability:GetSpecialValueFor("crit_damage")
    end
end

function modifier_kachok_big_tasty_buff:GetBonusNightVision()
    return self.ability:GetSpecialValueFor("bonus_night_vision")
end

function modifier_kachok_big_tasty_buff:GetModifierMoveSpeed_Limit()
    return self.ability:GetSpecialValueFor("speed")
end

function modifier_kachok_big_tasty_buff:GetModifierMoveSpeed_Absolute()
    return self.ability:GetSpecialValueFor("speed")
end

function modifier_kachok_big_tasty_buff:GetModifierMoveSpeedOverride()
    return self.ability:GetSpecialValueFor("speed")
end