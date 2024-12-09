ejovik = class({})
LinkLuaModifier( "modifier_ejovik", "modifier_ejovik", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function ejovik:OnSpellStart()
	EmitSoundOn( "ejovik", self:GetCaster() )

	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_ejovik", { duration = self:GetSpecialValueFor( "duration" ) } )
end
--------------------------------------------------------------------------------\
