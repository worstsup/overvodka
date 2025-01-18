modifier_generic_vector_target = class({})

--------------------------------------------------------------------------------
function modifier_generic_vector_target:IsHidden()
	return true
end

function modifier_generic_vector_target:IsPurgable()
	return false
end

function modifier_generic_vector_target:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT
end

--------------------------------------------------------------------------------
function modifier_generic_vector_target:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
	}

	return funcs
end

function modifier_generic_vector_target:OnOrder( params )
	if params.unit~=self:GetParent() then return end

	if params.order_type==DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION then
		self:GetAbility().vector_position = params.new_pos
	end
end