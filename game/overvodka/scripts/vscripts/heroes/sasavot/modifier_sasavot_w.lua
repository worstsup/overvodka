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
	if not IsServer() then return end
	self:SetStackCount(1)
	self.max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks")
	self.currentTarget = {}
end

function modifier_sasavot_w:OnRefresh( kv )
	if not IsServer() then return end
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

function modifier_sasavot_w:GetModifierSpellAmplify_Percentage()
	if self:GetParent():PassivesDisabled() then
		return 0
	end
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("spell")
end
function modifier_sasavot_w:GetModifierAttackSpeedBonus_Constant()
	if self:GetParent():PassivesDisabled() then
		return 0
	end
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("attack_speed")
end
function modifier_sasavot_w:GetModifierPhysicalArmorBonus()
	if self:GetParent():PassivesDisabled() then
		return 0
	end
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("armor")
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
