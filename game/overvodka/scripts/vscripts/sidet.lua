sidet = class({})
LinkLuaModifier( "modifier_sidet", "modifier_sidet", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function sidet:OnSpellStart()
	EmitGlobalSound( "skyli" )

	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_sidet", { duration = self:GetSpecialValueFor( "duration" ) } )
end
--------------------------------------------------------------------------------\
