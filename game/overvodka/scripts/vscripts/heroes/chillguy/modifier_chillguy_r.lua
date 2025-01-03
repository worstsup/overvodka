modifier_chillguy_r = class({})
--------------------------------------------------------------------------------
function modifier_chillguy_r:IsPurgable()
	return false
end

function modifier_chillguy_r:OnCreated( kv )
	self.bonus_hpregen = self:GetAbility():GetSpecialValueFor( "bonus_hpregen" )
	self.model_scale = self:GetAbility():GetSpecialValueFor( "model_scale" )
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "bonus_ms" )
	self.spell_amp = self:GetAbility():GetSpecialValueFor( "spell_amp" )
end

--------------------------------------------------------------------------------

function modifier_chillguy_r:OnRemoved()
end

--------------------------------------------------------------------------------

function modifier_chillguy_r:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}

	return funcs
end

function modifier_chillguy_r:GetModifierModelScale( params )
	return self.model_scale
end
function modifier_chillguy_r:GetModifierConstantHealthRegen( params )
	return self.bonus_hpregen
end
function modifier_chillguy_r:GetModifierMoveSpeedBonus_Constant( params )
	return self.bonus_ms
end
function modifier_chillguy_r:GetModifierSpellAmplify_Percentage( params )
	return self.spell_amp
end