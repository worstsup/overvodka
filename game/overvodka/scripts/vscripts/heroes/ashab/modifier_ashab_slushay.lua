modifier_ashab_slushay = class({})

--------------------------------------------------------------------------------

function modifier_ashab_slushay:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_ashab_slushay:OnCreated( kv )
end

function modifier_ashab_slushay:OnRefresh( kv )
end
--------------------------------------------------------------------------------

function modifier_ashab_slushay:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end

--------------------------------------------------------------------------------


