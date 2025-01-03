ashab_train = class({})
LinkLuaModifier( "modifier_train", "heroes/ashab/modifier_train", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function ashab_train:OnSpellStart()
	EmitSoundOn( "ashab_train", self:GetCaster() )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_train", { duration = self:GetSpecialValueFor( "duration" ) } )
end
--------------------------------------------------------------------------------
