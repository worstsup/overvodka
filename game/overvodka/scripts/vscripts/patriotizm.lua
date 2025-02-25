patriotizm = class({})
LinkLuaModifier( "modifier_patriotizm", "modifier_patriotizm", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_patriotizm_chance", "modifier_patriotizm_chance", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua.lua", LUA_MODIFIER_MOTION_NONE )

function patriotizm:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_terrorblade.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_terrorblade/terrorblade_mirror_image.vpcf", context )
end

function patriotizm:GetIntrinsicModifierName()
	return "modifier_patriotizm_chance"
end