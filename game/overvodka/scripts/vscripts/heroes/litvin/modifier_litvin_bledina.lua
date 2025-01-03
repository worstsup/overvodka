modifier_litvin_bledina = class({})
--------------------------------------------------------------------------------
function modifier_litvin_bledina:IsPurgable()
	return false
end

function modifier_litvin_bledina:OnCreated( kv )
	self.bat = self:GetAbility():GetSpecialValueFor( "bat" )
end

--------------------------------------------------------------------------------

function modifier_litvin_bledina:OnRemoved()
end

--------------------------------------------------------------------------------

function modifier_litvin_bledina:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end

function modifier_litvin_bledina:GetModifierBaseAttackTimeConstant()
	return self.bat
end

function modifier_litvin_bledina:GetModifierAttackSpeedBonus_Constant()
	return 2000
end
--------------------------------------------------------------------------------
