silvername_murloc = class({})

function silvername_murloc:Precache(context)
    PrecacheResource( "soundfile", "soundevents/murloc.vsndevts", context )
    PrecacheResource( "model", "models/creeps/mega_greevil/mega_greevil.vmdl", context )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_abaddon.vsndevts", context )
end

function silvername_murloc:OnAbilityPhaseStart()
    EmitSoundOn("murloc", self:GetCaster())
    return true
end

function silvername_murloc:OnAbilityPhaseInterrupted()
    StopSoundOn("murloc", self:GetCaster())
end

function silvername_murloc:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    local base_damage = self:GetSpecialValueFor("base_dmg")
    local base_hp = self:GetSpecialValueFor("base_hp")
    local gold = self:GetSpecialValueFor("gold")
    local xp = self:GetSpecialValueFor("xp")
    local murloc = CreateUnitByName("npc_murloc", caster:GetAbsOrigin() + RandomVector(200), true, caster, caster, caster:GetTeamNumber())
    FindClearSpaceForUnit(murloc, murloc:GetAbsOrigin(), true)
    murloc:SetControllableByPlayer(caster:GetPlayerID(), false)
    murloc:SetOwner(caster)
    murloc:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
    murloc:SetBaseMaxHealth(base_hp)
    murloc:SetMaxHealth(base_hp)
    murloc:SetHealth(base_hp)
    murloc:SetBaseDamageMin(base_damage)
    murloc:SetBaseDamageMax(base_damage)
    murloc:SetMaximumGoldBounty(gold)
    murloc:SetMinimumGoldBounty(gold)
    murloc:SetDeathXP(xp)
    murloc:AddNewModifier(caster, self, "modifier_phased", {duration = self:GetSpecialValueFor("phase")})
    local effect_cast = ParticleManager:CreateParticle("particles/items_fx/necronomicon_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, murloc)
    ParticleManager:SetParticleControl(effect_cast, 0, murloc:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
end
