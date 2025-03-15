dropchik = class({})
LinkLuaModifier( "modifier_dropchik", "modifier_dropchik", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dropchik_bkb", "modifier_dropchik_bkb", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dima", "modifier_dima", LUA_MODIFIER_MOTION_NONE)


function dropchik:OnSpellStart()
	
	EmitSoundOn( "knight", self:GetCaster() )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_dropchik", { duration = self:GetSpecialValueFor( "duration" ) } )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_dropchik_bkb", { duration = 5 } )
end
