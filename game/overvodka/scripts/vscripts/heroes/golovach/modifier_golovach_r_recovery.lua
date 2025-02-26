modifier_golovach_r_recovery = class({})

function modifier_golovach_r_recovery:IsHidden()
	return false
end

function modifier_golovach_r_recovery:IsDebuff()
	return true
end

function modifier_golovach_r_recovery:IsPurgable()
	return false
end

function modifier_golovach_r_recovery:OnCreated( kv )
	self.parent = self:GetParent()
	self.rate = self:GetAbility():GetSpecialValueFor( "recovery_fixed_attack_rate" )

	if not IsServer() then return end
	self.success = kv.success==1
end

function modifier_golovach_r_recovery:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_golovach_r_recovery:OnRemoved()
end

function modifier_golovach_r_recovery:OnDestroy()
	if not IsServer() then return end
	local main = self.parent:FindModifierByNameAndCaster( "modifier_golovach_r", self.parent )
	if not main then return end
	if self.forced then return end
	self.parent:AddNewModifier(
		self.parent,
		self:GetAbility(),
		"modifier_golovach_r_fury",
		{}
	)

end

function modifier_golovach_r_recovery:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
	}

	return funcs
end

function modifier_golovach_r_recovery:GetModifierFixedAttackRate( params )
	return self.rate
end

function modifier_golovach_r_recovery:ForceDestroy()
	self.forced = true
	self:Destroy()
end
