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
modifier_golovach_slow = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_golovach_slow:IsHidden()
	return false
end

function modifier_golovach_slow:IsDebuff()
	return true
end

function modifier_golovach_slow:IsStunDebuff()
	return false
end

function modifier_golovach_slow:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_golovach_slow:OnCreated( kv )
	-- references
	self.slow = 15

end

function modifier_golovach_slow:OnRefresh( kv )
	-- references
	self.slow = 15
end

function modifier_golovach_slow:OnRemoved()
end

function modifier_golovach_slow:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_golovach_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}

	return funcs
end
function modifier_golovach_slow:CheckState()
	local state = {
		[MODIFIER_STATE_PROVIDES_VISION] = true,
	}

	return state
end
function modifier_golovach_slow:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow
end