modifier_zolo_disarm = class({})

function modifier_zolo_disarm:IsHidden()
	return false
end
function modifier_zolo_disarm:IsDebuff()
	return true
end
function modifier_zolo_disarm:IsPurgable()
	return true
end

function modifier_zolo_disarm:OnCreated( kv )
	self.slow = self:GetAbility():GetSpecialValueFor( "slow" )
end
function modifier_zolo_disarm:OnRefresh( kv )
	self.slow = self:GetAbility():GetSpecialValueFor( "slow" )
end

function modifier_zolo_disarm:OnRemoved()
end
function modifier_zolo_disarm:OnDestroy()
end

function modifier_zolo_disarm:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end
function modifier_zolo_disarm:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end
function modifier_zolo_disarm:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end
function modifier_zolo_disarm:GetEffectName()
	return "particles/units/heroes/hero_invoker/invoker_deafening_blast_disarm_debuff.vpcf"
end

function modifier_zolo_disarm:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end