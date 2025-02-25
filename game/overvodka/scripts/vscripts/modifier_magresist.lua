modifier_magresist = class({})
--------------------------------------------------------------------------------
function modifier_magresist:IsPurgable()
	return false
end

function modifier_magresist:OnCreated( kv )
end

--------------------------------------------------------------------------------

function modifier_magresist:OnRemoved()
end

--------------------------------------------------------------------------------

function modifier_magresist:CheckState()
	local state = {
		[MODIFIER_STATE_DEBUFF_IMMUNE] = true,
	}

	return state
end
function modifier_magresist:GetEffectName()
	return "particles/econ/items/lifestealer/lifestealer_immortal_backbone/lifestealer_immortal_backbone_rage.vpcf"
end

function modifier_magresist:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end