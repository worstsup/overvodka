modifier_orlov_fly = class({})
--------------------------------------------------------------------------------
function modifier_orlov_fly:IsPurgable()
	return false
end

function modifier_orlov_fly:OnCreated( kv )
	self.move_speed = self:GetAbility():GetSpecialValueFor( "move_speed" )
	self.model_scale = self:GetAbility():GetSpecialValueFor( "model_scale" )
	self.bonus_strength = self:GetAbility():GetSpecialValueFor( "bonus_strength" )
	self.evasion = self:GetAbility():GetSpecialValueFor( "evasion" )
end

--------------------------------------------------------------------------------

function modifier_orlov_fly:OnRemoved()
end


--------------------------------------------------------------------------------

function modifier_orlov_fly:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_EXTRA_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
	}

	return funcs
end
function modifier_orlov_fly:CheckState()
	local state = {
		[MODIFIER_STATE_FLYING] = true,
	}

	return state
end
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------

function modifier_orlov_fly:GetModifierModelScale( params )
	return self.model_scale
end

function modifier_orlov_fly:GetModifierExtraStrengthBonus( params )
	return self.bonus_strength
end

function modifier_orlov_fly:GetModifierMoveSpeed_Limit( params )
	return self.move_speed
end

function modifier_orlov_fly:GetModifierEvasion_Constant( params )
	return self.evasion
end