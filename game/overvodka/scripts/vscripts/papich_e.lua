papich_e = class({})
papich_e_release = class({})
LinkLuaModifier( "modifier_papich_e_charge", "modifier_papich_e_charge.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_papich_e", "modifier_papich_e.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_papich_e_command", "papich_e.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_arc_lua", "modifier_generic_arc_lua.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua.lua", LUA_MODIFIER_MOTION_NONE )

function papich_e:Precache( context )
	PrecacheResource( "particle", "particles/units/heroes/hero_primal_beast/primal_beast_onslaught_charge_active.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_primal_beast/primal_beast_onslaught_impact.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_primal_beast/primal_beast_onslaught_chargeup.vpcf", context )
	PrecacheResource( "particle", "particles/primal_beast_onslaught_range_finder_new.vpcf", context )
end

function papich_e:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local team = caster:GetTeam()
	local point = 0
	local fountainEntities = Entities:FindAllByClassname( "ent_dota_fountain")
	for _,fountainEnt in pairs( fountainEntities ) do
		if fountainEnt:GetTeamNumber() == caster:GetTeamNumber() then
			point = fountainEnt:GetAbsOrigin()
			break
		end
    end
    caster:FaceTowards(point)
	-- load data
	local duration = self:GetSpecialValueFor( "chargeup_time" )
	-- add modifier
	local mod = caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_papich_e_charge", -- modifier name
		{ duration = duration } -- kv
	)
	local mod = caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_papich_e_command", -- modifier name
		{ duration = duration } -- kv
	)
end

function papich_e:OnChargeFinish( interrupt )
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local max_duration = self:GetSpecialValueFor( "chargeup_time" )
	local max_distance = self:GetSpecialValueFor( "max_distance" )
	local speed = self:GetSpecialValueFor( "charge_speed" )

	-- find charge modifier
	local charge_duration = max_duration
	local mod = caster:FindModifierByName( "modifier_papich_e_charge" )
	if mod then
		charge_duration = mod:GetElapsedTime()

		mod.charge_finish = true
		mod:Destroy()
	end

	local distance = max_distance * charge_duration/max_duration
	local duration = distance/speed

	-- cancel if interrupted
	if interrupt then return end

	-- add modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_papich_e", -- modifier name
		{ duration = -1 } -- kv
	)

	-- play effects
end

--------------------------------------------------------------------------------
-- Sub-ability
function papich_e_release:OnSpellStart()
	self.main:OnChargeFinish( false )
end

modifier_papich_e_command = class({})
function modifier_papich_e_command:IsHidden()
	return true
end

function modifier_papich_e_command:IsDebuff()
	return false
end

function modifier_papich_e_command:IsPurgable()
	return false
end
function modifier_papich_e_command:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}

	return state
end