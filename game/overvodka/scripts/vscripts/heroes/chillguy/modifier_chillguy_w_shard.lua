modifier_chillguy_w_shard = class({})

function modifier_chillguy_w_shard:IsDebuff()
	return true
end

function modifier_chillguy_w_shard:IsStunDebuff()
	return true
end

function modifier_chillguy_w_shard:OnCreated( kv )
	if not IsServer() then return end
	self.slow = self:GetAbility():GetSpecialValueFor("slow")
	self.shard = self:GetCaster():HasScepter()
	self.slow_as = self:GetAbility():GetSpecialValueFor("slow_as")
	self.slow_proj = self:GetAbility():GetSpecialValueFor("slow_proj")
end

function modifier_chillguy_w_shard:OnRefresh( kv )
	self:OnCreated( kv )
end
function modifier_chillguy_w_shard:OnRemoved()
end

function modifier_chillguy_w_shard:OnDestroy()
end

function modifier_chillguy_w_shard:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = false
	}

	return state
end
function modifier_chillguy_w_shard:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end
function modifier_chillguy_w_shard:GetModifierMoveSpeedBonus_Percentage( params )
	return self.slow
end

function modifier_chillguy_w_shard:GetModifierAttackSpeedBonus_Constant( params )
	return self.slow_as
end

function modifier_chillguy_w_shard:GetEffectName()
	return "particles/econ/events/fall_2021/bottle_fall_2021_ring_green.vpcf"
end

function modifier_chillguy_w_shard:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end