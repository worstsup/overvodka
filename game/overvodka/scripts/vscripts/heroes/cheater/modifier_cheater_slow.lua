modifier_cheater_slow = class({})

--------------------------------------------------------------------------------
function modifier_cheater_slow:IsHidden()
	return false
end

function modifier_cheater_slow:IsDebuff()
	return true
end

function modifier_cheater_slow:IsStunDebuff()
	return false
end

function modifier_cheater_slow:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
function modifier_cheater_slow:OnCreated( kv )
	self.slow = self:GetAbility():GetSpecialValueFor( "slow" )

end

function modifier_cheater_slow:OnRefresh( kv )
	self.slow = self:GetAbility():GetSpecialValueFor( "slow" )
end

function modifier_cheater_slow:OnRemoved()
end

function modifier_cheater_slow:OnDestroy()
end

--------------------------------------------------------------------------------
function modifier_cheater_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}

	return funcs
end

function modifier_cheater_slow:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow
end