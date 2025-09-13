silvername_r = class({})
LinkLuaModifier( "modifier_silvername_r_thinker", "heroes/silvername/silvername_r", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua.lua", LUA_MODIFIER_MOTION_NONE )

function silvername_r:Precache(context)
	PrecacheResource( "soundfile", "soundevents/silvername_r.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/silvername_r_start.vsndevts", context )
	PrecacheResource( "particle", "particles/econ/items/gyrocopter/gyro_ti10_immortal_missile/gyro_ti10_immortal_crimson_missile_explosion.vpcf", context )
	PrecacheResource( "particle", "particles/underlord_firestorm_pre_new.vpcf", context )
	PrecacheResource( "particle", "particles/abyssal_underlord_firestorm_wave_new.vpcf", context )
end

function silvername_r:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function silvername_r:OnAbilityPhaseStart()
	local point = self:GetCursorPosition()
	self:PlayEffects( point )
	return true
end

function silvername_r:OnAbilityPhaseInterrupted()
	self:StopEffects()
end

function silvername_r:OnSpellStart()
	self:StopEffects()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	CreateModifierThinker(
		caster,
		self,
		"modifier_silvername_r_thinker",
		{},
		point,
		caster:GetTeamNumber(),
		false
	)
end

function silvername_r:PlayEffects( point )
	local particle_cast = "particles/underlord_firestorm_pre_new.vpcf"
	local sound_cast = "silvername_r_start"
	local radius = self:GetSpecialValueFor( "radius" )
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( self.effect_cast, 0, point )
	ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( 2, 2, 2 ) )
	EmitSoundOnLocationWithCaster( point, sound_cast, self:GetCaster() )
end

function silvername_r:StopEffects()
	ParticleManager:DestroyParticle( self.effect_cast, true )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )
end

modifier_silvername_r_thinker = class({})

function modifier_silvername_r_thinker:IsHidden()
	return true
end
function modifier_silvername_r_thinker:IsPurgable()
	return false
end

function modifier_silvername_r_thinker:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	local damage = self.ability:GetSpecialValueFor( "wave_damage" )
	local delay = self.ability:GetSpecialValueFor( "first_wave_delay" )
	self.radius = self.ability:GetSpecialValueFor( "radius" )
	self.count = self.ability:GetSpecialValueFor( "wave_count" )
	self.interval = self.ability:GetSpecialValueFor( "wave_interval" )
	self.stun_duration = self.ability:GetSpecialValueFor( "stun_duration" )
	if not IsServer() then return end
	self.wave = 0
	self.damageTable = {
		attacker = self.caster,
		damage = damage,
		damage_type = self.ability:GetAbilityDamageType(),
		ability = self.ability,
	}
	EmitSoundOn( "silvername_r", self.parent )
	self:StartIntervalThink( delay )
end

function modifier_silvername_r_thinker:OnDestroy()
	if not IsServer() then return end
	UTIL_Remove( self:GetParent() )
end

function modifier_silvername_r_thinker:OnIntervalThink()
	if not self.delayed then
		self.delayed = true
		self:StartIntervalThink( self.interval )
		self:OnIntervalThink()
		return
	end
	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(),
		self.parent:GetOrigin(),
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		0,
		false
	)
	for _,enemy in pairs(enemies) do
		self.damageTable.victim = enemy
		enemy:AddNewModifier(
			self.caster,
			self.ability,
			"modifier_generic_stunned_lua", 
			{duration = self.stun_duration}
		)
		local particle = ParticleManager:CreateParticle("particles/econ/items/gyrocopter/gyro_ti10_immortal_missile/gyro_ti10_immortal_crimson_missile_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
		ParticleManager:ReleaseParticleIndex( particle )
		ApplyDamage( self.damageTable )
	end
	self:PlayEffects()
	self.wave = self.wave + 1
	if self.wave>=self.count then
		StopSoundOn( "silvername_r", self.parent )
		self:Destroy()
	end
end

function modifier_silvername_r_thinker:PlayEffects()
	local particle_cast = "particles/abyssal_underlord_firestorm_wave_new.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, self.parent:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 4, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end