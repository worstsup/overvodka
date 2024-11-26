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
modifier_axe_berserkers_call_lol_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_axe_berserkers_call_lol_debuff:IsHidden()
	return false
end

function modifier_axe_berserkers_call_lol_debuff:IsDebuff()
	return true
end

function modifier_axe_berserkers_call_lol_debuff:IsStunDebuff()
	return false
end

function modifier_axe_berserkers_call_lol_debuff:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_axe_berserkers_call_lol_debuff:OnCreated( kv )
	self.lose_strength = self:GetParent():GetStrength() / 2.5
end

function modifier_axe_berserkers_call_lol_debuff:OnRefresh( kv )
	self.lose_strength = self:GetParent():GetStrength() / 2.5
end

function modifier_axe_berserkers_call_lol_debuff:OnRemoved()
end

function modifier_axe_berserkers_call_lol_debuff:OnDestroy()
end

function modifier_axe_berserkers_call_lol_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MODEL_SCALE,
	}

	return funcs
end

function modifier_axe_berserkers_call_lol_debuff:GetModifierBonusStats_Strength( params )
	return -self.lose_strength
end
function modifier_axe_berserkers_call_lol_debuff:GetModifierModelScale()
	return -30
end

function modifier_axe_berserkers_call_lol_debuff:GetEffectName()
	return "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf"
end

function modifier_axe_berserkers_call_lol_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end