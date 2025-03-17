nix_rus = class({})
LinkLuaModifier( "modifier_nix_rus", "heroes/nix/modifier_nix_rus", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_axe_berserkers_call_lol_debuff", "heroes/nix/modifier_axe_berserkers_call_lol_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_disarmed_lua", "modifier_generic_disarmed_lua", LUA_MODIFIER_MOTION_NONE )

function nix_rus:Precache(context)
	PrecacheResource("particle", "particles/nix_r.vpcf", context)
	PrecacheResource("soundfile", "soundevents/nix_rus.vsndevts", context )
end

function nix_rus:OnSpellStart()
	if not IsServer() then return end
	EmitSoundOn( "nix_rus", self:GetCaster() )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_nix_rus", { duration = self:GetSpecialValueFor( "duration" ) } )
end
