modifier_litvin_litenergy = class({})
--------------------------------------------------------------------------------
function modifier_litvin_litenergy:IsPurgable()
	return false
end

function modifier_litvin_litenergy:OnCreated( kv )
	self.base_hp = self:GetAbility():GetSpecialValueFor( "base_hp" )
	self.level_hp = self:GetAbility():GetSpecialValueFor( "level_hp" )
	self.base_mana = self:GetAbility():GetSpecialValueFor( "base_mana" )
	self.level_mana = self:GetAbility():GetSpecialValueFor( "level_mana" )
	self.base_miss = self:GetAbility():GetSpecialValueFor( "base_miss" )
	self.level_miss = self:GetAbility():GetSpecialValueFor( "level_miss" )
	self.ms = self:GetAbility():GetSpecialValueFor( "ms" )
	self.level = self:GetCaster():GetLevel()
	self.base_hp = self.base_hp + self.level_hp * self.level
	self.base_mana = self.base_mana + self.level_mana * self.level
	self.base_miss = self.base_miss + self.level_miss * self.level
end

--------------------------------------------------------------------------------

function modifier_litvin_litenergy:OnRemoved()
end

--------------------------------------------------------------------------------

function modifier_litvin_litenergy:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_litvin_litenergy:GetModifierConstantHealthRegen()
	return self.base_hp
end

function modifier_litvin_litenergy:GetModifierConstantManaRegen()
	return self.base_mana
end

function modifier_litvin_litenergy:GetModifierEvasion_Constant()
	return self.base_miss
end

function modifier_litvin_litenergy:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end
--------------------------------------------------------------------------------
