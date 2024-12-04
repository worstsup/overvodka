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
mellstroy_business_new = class({})
LinkLuaModifier( "modifier_generic_orb_effect_lua", "modifier_generic_orb_effect_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mellstroy_business_new", "modifier_mellstroy_business_new", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function mellstroy_business_new:GetIntrinsicModifierName()
	return "modifier_generic_orb_effect_lua"
end

--------------------------------------------------------------------------------
-- Ability Start
function mellstroy_business_new:OnSpellStart()
end

--------------------------------------------------------------------------------
-- Orb Effects
function mellstroy_business_new:OnOrbImpact( params )
	-- get reference
	local duration = self:GetSpecialValueFor( "duration" )
	local gold_cost = self:GetSpecialValueFor( "gold_cost" )
	local percent = self:GetSpecialValueFor( "percent" )
	local player_id = self:GetCaster():GetPlayerID()
	local gold = PlayerResource:GetGold(player_id)
	local damage = gold_cost + percent * 0.01 * gold
	if gold < damage  then
		ability:EndCooldown()
		return
	end
	PlayerResource:SpendGold(player_id, damage, 4)
	local sound_cast = "biznes"
	EmitSoundOn( sound_cast, self:GetCaster() )
	ApplyDamage({attacker = self:GetCaster(), victim = params.target, ability = self, damage = damage, damage_type = DAMAGE_TYPE_PURE})
	-- add debuff
	params.target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_mellstroy_business_new", -- modifier name
		{ duration = duration } -- kv
	)
end