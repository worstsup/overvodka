modifier_axe_berserkers_call_lol_debuff = class({})

function modifier_axe_berserkers_call_lol_debuff:IsHidden()
	return false
end

function modifier_axe_berserkers_call_lol_debuff:IsDebuff()
	return true
end

function modifier_axe_berserkers_call_lol_debuff:IsStunDebuff()
	return false
end

function modifier_axe_berserkers_call_lol_debuff:IsPurgable()
	return false
end

function modifier_axe_berserkers_call_lol_debuff:OnCreated( kv )
	self.lose_strength = self:GetParent():GetStrength() * self:GetAbility():GetSpecialValueFor("str_loss") * 0.01
	self.as_loss = self:GetAbility():GetSpecialValueFor( "as_loss" )
end

function modifier_axe_berserkers_call_lol_debuff:OnRefresh( kv )
	self.lose_strength = self:GetParent():GetStrength() * self:GetAbility():GetSpecialValueFor("str_loss") * 0.01
	self.as_loss = self:GetAbility():GetSpecialValueFor( "as_loss" )
end

function modifier_axe_berserkers_call_lol_debuff:OnRemoved()
end

function modifier_axe_berserkers_call_lol_debuff:OnDestroy()
end

function modifier_axe_berserkers_call_lol_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}

	return funcs
end

function modifier_axe_berserkers_call_lol_debuff:GetModifierBonusStats_Strength( params )
	return -self.lose_strength
end
function modifier_axe_berserkers_call_lol_debuff:GetModifierAttackSpeedBonus_Constant( params )
	return -self.as_loss
end
function modifier_axe_berserkers_call_lol_debuff:GetModifierModelScale()
	return -30
end

function modifier_axe_berserkers_call_lol_debuff:GetEffectName()
	return "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf"
end

function modifier_axe_berserkers_call_lol_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end