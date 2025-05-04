litvin_bledina = class({})
LinkLuaModifier( "modifier_litvin_bledina", "heroes/litvin/modifier_litvin_bledina", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function litvin_bledina:OnSpellStart()
	EmitSoundOn( "bledina", self:GetCaster() )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_litvin_bledina", { duration = self:GetSpecialValueFor( "duration" ) } )
end
--------------------------------------------------------------------------------\
