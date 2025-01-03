modifier_mell_three = class({})
--------------------------------------------------------------------------------
function modifier_mell_three:IsPurgable()
	return false
end
function modifier_mell_three:IsHidden()
	return true
end

function modifier_mell_three:OnCreated( kv )
end

--------------------------------------------------------------------------------

function modifier_mell_three:OnRemoved()
end

function modifier_mell_three:GetEffectName()
	return "particles/marci_unleash_stack_number_three.vpcf"
end

function modifier_mell_three:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end