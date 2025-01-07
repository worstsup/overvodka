modifier_invoker_wex_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_invoker_wex_lua:IsHidden()
	return false
end

function modifier_invoker_wex_lua:IsDebuff()
	return false
end

function modifier_invoker_wex_lua:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_invoker_wex_lua:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
function modifier_invoker_wex_lua:OnCreated( kv )
	self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_per_instance" )
	self.ms_bonus = self:GetAbility():GetSpecialValueFor( "move_speed_per_instance" )
	self.cdr = self:GetAbility():GetSpecialValueFor( "cdr" )
	self.as_bonus_sss = self.as_bonus * 2
	self.ms_bonus_sss = self.ms_bonus * 2
	self.cdr_sss = self.cdr * 2
	self:StartIntervalThink(0.5)
end

function modifier_invoker_wex_lua:OnRefresh( kv )
	self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_per_instance" )
	self.ms_bonus = self:GetAbility():GetSpecialValueFor( "move_speed_per_instance" )
	self.cdr = self:GetAbility():GetSpecialValueFor( "cdr" )
	self.as_bonus_sss = self.as_bonus * 2
	self.ms_bonus_sss = self.ms_bonus * 2
	self.cdr_sss = self.cdr * 2
	self:StartIntervalThink(0.5)
end

function modifier_invoker_wex_lua:OnIntervalThink()
	if self:GetParent():HasModifier("modifier_invoker_ghost_walk_lua") then
		self.as_bonus = self.as_bonus_sss
		self.ms_bonus = self.ms_bonus_sss
		self.cdr = self.cdr_sss
	else
		self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_per_instance" )
		self.ms_bonus = self:GetAbility():GetSpecialValueFor( "move_speed_per_instance" )
		self.cdr = self:GetAbility():GetSpecialValueFor( "cdr" )
	end
end
function modifier_invoker_wex_lua:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_invoker_wex_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
	}

	return funcs
end

function modifier_invoker_wex_lua:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end
function modifier_invoker_wex_lua:GetModifierPercentageCooldown()
	return self.cdr
end
function modifier_invoker_wex_lua:GetModifierAttackSpeedBonus_Constant()
	return self.as_bonus
end
