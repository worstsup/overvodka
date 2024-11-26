modifier_tidehunter_anchor_smash_lua = class({})

--------------------------------------------------------------------------------

function modifier_tidehunter_anchor_smash_lua:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_tidehunter_anchor_smash_lua:OnCreated( kv )
end

function modifier_tidehunter_anchor_smash_lua:OnRefresh( kv )
end
--------------------------------------------------------------------------------

function modifier_tidehunter_anchor_smash_lua:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end

--------------------------------------------------------------------------------


