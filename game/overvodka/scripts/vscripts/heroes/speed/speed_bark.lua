LinkLuaModifier( "modifier_speed_bark_effect", "heroes/speed/speed_bark", LUA_MODIFIER_MOTION_NONE )

speed_bark = class({})

function speed_bark:Precache( context )
    PrecacheResource( "soundfile", "soundevents/speed_bark.vsndevts", context)
    PrecacheResource( "particle", "particles/speed_bark_cast.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_blue.vpcf", context )
end

function speed_bark:OnSpellStart()
    if not IsServer() then return end
    local caster   = self:GetCaster()
    local point    = caster:GetAbsOrigin()
    local radius   = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")
    local units = FindUnitsInRadius(
        caster:GetTeamNumber(),
        point,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    for _,unit in ipairs(units) do
        unit:AddNewModifier(caster, self, "modifier_speed_bark_effect", { duration = duration })
    end
    local p = ParticleManager:CreateParticle(
        "particles/speed_bark_cast.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        caster
    )
    ParticleManager:ReleaseParticleIndex(p)
    EmitSoundOn("speed_bark", caster)
end

modifier_speed_bark_effect = class({})

function modifier_speed_bark_effect:IsDebuff()
    if ( self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() ) then
        return false
    else
        return true
    end
end

function modifier_speed_bark_effect:OnCreated(kv)
    if not IsServer() then return end
    if (self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber()) then
        self.pfx = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf",
            PATTACH_ABSORIGIN_FOLLOW,
            self:GetParent()
        )
    else
        self.pfx = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_blue.vpcf",
            PATTACH_ABSORIGIN_FOLLOW,
            self:GetParent()
        )
    end
    ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
end

function modifier_speed_bark_effect:OnDestroy()
    if self.pfx then
        ParticleManager:DestroyParticle(self.pfx, false)
        ParticleManager:ReleaseParticleIndex(self.pfx)
    end
end

function modifier_speed_bark_effect:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
end

function modifier_speed_bark_effect:GetModifierMoveSpeedBonus_Percentage()
    if ( self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() ) then
        return self:GetAbility():GetSpecialValueFor("movespeed")
    else
        return -self:GetAbility():GetSpecialValueFor("movespeed")
    end
end

function modifier_speed_bark_effect:GetModifierPhysicalArmorBonus()
    if ( self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() ) then
        return self:GetAbility():GetSpecialValueFor("armor")
    else
        return -self:GetAbility():GetSpecialValueFor("armor")
    end
end

function modifier_speed_bark_effect:GetModifierMagicalResistanceBonus()
    if ( self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() ) then
        return self:GetAbility():GetSpecialValueFor("magic_resist")
    else
        return -self:GetAbility():GetSpecialValueFor("magic_resist")
    end
end
