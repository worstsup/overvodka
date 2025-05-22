mellstroy_shavel = class({})
LinkLuaModifier( "modifier_mellstroy_shavel", "heroes/mellstroy/modifier_mellstroy_shavel", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mellstroy_shavel_debuff", "heroes/mellstroy/modifier_mellstroy_shavel_debuff", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua.lua", LUA_MODIFIER_MOTION_NONE )

function mellstroy_shavel:Precache( context )
	PrecacheResource( "particle", "particles/units/heroes/hero_primal_beast/primal_beast_pulverize_hit.vpcf", context )
end

function mellstroy_shavel:Spawn()
	if not IsServer() then return end
end

function mellstroy_shavel:GetChannelAnimation()
	return ACT_DOTA_GENERIC_CHANNEL_1
end

mellstroy_shavel.modifiers = {}
function mellstroy_shavel:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb( self ) then
		caster:Interrupt()
		return
	end
	local duration = self:GetSpecialValueFor( "channel_time" )
	if target:HasModifier("modifier_generic_motion") then
		target:RemoveModifierByName("modifier_generic_motion")
	end
	if target:HasModifier("modifier_knockback") then
		target:RemoveModifierByName("modifier_knockback")
	end
	if target:HasModifier("modifier_generic_knockback_lua") then
		target:RemoveModifierByName("modifier_generic_knockback_lua")
	end
	local mod = target:AddNewModifier(
		caster,
		self,
		"modifier_mellstroy_shavel_debuff",
		{ duration = duration }
	)
	self.modifiers[mod] = true

	caster:AddNewModifier(
		caster,
		self,
		"modifier_mellstroy_shavel",
		{ duration = duration }
	)
	if target:IsCreep() then
		EmitSoundOn( "shavel", caster )
	else
		EmitSoundOn( "shavel", caster )
	end
end

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