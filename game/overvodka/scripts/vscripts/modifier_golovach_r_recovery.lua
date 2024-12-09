-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
modifier_golovach_r_recovery = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_golovach_r_recovery:IsHidden()
	return false
end

function modifier_golovach_r_recovery:IsDebuff()
	return true
end

function modifier_golovach_r_recovery:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_golovach_r_recovery:OnCreated( kv )
	self.parent = self:GetParent()
	-- references
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

	-- check main modifier
	local main = self.parent:FindModifierByNameAndCaster( "modifier_golovach_r", self.parent )
	if not main then return end

	-- check if forced destroy by main modifier
	if self.forced then return end

	-- add fury charge
	self.parent:AddNewModifier(
		self.parent, -- player source
		self:GetAbility(), -- ability source
		"modifier_golovach_r_fury", -- modifier name
		{} -- kv
	)

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_golovach_r_recovery:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
	}

	return funcs
end

function modifier_golovach_r_recovery:GetModifierFixedAttackRate( params )
	return self.rate
end

--------------------------------------------------------------------------------
-- Helper
function modifier_golovach_r_recovery:ForceDestroy()
	self.forced = true
	self:Destroy()
end
