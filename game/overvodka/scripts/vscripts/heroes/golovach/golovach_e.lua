golovach_e = class({})
LinkLuaModifier( "modifier_golovach_e", "heroes/golovach/modifier_golovach_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_golovach_run", "heroes/golovach/modifier_golovach_run", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_marci_sidekick_lua", "modifier_marci_sidekick_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_knockback_lua", "modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function golovach_e:Precache( context )
	PrecacheResource( "particle", "particles/units/heroes/hero_invoker/invoker_cold_snap.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_invoker/invoker_cold_snap_status.vpcf", context )
	PrecacheResource( "particle", "particles/muerta_ultimate_form_screen_effect_new.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/am_basher_c_gold.vpcf", context )
end
function golovach_e:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(self) then return end
	-- load data
	local duration = self:GetSpecialValueFor("duration")
	EmitSoundOn( "golovach_e_start", self:GetCaster() )
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_golovach_run", {target = target:entindex(), duration = duration})
	-- logic
	self:GetCaster():AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_marci_sidekick_lua", -- modifier name
		{ duration = duration } -- kv
	)
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_golovach_e", -- modifier name
		{ duration = duration } -- kv
	)

	self:PlayEffects( target )
end

--------------------------------------------------------------------------------
function golovach_e:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_invoker/invoker_cold_snap.vpcf"

	-- Get Data
	local direction = target:GetOrigin()-self:GetCaster():GetOrigin()

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, self:GetCaster():GetOrigin() + direction )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end