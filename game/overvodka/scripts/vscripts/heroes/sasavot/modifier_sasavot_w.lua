modifier_sasavot_w = class({})


function modifier_sasavot_w:IsHidden( kv )
	return false
end
function modifier_sasavot_w:IsDebuff( kv )
	return false
end
function modifier_sasavot_w:IsPurgable( kv )
	return false
end
function modifier_sasavot_w:RemoveOnDeath( kv )
	return false
end


function modifier_sasavot_w:OnCreated( kv )
	self:SetStackCount(1)
	self.stack_multiplier = self:GetAbility():GetSpecialValueFor("attack_speed")
	self.stack_multiplier_armor = self:GetAbility():GetSpecialValueFor("armor")
	self.stack_multiplier_spell = self:GetAbility():GetSpecialValueFor("spell")
	self.max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks")
	self.currentTarget = {}
end

function modifier_sasavot_w:OnRefresh( kv )
	self.stack_multiplier = self:GetAbility():GetSpecialValueFor("attack_speed")
	self.stack_multiplier_armor = self:GetAbility():GetSpecialValueFor("armor")
	self.stack_multiplier_spell = self:GetAbility():GetSpecialValueFor("spell")
	self.max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks")
end


function modifier_sasavot_w:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}
	return funcs
end

function modifier_sasavot_w:OnAttack( params )
	if IsServer() then
		pass = false
		if params.attacker==self:GetParent() then
			pass = true
		end
		if pass then
			if self.currentTarget==params.target then
				if params.target:HasModifier("modifier_sasavot_r_new_secondary") then
					self:SetStackCount(10)
				else
					self:AddStack()
				end
			else
				self:ResetStack()
				self.currentTarget = params.target
			end
		end
	end
end
function modifier_sasavot_w:GetModifierSpellAmplify_Percentage( params )
	local passive = 1
	if self:GetParent():PassivesDisabled() then
		passive = 0
	end
	return self:GetStackCount() * self.stack_multiplier_spell * passive
end
function modifier_sasavot_w:GetModifierAttackSpeedBonus_Constant( params )
	local passive = 1
	if self:GetParent():PassivesDisabled() then
		passive = 0
	end
	return self:GetStackCount() * self.stack_multiplier * passive
end
function modifier_sasavot_w:GetModifierPhysicalArmorBonus( params )
	local passive = 1
	if self:GetParent():PassivesDisabled() then
		passive = 0
	end
	return self:GetStackCount() * self.stack_multiplier_armor * passive
end


function modifier_sasavot_w:AddStack()
	if not self:GetParent():PassivesDisabled() then
		if self:GetStackCount() < self.max_stacks then
			self:IncrementStackCount()
		end
	end
end

function modifier_sasavot_w:ResetStack()
	if not self:GetParent():PassivesDisabled() then
		self:SetStackCount(1)
	end
end
