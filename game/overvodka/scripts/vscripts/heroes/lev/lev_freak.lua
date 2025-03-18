LinkLuaModifier("modifier_lev_freak", "heroes/lev/lev_freak", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)

lev_freak = class({})

function lev_freak:Precache(context)
    PrecacheResource("soundfile", "soundevents/freak.vsndevts", context)
    PrecacheResource("particle", "particles/econ/items/nyx_assassin/nyx_ti9_immortal/nyx_ti9_carapace.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/ancient_apparition/aa_2021_immortal/aa_2021_immortal_chilling_projectile_hit.vpcf", context)
end

function lev_freak:OnSpellStart()
    local caster = self:GetCaster()
    caster.carapaced_units = {}
    local reflect_duration = self:GetSpecialValueFor("reflect_duration")
    caster:AddNewModifier(caster, self, "modifier_lev_freak", { duration = reflect_duration })
    EmitSoundOn("freak", caster)
end

modifier_lev_freak = class({})

function modifier_lev_freak:IsPurgable() return false end
function modifier_lev_freak:IsHidden() return false end
function modifier_lev_freak:IsDebuff() return false end

function modifier_lev_freak:OnCreated()
    if not IsServer() then return end
    self.stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
end

function modifier_lev_freak:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end

function modifier_lev_freak:GetEffectName()
    return "particles/econ/items/nyx_assassin/nyx_ti9_immortal/nyx_ti9_carapace.vpcf"
end

function modifier_lev_freak:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_lev_freak:OnTakeDamage(event)
    if not IsServer() then return end

    local parent = self:GetParent()
    local attacker = event.attacker
    local damage = event.damage
    if event.unit == parent and attacker:GetTeamNumber() ~= parent:GetTeamNumber() and not parent.carapaced_units[ attacker:entindex() ] then
        attacker:AddNewModifier(parent, self:GetAbility(), "modifier_generic_stunned_lua", { duration = self.stun_duration })
        parent.carapaced_units[ attacker:entindex() ] = attacker
        local particle = ParticleManager:CreateParticle("particles/econ/items/ancient_apparition/aa_2021_immortal/aa_2021_immortal_chilling_projectile_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
        ParticleManager:SetParticleControlEnt(particle, 1, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle, 3, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(particle)
    end
end