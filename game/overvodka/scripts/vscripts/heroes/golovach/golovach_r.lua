golovach_r = class({})
LinkLuaModifier( "modifier_golovach_r", "heroes/golovach/modifier_golovach_r", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_golovach_r_animation", "heroes/golovach/modifier_golovach_r_animation", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_golovach_r_fury", "heroes/golovach/modifier_golovach_r_fury", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_golovach_r_debuff", "heroes/golovach/modifier_golovach_r_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_golovach_r_recovery", "heroes/golovach/modifier_golovach_r_recovery", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_arc_lua", "modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )

function golovach_r:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_marci.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_unleash_cast.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_unleash_buff.vpcf", context )
	PrecacheResource( "particle", "particles/marci_unleash_stack_golovach.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_unleash_attack.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_unleash_pulse.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_unleash_pulse_debuff.vpcf", context )
	PrecacheResource( "particle", "particles/status_fx/status_effect_snapfire_slow.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength.vpcf", context )
end
function golovach_r:Spawn()
	if not IsServer() then return end
end

function golovach_r:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor( "duration" )
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_golovach_r", -- modifier name
		{ duration = duration } -- kv
	)
end