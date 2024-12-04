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
modifier_shkolnik_armor = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_shkolnik_armor:IsHidden()
	return true
end

function modifier_shkolnik_armor:IsDebuff()
	return true
end

function modifier_shkolnik_armor:IsStunDebuff()
	return false
end

function modifier_shkolnik_armor:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_shkolnik_armor:OnCreated( kv )
	self.armor = self:GetAbility():GetSpecialValueFor( "armor" )
end

function modifier_shkolnik_armor:OnRefresh( kv )
	-- references
	self.armor = self:GetAbility():GetSpecialValueFor( "armor" )
end

function modifier_shkolnik_armor:OnRemoved()
end

function modifier_shkolnik_armor:OnDestroy()
end
function modifier_shkolnik_armor:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}

	return funcs
end

function modifier_shkolnik_armor:GetModifierPhysicalArmorBonus()
	return self.armor
end
--------------------------------------------------------------------------------
