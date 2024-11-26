dropchik = class({})
LinkLuaModifier( "modifier_dropchik", "modifier_dropchik", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dima", "modifier_dima", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function dropchik:OnSpellStart()
	EmitGlobalSound( "knight" )

	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_dropchik", { duration = self:GetSpecialValueFor( "duration" ) } )
end
--------------------------------------------------------------------------------\
