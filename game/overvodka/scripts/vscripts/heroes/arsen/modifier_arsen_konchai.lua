modifier_arsen_konchai = class({})

function modifier_arsen_konchai:IsHidden() return false end
function modifier_arsen_konchai:IsDebuff() return true end
function modifier_arsen_konchai:IsStunDebuff() return false end
function modifier_arsen_konchai:IsPurgable() return true end

function modifier_arsen_konchai:OnCreated( kv )
	self.armor_stack = self:GetAbility():GetSpecialValueFor( "armor_per_stack" )
	self.slow_base = self:GetAbility():GetSpecialValueFor( "base_move_slow" )
	self.slow_stack = self:GetAbility():GetSpecialValueFor( "move_slow_per_stack" )

	if IsServer() then
		self:SetStackCount(1)
	end
end

function modifier_arsen_konchai:OnRefresh( kv )
	self.armor_stack = self:GetAbility():GetSpecialValueFor( "armor_per_stack" )
	self.slow_base = self:GetAbility():GetSpecialValueFor( "base_move_slow" )
	self.slow_stack = self:GetAbility():GetSpecialValueFor( "move_slow_per_stack" )
	local max_stack = self:GetAbility():GetSpecialValueFor( "stack_limit" )

	if IsServer() then
		if self:GetStackCount()<max_stack then
			self:IncrementStackCount()
		end
	end
end

function modifier_arsen_konchai:OnDestroy( kv )

end

function modifier_arsen_konchai:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end
function modifier_arsen_konchai:GetModifierPhysicalArmorBonus()
	return -self.armor_stack * self:GetStackCount()
end
function modifier_arsen_konchai:GetModifierMoveSpeedBonus_Percentage()
	return -(self.slow_base + self.slow_stack * self:GetStackCount())
end

function modifier_arsen_konchai:GetEffectName()
	return "particles/bristleback_viscous_nasal_goo_debuff_new.vpcf"
end

function modifier_arsen_konchai:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end