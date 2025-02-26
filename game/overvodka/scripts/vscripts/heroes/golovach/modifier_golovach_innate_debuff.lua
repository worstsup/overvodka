modifier_golovach_innate_debuff = class({})

function modifier_golovach_innate_debuff:IsHidden()
	return false
end

function modifier_golovach_innate_debuff:IsDebuff()
	return true
end

function modifier_golovach_innate_debuff:IsStunDebuff()
	return false
end

function modifier_golovach_innate_debuff:IsPurgable()
	return true
end

function modifier_golovach_innate_debuff:OnCreated( kv )
	self.move_slow = self:GetAbility():GetSpecialValueFor( "movespeed" )
	self.attack_slow = self:GetAbility():GetSpecialValueFor( "attackslow_tooltip" )
end

function modifier_golovach_innate_debuff:OnRefresh( kv )
	self.move_slow = self:GetAbility():GetSpecialValueFor( "movespeed" )
	self.attack_slow = self:GetAbility():GetSpecialValueFor( "attackslow_tooltip" )
end

function modifier_golovach_innate_debuff:OnDestroy( kv )
end

function modifier_golovach_innate_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end
function modifier_golovach_innate_debuff:GetModifierAttackSpeedBonus_Constant()
	return self.attack_slow
end

function modifier_golovach_innate_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.move_slow
end

function modifier_golovach_innate_debuff:GetEffectName()
	return "particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_slow_debuff.vpcf"
end

function modifier_golovach_innate_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end