modifier_serega_radiance_debuff = class({})
--------------------------------------------------------------------------------
-- Classifications
function modifier_serega_radiance_debuff:IsHidden()
	return true
end

function modifier_serega_radiance_debuff:IsDebuff()
	return true
end

function modifier_serega_radiance_debuff:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_serega_radiance_debuff:OnCreated( kv )
end

function modifier_serega_radiance_debuff:OnRefresh( kv )
end

function modifier_serega_radiance_debuff:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_serega_radiance_debuff:DeclareFunctions()
	local funcs = {
	}
	return funcs
end

function modifier_serega_radiance_debuff:GetEffectName()
	return "particles/econ/events/fall_2022/radiance_target_fall2022.vpcf"
end

function modifier_serega_radiance_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end