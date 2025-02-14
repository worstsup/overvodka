litvin_litenergy = class({})
LinkLuaModifier( "modifier_litvin_litenergy", "heroes/litvin/modifier_litvin_litenergy", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function litvin_litenergy:OnSpellStart()
	EmitGlobalSound( "litenergy" )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_litvin_litenergy", { duration = self:GetSpecialValueFor( "duration" ) } )
end
--------------------------------------------------------------------------------
