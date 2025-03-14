modifier_stariy_fly = class({})

function modifier_stariy_fly:IsPurgable()
	return false
end
function modifier_stariy_fly:IsHidden()
	return true
end

function modifier_stariy_fly:OnCreated( kv )
end

function modifier_stariy_fly:OnRemoved()
end

function modifier_stariy_fly:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end
function modifier_stariy_fly:CheckState()
	local state = {
		[MODIFIER_STATE_FLYING] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end

function modifier_stariy_fly:GetModifierModelScale( params )
	return 1.2
end
function modifier_stariy_fly:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_4
end