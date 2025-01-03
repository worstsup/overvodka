--------------------------------------------------------------------------------
modifier_chillguy_blind = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_chillguy_blind:IsHidden()
	return true
end

function modifier_chillguy_blind:IsDebuff()
	return true
end

function modifier_chillguy_blind:IsStunDebuff()
	return false
end

function modifier_chillguy_blind:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_chillguy_blind:OnCreated( kv )

end

function modifier_chillguy_blind:OnRefresh( kv )
end

function modifier_chillguy_blind:OnRemoved()
end

function modifier_chillguy_blind:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_chillguy_blind:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
	}

	return funcs
end

function modifier_chillguy_blind:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end
function modifier_chillguy_blind:GetBonusDayVision()
	return -1600
end
function modifier_chillguy_blind:GetBonusNightVision()
	return -600
end