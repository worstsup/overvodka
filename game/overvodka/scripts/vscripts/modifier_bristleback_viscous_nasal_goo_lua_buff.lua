modifier_bristleback_viscous_nasal_goo_lua_buff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_bristleback_viscous_nasal_goo_lua_buff:IsHidden()
	return false
end

function modifier_bristleback_viscous_nasal_goo_lua_buff:IsDebuff()
	return false
end

function modifier_bristleback_viscous_nasal_goo_lua_buff:IsStunDebuff()
	return false
end

function modifier_bristleback_viscous_nasal_goo_lua_buff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_bristleback_viscous_nasal_goo_lua_buff:OnCreated( kv )
	-- references
	self.armor_stack = self:GetAbility():GetSpecialValueFor( "armor_per_stack" )
	self.slow_base = self:GetAbility():GetSpecialValueFor( "base_move_slow" )
	self.slow_stack = self:GetAbility():GetSpecialValueFor( "move_slow_per_stack" )

	if IsServer() then
		self:SetStackCount(1)
	end
end

function modifier_bristleback_viscous_nasal_goo_lua_buff:OnRefresh( kv )
	-- references
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

function modifier_bristleback_viscous_nasal_goo_lua_buff:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_bristleback_viscous_nasal_goo_lua_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}

	return funcs
end
function modifier_bristleback_viscous_nasal_goo_lua_buff:GetModifierPhysicalArmorBonus()
	return self.armor_stack * self:GetStackCount()
end
