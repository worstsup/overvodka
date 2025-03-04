stariy_bred = class({})
LinkLuaModifier( "modifier_bred", "heroes/stariy/modifier_bred", LUA_MODIFIER_MOTION_NONE )

function stariy_bred:Precache(context)
	PrecacheResource( "particle", "particles/events/muerta_ofrenda/muerta_death_reckoning_flames_green.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/stariy_bred.vsndevts", context )
end

function stariy_bred:OnSpellStart()
	if not IsServer() then return end
	EmitSoundOn( "stariy_bred", self:GetCaster() )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_bred", { duration = self:GetSpecialValueFor( "duration" ) } )
end