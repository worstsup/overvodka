Lev_Otec = class({})
LinkLuaModifier( "modifier_otec", "modifier_otec", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function Lev_Otec:OnSpellStart()
	EmitGlobalSound( "otec" )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_otec", { duration = self:GetSpecialValueFor( "duration" ) } )
end
--------------------------------------------------------------------------------
