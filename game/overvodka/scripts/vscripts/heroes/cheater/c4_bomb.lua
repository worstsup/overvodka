LinkLuaModifier("modifier_c4_bomb", "heroes/cheater/modifier_c4_bomb", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_c4_defuse_channel", "heroes/cheater/modifier_c4_defuse_channel", LUA_MODIFIER_MOTION_NONE)

c4_bomb = class({})

function c4_bomb:Precache(context)
    PrecacheResource("particle", "particles/doom_bringer_doom_ring_new.vpcf", context)
    PrecacheResource( "particle", "particles/c4_explosion.vpcf", context )
	PrecacheResource( "particle", "particles/doom_bringer_doom_ring_bomb.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_timer.vpcf", context )
    PrecacheResource( "soundfile", "soundevents/c4_activate.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/c4.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/c4_defused.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/bomb_defusing.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/bomb_planted.vsndevts", context )
    PrecacheResource( "model", "cheater/models/heroes/cheat/c4_1.vmdl", context )
end

function c4_bomb:OnAbilityPhaseStart()
	EmitGlobalSound("c4_activate")
end
function c4_bomb:OnSpellStart()
    local caster = self:GetCaster()
    local target_point = self:GetCursorPosition()
    local duration = self:GetLevelSpecialValueFor("detonation_time", self:GetLevel() - 1)
    local bomb = CreateUnitByName("npc_dota_c4_bomb", target_point, true, caster, caster, caster:GetTeam())
    bomb:AddNewModifier(caster, self, "modifier_c4_bomb", { duration = 41 })
end
