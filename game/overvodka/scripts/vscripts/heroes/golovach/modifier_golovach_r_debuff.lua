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
modifier_golovach_r_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_golovach_r_debuff:IsHidden()
	return false
end

function modifier_golovach_r_debuff:IsDebuff()
	return true
end

function modifier_golovach_r_debuff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_golovach_r_debuff:OnCreated( kv )
	-- references
	self.as_slow = -self:GetAbility():GetSpecialValueFor( "pulse_attack_slow_pct" )
	self.ms_slow = -self:GetAbility():GetSpecialValueFor( "pulse_move_slow_pct" )

	if not IsServer() then return end
end

function modifier_golovach_r_debuff:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_golovach_r_debuff:OnRemoved()
end

function modifier_golovach_r_debuff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_golovach_r_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_golovach_r_debuff:GetModifierAttackSpeedBonus_Constant()
	return self.as_slow
end

function modifier_golovach_r_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_slow
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_golovach_r_debuff:GetEffectName()
	return "particles/units/heroes/hero_marci/marci_unleash_pulse_debuff.vpcf"
end

function modifier_golovach_r_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_golovach_r_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_snapfire_slow.vpcf"
end

function modifier_golovach_r_debuff:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end