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
modifier_mellstroy_business_new = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_mellstroy_business_new:IsHidden()
	return false
end

function modifier_mellstroy_business_new:IsDebuff()
	return true
end

function modifier_mellstroy_business_new:IsStunDebuff()
	return false
end

function modifier_mellstroy_business_new:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_mellstroy_business_new:OnCreated( kv )
	if not IsServer() then return end
	self.slow = self:GetAbility():GetSpecialValueFor( "bonus_movespeed" )
	self.as = self:GetAbility():GetSpecialValueFor( "bonus_attackspeed" )
end

function modifier_mellstroy_business_new:OnRefresh( kv )
	if not IsServer() then return end
	self.slow = self:GetAbility():GetSpecialValueFor( "bonus_movespeed" )
	self.as = self:GetAbility():GetSpecialValueFor( "bonus_attackspeed" )
end

function modifier_mellstroy_business_new:OnRemoved()
end

function modifier_mellstroy_business_new:OnDestroy()
end
function modifier_mellstroy_business_new:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}

	return funcs
end
function modifier_mellstroy_business_new:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_mellstroy_business_new:GetModifierAttackSpeedBonus_Constant()
	return self.as
end
--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_mellstroy_business_new:GetEffectName()
	return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_jinda_slow.vpcf"
end

function modifier_mellstroy_business_new:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
