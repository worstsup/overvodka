modifier_batya_radiance_debuff = class({})
--------------------------------------------------------------------------------
-- Classifications
function modifier_batya_radiance_debuff:IsHidden()
	return true
end

function modifier_batya_radiance_debuff:IsDebuff()
	return true
end

function modifier_batya_radiance_debuff:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_batya_radiance_debuff:OnCreated( kv )
	self.slow = self:GetAbility():GetSpecialValueFor( "slow" )
end

function modifier_batya_radiance_debuff:OnRefresh( kv )
	self.slow = self:GetAbility():GetSpecialValueFor( "slow" )
end

function modifier_batya_radiance_debuff:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_batya_radiance_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end
function modifier_batya_radiance_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end
