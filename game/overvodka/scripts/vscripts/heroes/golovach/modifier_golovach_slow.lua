modifier_golovach_slow = class({})

function modifier_golovach_slow:IsHidden()
	return false
end

function modifier_golovach_slow:IsDebuff()
	return true
end

function modifier_golovach_slow:IsStunDebuff()
	return false
end

function modifier_golovach_slow:IsPurgable()
	return false
end

function modifier_golovach_slow:OnCreated( kv )
	self.slow = 20
end

function modifier_golovach_slow:OnRefresh( kv )
	self.slow = 20
end

function modifier_golovach_slow:OnRemoved()
end

function modifier_golovach_slow:OnDestroy()
end

function modifier_golovach_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}

	return funcs
end
function modifier_golovach_slow:CheckState()
	local state = {
		[MODIFIER_STATE_PROVIDES_VISION] = true,
	}

	return state
end
function modifier_golovach_slow:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow
end