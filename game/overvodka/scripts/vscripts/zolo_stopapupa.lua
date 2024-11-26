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
zolo_stopapupa = class({})
LinkLuaModifier( "modifier_generic_orb_effect_lua", "modifier_generic_orb_effect_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zolo_stopapupa", "modifier_zolo_stopapupa", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function zolo_stopapupa:GetIntrinsicModifierName()
	return "modifier_generic_orb_effect_lua"
end

--------------------------------------------------------------------------------
-- Ability Start
function zolo_stopapupa:OnSpellStart()
end

--------------------------------------------------------------------------------
-- Orb Effects
function zolo_stopapupa:OnOrbImpact( params )
	-- get reference
	local duration = self:GetSpecialValueFor( "armor_duration" )
	local bash = self:GetSpecialValueFor( "ministun_duration" )
	local chance = self:GetSpecialValueFor( "chance" )
	local str = self:GetCaster():GetStrength()
	local damage = self:GetSpecialValueFor( "str_damage" ) * str
	local random_chance = RandomInt(1, 100)
	if random_chance <= chance then
		self:GetCaster():ModifyGold(300, false, 0)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, self:GetCaster(), 300, nil)
	end
	-- add debuff
	ApplyDamage({victim = params.target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self})
	params.target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_zolo_stopapupa", -- modifier name
		{ duration = duration } -- kv
	)

	-- add ministun
	params.target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_dark_willow_debuff_fear", -- modifier name
		{ duration = bash } -- kv
	)
end