arsen_baza = class({})
LinkLuaModifier( "modifier_arsen_baza", "heroes/arsen/modifier_arsen_baza", LUA_MODIFIER_MOTION_NONE )

function arsen_baza:GetIntrinsicModifierName()
	return "modifier_generic_orb_effect_lua"
end

function arsen_baza:GetCastRange(vLocation, hTarget)
    return self:GetCaster():Script_GetAttackRange()
end

function arsen_baza:OnOrbImpact( params )
	local duration = self:GetSpecialValueFor( "burn_duration" )
	local bash = self:GetSpecialValueFor( "ministun_duration" )
	local break_duration = self:GetSpecialValueFor( "break_duration" )
	params.target:AddNewModifier(self:GetCaster(), self, "modifier_arsen_baza", { duration = duration })
	params.target:AddNewModifier(self:GetCaster(), self, "modifier_generic_stunned_lua", { duration = bash })
	params.target:AddNewModifier(self:GetCaster(), self, "modifier_silver_edge_debuff", {duration = break_duration})
end