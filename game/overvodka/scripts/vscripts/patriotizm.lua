-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
patriotizm = class({})
LinkLuaModifier( "modifier_patriotizm", "modifier_patriotizm", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_patriotizm_chance", "modifier_patriotizm_chance", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Init Abilities
function patriotizm:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_terrorblade.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_terrorblade/terrorblade_mirror_image.vpcf", context )
end

--------------------------------------------------------------------------------
function patriotizm:GetIntrinsicModifierName()
	return "modifier_patriotizm_chance"
end