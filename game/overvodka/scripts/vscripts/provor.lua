Provor = class({})
LinkLuaModifier( "modifier_provor", "modifier_provor", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function Provor:OnSpellStart()
	EmitGlobalSound( "prov" )

	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_provor", { duration = self:GetSpecialValueFor( "duration" ) } )
end
--------------------------------------------------------------------------------\
