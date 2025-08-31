LinkLuaModifier("modifier_frisk_e_buff", "heroes/frisk/frisk_e", LUA_MODIFIER_MOTION_NONE)

frisk_e = class({})

function frisk_e:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function frisk_e:Precache(context)
    PrecacheResource("soundfile", "soundevents/frisk_sounds.vsndevts", context)
    PrecacheResource("particle", "particles/items3_fx/warmage_recipient.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_abaddon/abaddon_mist_coil_buff.vpcf", context)
    PrecacheResource("particle", "particles/frisk_e.vpcf", context)
end

function frisk_e:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local radius = self:GetSpecialValueFor("radius")
    local heal = self:GetSpecialValueFor("heal")
    local duration = self:GetSpecialValueFor("duration")
    EmitSoundOnLocationWithCaster(point, "frisk_e", caster)
    local friends = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _,friend in ipairs(friends) do
        friend:HealWithParams(heal, self, false, true, caster, false)
        friend:AddNewModifier(caster, self, "modifier_frisk_e_buff", { duration = duration })
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, friend, heal, caster and caster:GetPlayerOwner())
        local particle = ParticleManager:CreateParticle("particles/items3_fx/warmage_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, friend)
        ParticleManager:SetParticleControl(particle, 0, friend:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle)
    end
    local p = ParticleManager:CreateParticle("particles/frisk_e.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(p, 0, point)
    ParticleManager:SetParticleControl(p, 1, Vector(radius + 30, 0, 0))
    ParticleManager:ReleaseParticleIndex(p)
end


modifier_frisk_e_buff = class({})

function modifier_frisk_e_buff:IsHidden() return false end
function modifier_frisk_e_buff:IsPurgable() return true end

function modifier_frisk_e_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATUS_RESISTANCE,
    }
end

function modifier_frisk_e_buff:GetModifierStatusResistance()
    return self:GetAbility():GetSpecialValueFor("status_resist")
end

function modifier_frisk_e_buff:GetEffectName()
    return "particles/units/heroes/hero_abaddon/abaddon_mist_coil_buff.vpcf"
end

function modifier_frisk_e_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end