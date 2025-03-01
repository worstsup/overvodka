stariy_bolt = class({})
LinkLuaModifier( "modifier_stariy_bolt", "heroes/stariy/modifier_stariy_bolt", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stariy_bolt_debuff", "heroes/stariy/modifier_stariy_bolt_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stariy_lasers_linger_thinker", "heroes/stariy/modifier_stariy_lasers_linger_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stariy_lasers_debuff", "heroes/stariy/modifier_stariy_lasers_debuff", LUA_MODIFIER_MOTION_NONE )

function stariy_bolt:Precache(context)
	PrecacheResource( "particle", "particles/staff_beam_new.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_beam_channel.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_beam_burn.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/staff_beam_linger.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/staff_beam_tgt_ring.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_debug_ring.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/stariy_peterka.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_huskar.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_jakiro.vsndevts", context )
end

function stariy_bolt:GetIntrinsicModifierName()
	return "modifier_stariy_bolt"
end