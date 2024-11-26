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
modifier_dimon_sdvg = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_dimon_sdvg:IsHidden()
	return true
end

function modifier_dimon_sdvg:IsDebuff()
	return false
end

function modifier_dimon_sdvg:IsStunDebuff()
	return false
end

function modifier_dimon_sdvg:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_dimon_sdvg:OnCreated( kv )
	if not IsServer() then return end
end

function modifier_dimon_sdvg:OnRefresh( kv )
	
end

function modifier_dimon_sdvg:OnRemoved()
end

function modifier_dimon_sdvg:OnDestroy()
end

--------------------------------------------------------------------------------
-- Graphics & Animations

function modifier_dimon_sdvg:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_dimon_sdvg:StatusEffectPriority()
	return MODIFIER_PRIORITY_MONKAGIGA_EXTEME_HYPER_ULTRA_REINFORCED_V9
end