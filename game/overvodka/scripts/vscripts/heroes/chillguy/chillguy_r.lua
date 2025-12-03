chillguy_r = class({})
LinkLuaModifier( "modifier_chillguy_r", "heroes/chillguy/modifier_chillguy_r", LUA_MODIFIER_MOTION_NONE )

function chillguy_r:OnSpellStart()
	if not global_sounds_muted then
		EmitSoundOn( "chillguy_r", self:GetCaster() )
	end
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_chillguy_r", { duration = self:GetSpecialValueFor( "duration" ) } )
end