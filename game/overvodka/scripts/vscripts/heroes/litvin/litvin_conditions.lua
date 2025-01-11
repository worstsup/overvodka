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
litvin_conditions = class({})
LinkLuaModifier( "modifier_litvin_conditions", "heroes/litvin/modifier_litvin_conditions", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_generic_arc_lua", "modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function litvin_conditions:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------
-- Ability Cast Filter
function litvin_conditions:CastFilterResultTarget( hTarget )
	if self:GetCaster() == hTarget then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function litvin_conditions:GetCustomCastErrorTarget( hTarget )
	if self:GetCaster() == hTarget then
		return "#dota_hud_error_cant_cast_on_self"
	end

	return "#dota_hud_error_nothing_to_toss"
end

--------------------------------------------------------------------------------
-- Helper
function litvin_conditions:FindEnemies()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor( "grab_radius" )

	-- find unit around tiny
	local units = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
		FIND_CLOSEST,	-- int, order filter
		false	-- bool, can grow cache
	)

	local target
	for _,unit in pairs(units) do
		local filter1 = (unit~=caster) and (not unit:IsAncient()) and (not unit:FindModifierByName( 'modifier_litvin_conditions' ))
		local filter2 = (unit:GetTeamNumber()==caster:GetTeamNumber()) or (not unit:IsInvisible())
		if filter1 then
			if filter2 then
				target = unit
				break
			end
		end
	end

	return target
end

--------------------------------------------------------------------------------
-- Ability Phase Start
function litvin_conditions:OnAbilityPhaseInterrupted()

end
function litvin_conditions:OnAbilityPhaseStart()
	return self:FindEnemies()
	-- return true -- if success
end

--------------------------------------------------------------------------------
-- Ability Start
function litvin_conditions:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(self) then return end
	-- local point = self:GetCursorPosition()

	-- get victim
	local victim = self:FindEnemies()

	-- add modifier
	victim:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_litvin_conditions", -- modifier name
		{
			target = target:entindex(),
		} -- kv
	)

end