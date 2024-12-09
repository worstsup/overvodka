Lev_Otec = class({})
LinkLuaModifier( "modifier_otec", "modifier_otec", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function Lev_Otec:OnSpellStart()
	EmitSoundOn( "otec", self:GetCaster() )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_otec", { duration = self:GetSpecialValueFor( "duration" ) } )
end
--------------------------------------------------------------------------------
