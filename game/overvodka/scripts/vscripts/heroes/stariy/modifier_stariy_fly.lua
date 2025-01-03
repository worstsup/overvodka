modifier_stariy_fly = class({})
--------------------------------------------------------------------------------
function modifier_stariy_fly:IsPurgable()
	return false
end

function modifier_stariy_fly:IsHidden()
	return true
end


function modifier_stariy_fly:OnCreated( kv )
end

--------------------------------------------------------------------------------

function modifier_stariy_fly:OnRemoved()
end


--------------------------------------------------------------------------------

function modifier_stariy_fly:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MODEL_SCALE,
	}

	return funcs
end
function modifier_stariy_fly:CheckState()
	local state = {
		[MODIFIER_STATE_FLYING] = true,
	}

	return state
end
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------

function modifier_stariy_fly:GetModifierModelScale( params )
	return 1.2
end
