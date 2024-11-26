nix_rus = class({})
LinkLuaModifier( "modifier_nix_rus", "modifier_nix_rus", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_axe_berserkers_call_lol_debuff", "modifier_axe_berserkers_call_lol_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_disarmed_lua", "modifier_generic_disarmed_lua", LUA_MODIFIER_MOTION_NONE )


--------------------------------------------------------------------------------

function nix_rus:OnSpellStart()
	EmitGlobalSound( "nix_rus" )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_nix_rus", { duration = self:GetSpecialValueFor( "duration" ) } )
end
--------------------------------------------------------------------------------
