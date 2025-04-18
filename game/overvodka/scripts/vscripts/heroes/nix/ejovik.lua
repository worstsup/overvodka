ejovik = class({})
LinkLuaModifier( "modifier_ejovik", "heroes/nix/modifier_ejovik", LUA_MODIFIER_MOTION_NONE )

function ejovik:Precache( context )
	PrecacheResource( "soundfile", "soundevents/ejovik.vsndevts", context ) 
	PrecacheResource( "particle", "particles/pangolier_shard_rollup_magic_immune_nix.vpcf", context )
end

function ejovik:OnSpellStart()
	if not IsServer() then return end
	EmitSoundOn( "ejovik", self:GetCaster() )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_ejovik", { duration = self:GetSpecialValueFor( "duration" ) } )
end
