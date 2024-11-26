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
local MODIFIER_PRIORITY_MONKAGIGA_EXTEME_HYPER_ULTRA_REINFORCED_V9 = 10001

--------------------------------------------------------------------------------
modifier_patriotizm = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_patriotizm:IsHidden()
	return true
end

function modifier_patriotizm:IsDebuff()
	return false
end

function modifier_patriotizm:IsStunDebuff()
	return false
end

function modifier_patriotizm:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_patriotizm:OnCreated( kv )
	if not IsServer() then return end
end
function modifier_patriotizm:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}

	return state
end

function modifier_patriotizm:OnRefresh( kv )
	
end

function modifier_patriotizm:OnRemoved()
end

function modifier_patriotizm:OnDestroy()
end
