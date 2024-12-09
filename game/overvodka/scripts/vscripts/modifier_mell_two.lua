modifier_mell_two = class({})
--------------------------------------------------------------------------------
function modifier_mell_two:IsPurgable()
	return false
end
function modifier_mell_two:IsHidden()
	return true
end

function modifier_mell_two:OnCreated( kv )
end

--------------------------------------------------------------------------------

function modifier_mell_two:OnRemoved()
end

function modifier_mell_two:GetEffectName()
	return "particles/marci_unleash_stack_number_two.vpcf"
end

function modifier_mell_two:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end