litvin_bledina = class({})
LinkLuaModifier( "modifier_litvin_bledina", "heroes/litvin/modifier_litvin_bledina", LUA_MODIFIER_MOTION_NONE )

function litvin_bledina:Precache(context)
	PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_unleash_buff.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_unleash_attack.vpcf", context )
end

function litvin_bledina:OnSpellStart()
	if not IsServer() then return end
	EmitSoundOn( "bledina", self:GetCaster() )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_litvin_bledina", { duration = self:GetSpecialValueFor( "duration" ) } )
end