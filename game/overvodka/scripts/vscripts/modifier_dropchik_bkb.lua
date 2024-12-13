modifier_dropchik_bkb = class({})
--------------------------------------------------------------------------------
function modifier_dropchik_bkb:IsPurgable()
	return false
end
function modifier_dropchik_bkb:IsHidden()
	return true
end
function modifier_dropchik_bkb:OnCreated( kv )
	self.shard = self:GetParent():HasModifier("modifier_item_aghanims_shard")
end

--------------------------------------------------------------------------------

function modifier_dropchik_bkb:OnRemoved()
end

function modifier_dropchik_bkb:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = self.shard,
	}

	return state
end
--------------------------------------------------------------------------------
