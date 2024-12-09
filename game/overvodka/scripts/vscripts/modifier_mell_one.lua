modifier_mell_one = class({})
--------------------------------------------------------------------------------
function modifier_mell_one:IsPurgable()
	return false
end
function modifier_mell_one:IsHidden()
	return true
end

function modifier_mell_one:OnCreated( kv )
end

--------------------------------------------------------------------------------

function modifier_mell_one:OnRemoved()
end

function modifier_mell_one:GetEffectName()
	return "particles/marci_unleash_stack_number_one.vpcf"
end

function modifier_mell_one:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end