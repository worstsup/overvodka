modifier_dima = class({})
--------------------------------------------------------------------------------
function modifier_dima:IsPurgable()
	return false
end
--------------------------------------------------------------------------------

function modifier_dima:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
	}

	return funcs
end

function modifier_dima:GetModifierMoveSpeed_Limit( params )
	return 300
end