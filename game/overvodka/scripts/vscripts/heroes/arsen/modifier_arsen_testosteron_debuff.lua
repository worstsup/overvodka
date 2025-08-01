modifier_arsen_testosteron_debuff = class({})

function modifier_arsen_testosteron_debuff:IsHidden() return false end
function modifier_arsen_testosteron_debuff:IsDebuff() return true end
function modifier_arsen_testosteron_debuff:IsStunDebuff() return false end
function modifier_arsen_testosteron_debuff:IsPurgable() return false end

function modifier_arsen_testosteron_debuff:OnCreated( kv )
	if IsServer() then
		self:GetParent():SetForceAttackTarget( self:GetCaster() )
		self:GetParent():MoveToTargetToAttack( self:GetCaster() )
	end
end

function modifier_arsen_testosteron_debuff:OnRefresh( kv )
end

function modifier_arsen_testosteron_debuff:OnRemoved()
	if IsServer() then
		self:GetParent():SetForceAttackTarget( nil )
	end
end

function modifier_arsen_testosteron_debuff:OnDestroy()
end

function modifier_arsen_testosteron_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
	return state
end

function modifier_arsen_testosteron_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_beserkers_call.vpcf"
end

function modifier_arsen_testosteron_debuff:GetEffectName()
	return "particles/generic_gameplay/outpost_reward.vpcf"
end

function modifier_arsen_testosteron_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end