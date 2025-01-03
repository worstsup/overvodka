--------------------------------------------------------------------------------
mellstroy_shavel = class({})
LinkLuaModifier( "modifier_mellstroy_shavel", "heroes/mellstroy/modifier_mellstroy_shavel", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mellstroy_shavel_debuff", "heroes/mellstroy/modifier_mellstroy_shavel_debuff", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Init Abilities
function mellstroy_shavel:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_primal_beast.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_primal_beast/primal_beast_pulverize_hit.vpcf", context )
end

function mellstroy_shavel:Spawn()
	if not IsServer() then return end
end

function mellstroy_shavel:GetChannelAnimation()
	return ACT_DOTA_GENERIC_CHANNEL_1
end

--------------------------------------------------------------------------------
-- Ability Start
mellstroy_shavel.modifiers = {}
function mellstroy_shavel:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- cancel if linken
	if target:TriggerSpellAbsorb( self ) then
		caster:Interrupt()
		return
	end

	-- load data
	local duration = self:GetSpecialValueFor( "channel_time" )

	-- add modifier
	local mod = target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_mellstroy_shavel_debuff", -- modifier name
		{ duration = duration } -- kv
	)
	self.modifiers[mod] = true

	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_mellstroy_shavel", -- modifier name
		{ duration = duration } -- kv
	)

	-- play effects
	if target:IsCreep() then
		EmitSoundOn( "shavel", caster )
	else
		EmitSoundOn( "shavel", caster )
	end
end

--------------------------------------------------------------------------------
-- Ability Channeling
function mellstroy_shavel:GetChannelTime()
	return self:GetSpecialValueFor( "channel_time" )
end

function mellstroy_shavel:OnChannelFinish( bInterrupted )
	for mod,_ in pairs(self.modifiers) do
		if not mod:IsNull() then
			mod:Destroy()
		end
	end
	self.modifiers = {}

	local self_mod = self:GetCaster():FindModifierByName( "modifier_mellstroy_shavel" )
	if self_mod then
		self_mod:Destroy()
	end
end

function mellstroy_shavel:RemoveModifier( mod )
	self.modifiers[mod] = nil
	local has_enemies = false
	for _,mod in pairs(self.modifiers) do
		has_enemies = true
	end

	if not has_enemies then
		self:EndChannel( true )
	end
end