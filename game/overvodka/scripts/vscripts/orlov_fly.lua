orlov_fly = class({})
LinkLuaModifier( "modifier_orlov_fly", "modifier_orlov_fly", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function orlov_fly:OnSpellStart()
	EmitSoundOn( "orlov", self:GetCaster() )

	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_orlov_fly", { duration = self:GetSpecialValueFor( "duration" ) } )
end
--------------------------------------------------------------------------------\
