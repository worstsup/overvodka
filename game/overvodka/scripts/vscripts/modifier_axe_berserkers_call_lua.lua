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
modifier_axe_berserkers_call_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_axe_berserkers_call_lua:IsHidden()
	return false
end

function modifier_axe_berserkers_call_lua:IsDebuff()
	return false
end

function modifier_axe_berserkers_call_lua:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_axe_berserkers_call_lua:OnCreated( kv )
	-- references
	self.armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
	self.str = self:GetAbility():GetSpecialValueFor( "bonus_str" )
end

function modifier_axe_berserkers_call_lua:OnRefresh( kv )
	-- references
	self.armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
	self.str = self:GetAbility():GetSpecialValueFor( "bonus_str" )
end

function modifier_axe_berserkers_call_lua:OnRemoved()
end

function modifier_axe_berserkers_call_lua:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_axe_berserkers_call_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}

	return funcs
end

function modifier_axe_berserkers_call_lua:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_axe_berserkers_call_lua:GetModifierModelScale()
	return 40
end

function modifier_axe_berserkers_call_lua:GetModifierBonusStats_Strength()
	return self.str
end
--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_axe_berserkers_call_lua:GetEffectName()
	return "particles/econ/items/ogre_magi/ogre_ti8_immortal_weapon/ogre_ti8_immortal_bloodlust_buff.vpcf"
end

function modifier_axe_berserkers_call_lua:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


