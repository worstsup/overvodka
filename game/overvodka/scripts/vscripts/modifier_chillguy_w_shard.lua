modifier_chillguy_w_shard = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_chillguy_w_shard:IsDebuff()
	return true
end

function modifier_chillguy_w_shard:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_chillguy_w_shard:OnCreated( kv )
	if not IsServer() then return end
	self.slow = self:GetAbility():GetSpecialValueFor("slow")
	self.shard = self:GetCaster():HasScepter()
end

function modifier_chillguy_w_shard:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_chillguy_w_shard:OnRemoved()
end

function modifier_chillguy_w_shard:OnDestroy()
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_chillguy_w_shard:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = self.shard,
		[MODIFIER_STATE_SILENCED] = self.shard,
	}

	return state
end
function modifier_chillguy_w_shard:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end
function modifier_chillguy_w_shard:GetModifierMoveSpeedBonus_Percentage( params )
	return self.slow
end
--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_chillguy_w_shard:GetEffectName()
	return "particles/econ/events/fall_2021/bottle_fall_2021_ring_green.vpcf"
end

function modifier_chillguy_w_shard:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end