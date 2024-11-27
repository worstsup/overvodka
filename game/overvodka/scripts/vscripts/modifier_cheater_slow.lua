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
modifier_cheater_slow = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_cheater_slow:IsHidden()
	return false
end

function modifier_cheater_slow:IsDebuff()
	return true
end

function modifier_cheater_slow:IsStunDebuff()
	return false
end

function modifier_cheater_slow:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_cheater_slow:OnCreated( kv )
	-- references
	self.slow = self:GetAbility():GetSpecialValueFor( "slow" )

end

function modifier_cheater_slow:OnRefresh( kv )
	-- references
	self.slow = self:GetAbility():GetSpecialValueFor( "slow" )
end

function modifier_cheater_slow:OnRemoved()
end

function modifier_cheater_slow:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_cheater_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}

	return funcs
end

function modifier_cheater_slow:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow
end