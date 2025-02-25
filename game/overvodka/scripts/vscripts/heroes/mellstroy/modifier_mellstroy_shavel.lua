modifier_mellstroy_shavel = class({})

function modifier_mellstroy_shavel:IsHidden()
	return false
end
function modifier_mellstroy_shavel:IsDebuff()
	return false
end
function modifier_mellstroy_shavel:IsPurgable()
	return false
end
function modifier_mellstroy_shavel:OnCreated( kv )
	if not IsServer() then return end
end
function modifier_mellstroy_shavel:OnRefresh( kv )
end
function modifier_mellstroy_shavel:OnRemoved()
end
function modifier_mellstroy_shavel:OnDestroy()
end

function modifier_mellstroy_shavel:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_TURNING,
	}

	return funcs
end

function modifier_mellstroy_shavel:GetModifierDisableTurning()
	return 1
end