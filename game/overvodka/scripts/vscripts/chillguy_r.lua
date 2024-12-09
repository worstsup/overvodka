chillguy_r = class({})
LinkLuaModifier( "modifier_chillguy_r", "modifier_chillguy_r", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function chillguy_r:OnSpellStart()
	EmitSoundOn( "chillguy_r", self:GetCaster() )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_chillguy_r", { duration = self:GetSpecialValueFor( "duration" ) } )
end
--------------------------------------------------------------------------------
