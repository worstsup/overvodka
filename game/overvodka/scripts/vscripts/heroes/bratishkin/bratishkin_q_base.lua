LinkLuaModifier("modifier_bratishkin_q_knight", "heroes/bratishkin/bratishkin_q_knight", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bratishkin_q_knight_upgrade", "heroes/bratishkin/bratishkin_q_knight", LUA_MODIFIER_MOTION_NONE)

bratishkin_q_base = class({})
t = 0
function bratishkin_q_base:GetManaCost(iLevel)
    local base_cost = self:GetSpecialValueFor("base_manacost")
    local manacost_from_current_mana = self:GetSpecialValueFor("manacost_from_current_mana")
    return base_cost + (self:GetCaster():GetMana() / 100 * manacost_from_current_mana)
end

function bratishkin_q_base:IsStealable() return false end

function bratishkin_q_base:Precache( context )
    PrecacheResource( "particle", "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/dark_willow/dark_willow_chakram_immortal/dark_willow_chakram_immortal_bramble_root.vpcf", context )
    PrecacheResource( "model", "models/bratishkin/knight/base.vmdl", context )
	PrecacheResource( "model", "models/items/sven/weapon_ruling_sword.vmdl", context )
    PrecacheResource( "soundfile", "soundevents/bratishkin_knight_attack.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/bratishkin_q_base_1.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/bratishkin_q_base_2.vsndevts", context )
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
    if t == 0 then
        self:GetCaster():EmitSound("bratishkin_q_base_1")
        t = 1
    elseif t == 1 then
        self:GetCaster():EmitSound("bratishkin_q_base_2")
        t = 0
    end
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:ReleaseParticleIndex(particle)
    local illusions = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        self:GetCaster():GetAbsOrigin(),
        nil,
        6000,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_ANY_ORDER,
        false
    )

    for _, unit in pairs(illusions) do
        if unit:IsIllusion() and unit:GetPlayerOwnerID() == self:GetCaster():GetPlayerOwnerID() then
            if unit:HasModifier("modifier_bratishkin_q_knight") then
                unit:RemoveModifierByName("modifier_bratishkin_q_knight")
            end
        end
    end
end