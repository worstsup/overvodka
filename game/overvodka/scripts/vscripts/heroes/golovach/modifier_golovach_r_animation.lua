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
modifier_golovach_r_animation = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_golovach_r_animation:IsHidden()
	return true
end

function modifier_golovach_r_animation:IsDebuff()
	return false
end

function modifier_golovach_r_animation:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_golovach_r_animation:OnCreated( kv )
end

function modifier_golovach_r_animation:OnDestroy( kv )
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_golovach_r_animation:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}

	return funcs
end

function modifier_golovach_r_animation:GetActivityTranslationModifiers()
	return "unleash"
end