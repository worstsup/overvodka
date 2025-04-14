modifier_kachok_trenbolone = class({})

function modifier_kachok_trenbolone:IsHidden()
	return false
end

function modifier_kachok_trenbolone:IsBuff()
    return true
end

function modifier_kachok_trenbolone:IsPurgable()
	return false
end

function modifier_kachok_trenbolone:OnCreated( kv )
    local ability = self:GetAbility()
    self.bat = ability:GetSpecialValueFor("base_attack_time")
    self.attack_speed = ability:GetSpecialValueFor("bonus_as")
    self.range = ability:GetSpecialValueFor("bonus_range")

    if not IsServer() then return end

    local transformParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:ReleaseParticleIndex(transformParticle)
end

function modifier_kachok_trenbolone:OnRefresh( kv )
    self:OnCreated( kv )
end

function modifier_kachok_trenbolone:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_MODEL_CHANGE
    }
end

function modifier_kachok_trenbolone:GetModifierBaseAttackTimeConstant()
    return self.bat
end

function modifier_kachok_trenbolone:GetModifierAttackSpeedBonus_Constant()
    return self.attack_speed
end

function modifier_kachok_trenbolone:GetModifierAttackRangeBonus()
    return self.range
end

function modifier_kachok_trenbolone:GetModifierModelChange()
    return "models/items/warlock/golem/hellsworn_golem/hellsworn_golem.vmdl"
end