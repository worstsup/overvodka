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
modifier_windranger_focus_fire_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_windranger_focus_fire_lua:IsHidden()
	return false
end

function modifier_windranger_focus_fire_lua:IsDebuff()
	return false
end

function modifier_windranger_focus_fire_lua:IsPurgable()
	return false
end

function modifier_windranger_focus_fire_lua:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_windranger_focus_fire_lua:OnCreated( kv )
	if not IsServer() then return end
	self.bonus = self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
	self.reduction = self:GetAbility():GetSpecialValueFor( "focusfire_damage_reduction" )
end

function modifier_windranger_focus_fire_lua:OnRefresh( kv )
	if not IsServer() then return end
	self.bonus = self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
	self.reduction = self:GetAbility():GetSpecialValueFor( "focusfire_damage_reduction" )
end

function modifier_windranger_focus_fire_lua:OnRemoved()
end

function modifier_windranger_focus_fire_lua:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_windranger_focus_fire_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK,
	}

	return funcs
end
function modifier_windranger_focus_fire_lua:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
	}

	return state
end

function modifier_windranger_focus_fire_lua:GetModifierAttackSpeedBonus_Constant()
	return self.bonus
end
function modifier_windranger_focus_fire_lua:GetModifierDamageOutgoing_Percentage()
	return self.reduction
end

function modifier_windranger_focus_fire_lua:OnAttack( params )
	if params.attacker~=self:GetParent() then return end
	self:GetParent():EmitSound("scar")
end