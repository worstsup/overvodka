modifier_sasavot_w = class({})

function modifier_sasavot_w:IsHidden() return (self:GetStackCount() == 0) end
function modifier_sasavot_w:IsDebuff() return false end
function modifier_sasavot_w:IsPurgable() return false end
function modifier_sasavot_w:RemoveOnDeath() return false end

function modifier_sasavot_w:OnCreated()
	if not IsServer() then return end
	self:SetStackCount(0)
	self.max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks")
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
end

function modifier_sasavot_w:OnRefresh()
	if not IsServer() then return end
	self.max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks")
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
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
			if params.target:HasModifier("modifier_sasavot_r_new_secondary") then
				for i=1,10 do
					self:AddStack()
				end
			else
				self:AddStack()
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

function modifier_sasavot_w:RemoveStack()
	self:DecrementStackCount()
end

function modifier_sasavot_w:AddStack()
	if not self:GetParent():PassivesDisabled() then
		if self:GetStackCount() < self.max_stacks then
			local mod = self:GetParent():AddNewModifier(
				self:GetParent(),
				self:GetAbility(),
				"modifier_sasavot_w_stack",
				{
					duration = self.duration,
				}
			)
			mod.modifier = self
			self:IncrementStackCount()
		end
	end
end

modifier_sasavot_w_stack = class({})

function modifier_sasavot_w_stack:IsHidden() return true end
function modifier_sasavot_w_stack:IsPurgable() return false end
function modifier_sasavot_w_stack:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_sasavot_w_stack:OnCreated( kv )
end

function modifier_sasavot_w_stack:OnRemoved()
	if IsServer() then
		self.modifier:RemoveStack()
	end
end