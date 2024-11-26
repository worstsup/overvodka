stariy_bred = class({})
LinkLuaModifier( "modifier_bred", "modifier_bred", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function stariy_bred:OnSpellStart()
	EmitGlobalSound( "stariy_bred" )

	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_bred", { duration = self:GetSpecialValueFor( "duration" ) } )
end
--------------------------------------------------------------------------------\
