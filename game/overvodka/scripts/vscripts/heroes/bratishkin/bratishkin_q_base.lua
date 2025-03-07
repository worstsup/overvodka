LinkLuaModifier("modifier_bratishkin_q_knight", "heroes/bratishkin/bratishkin_q_knight", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bratishkin_q_knight_upgrade", "heroes/bratishkin/bratishkin_q_knight", LUA_MODIFIER_MOTION_NONE)

bratishkin_q_base = class({})

function bratishkin_q_base:GetManaCost(iLevel)
    local base_cost = self:GetSpecialValueFor("base_manacost")
    local manacost_from_current_mana = self:GetSpecialValueFor("manacost_from_current_mana")
    return base_cost + (self:GetCaster():GetMana() / 100 * manacost_from_current_mana)
end

function bratishkin_q_base:Precache( context )
    PrecacheResource( "particle", "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_transform.vpcf", context )
    PrecacheResource( "model", "models/bratishkin/knight/base.vmdl", context )
	PrecacheResource( "model", "models/heroes/sven/sven_sword.vmdl", context )
end

function bratishkin_q_base:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_bratishkin_q_knight_upgrade", {})
    local modifier_bratishkin_q_knight = self:GetCaster():FindModifierByName("modifier_bratishkin_q_knight")
    if modifier_bratishkin_q_knight then
        modifier_bratishkin_q_knight:Destroy()
    else
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_bratishkin_q_knight", {})
    end
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_transform.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:ReleaseParticleIndex(particle)
end