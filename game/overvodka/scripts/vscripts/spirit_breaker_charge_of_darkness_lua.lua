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
spirit_breaker_charge_of_darkness_lua = class({})
LinkLuaModifier( "modifier_spirit_breaker_charge_of_darkness_lua", "modifier_spirit_breaker_charge_of_darkness_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_spirit_breaker_charge_of_darkness_lua_debuff", "modifier_spirit_breaker_charge_of_darkness_lua_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_magresist", "modifier_magresist", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_BOTH )

--------------------------------------------------------------------------------
-- Init Abilities
function spirit_breaker_charge_of_darkness_lua:Precache( context )
	PrecacheResource( "particle", "particles/econ/items/primal_beast/primal_beast_2022_prestige/primal_beast_2022_prestige_onslaught_charge_mesh.vpcf", context )
	PrecacheResource( "particle", "particles/spirit_breaker_charge_target_new.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/gyrocopter/gyro_ti10_immortal_missile/gyro_ti10_immortal_crimson_missile_explosion.vpcf", context )
end

function spirit_breaker_charge_of_darkness_lua:Spawn()
	if not IsServer() then return end
end

--------------------------------------------------------------------------------
-- Ability Start
function spirit_breaker_charge_of_darkness_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- add charge modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_spirit_breaker_charge_of_darkness_lua", -- modifier name
		{ target = target:entindex() } -- kv
	)
end