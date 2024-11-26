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
razor_plasma_field_lua = class({})
LinkLuaModifier( "modifier_razor_plasma_field_lua", "modifier_razor_plasma_field_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_ring_lua", "modifier_generic_ring_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_topor", "modifier_topor", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_marci_sidekick_lua", "modifier_marci_sidekick_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Init Abilities
function razor_plasma_field_lua:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_razor.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_terrorblade/terrorblade_scepter_ground_proj.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_terrorblade/terrorblade_scepter.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_sidekick_self_buff.vpcf", context )
	PrecacheResource( "particle", "particles/status_fx/status_effect_marci_sidekick.vpcf", context )
end

function razor_plasma_field_lua:Spawn()
	if not IsServer() then return end
end

--------------------------------------------------------------------------------
-- Ability Start
function razor_plasma_field_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_topor", { duration = 10 } )
	-- load data
	local radius = self:GetSpecialValueFor( "radius" )
	local speed = self:GetSpecialValueFor( "speed" )
	local buff_duration = self:GetSpecialValueFor( "buff_duration" )
	-- play effects
	local effect = self:PlayEffects( radius, speed )
	local effect_new = self:PlayEffectsNew( )
	-- create ring
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_marci_sidekick_lua", -- modifier name
		{ duration = buff_duration } -- kv
	)
	local pulse = caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_generic_ring_lua", -- modifier name
		{
			end_radius = radius,
			speed = speed,
			target_team = DOTA_UNIT_TARGET_TEAM_ENEMY,
			target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		} -- kv
	)
	pulse:SetCallback( function( enemy )
		self:OnHit( enemy )
	end)
end

function razor_plasma_field_lua:OnHit( enemy )
	local caster = self:GetCaster()
	-- load data
	local radius = self:GetSpecialValueFor( "radius" )
	local damage_min = self:GetSpecialValueFor( "damage_min" )
	local damage_max = self:GetSpecialValueFor( "damage_max" )
	local slow_min = self:GetSpecialValueFor( "slow_min" )
	local slow_max = self:GetSpecialValueFor( "slow_max" )
	local duration = self:GetSpecialValueFor( "slow_duration" )
	-- calculate damage & slow
	local distance = (enemy:GetOrigin()-caster:GetOrigin()):Length2D()
	local pct = distance/radius
	pct = math.min(pct,1)
	local damage = damage_min + (damage_max-damage_min)*pct
	local slow = slow_min + (slow_max-slow_min)*pct

	-- apply damage
	local damageTable = {
		victim = enemy,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)
	enemy:AddNewModifier(caster, self, "modifier_dark_willow_debuff_fear", {duration = duration})
	-- slow
	enemy:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_razor_plasma_field_lua", -- modifier name
		{
			duration = duration,
			slow = slow,
		} -- kv
	)
	-- Play effects
	-- self:PlayEffects2( enemy )
	local sound_cast = "Ability.PlasmaFieldImpact"
	EmitSoundOn( sound_cast, enemy )
end

--------------------------------------------------------------------------------
-- Effects
function razor_plasma_field_lua:PlayEffects( radius, speed )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_terrorblade/terrorblade_scepter_ground_proj.vpcf"
	local sound_cast = "serega_topor"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( speed, radius, 1 ) )

	EmitGlobalSound( sound_cast )

	return effect_cast
end

function razor_plasma_field_lua:PlayEffectsNew()
	local particle_cast = "particles/units/heroes/hero_terrorblade/terrorblade_scepter.vpcf"
	local effect_cast_new = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex( effect_cast_new )
end
