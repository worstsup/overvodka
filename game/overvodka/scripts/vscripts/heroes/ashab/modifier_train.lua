modifier_train = class({})

function modifier_train:IsPurgable()
	return false
end

function modifier_train:OnCreated( kv )
	self.model_scale = self:GetAbility():GetSpecialValueFor( "model_scale" )
	self.bonus_status = self:GetAbility():GetSpecialValueFor( "bonus_status" )
	self.bonus_strength   = self:GetParent():GetStrength() * self:GetAbility():GetSpecialValueFor("bonus_strength") * 0.01
end

function modifier_train:OnRemoved()
end

function modifier_train:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
	}
	return funcs
end

function modifier_train:GetModifierModelScale( params )
	return self.model_scale
end

function modifier_train:GetModifierBonusStats_Strength( params )
	return self.bonus_strength
end

function modifier_train:GetModifierStatusResistance()
	return self.bonus_status
end