modifier_underlord_firestorm_lua_thinker = class({})

function modifier_underlord_firestorm_lua_thinker:IsHidden()
	return true
end
function modifier_underlord_firestorm_lua_thinker:IsPurgable()
	return false
end

function modifier_underlord_firestorm_lua_thinker:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	local damage = self.ability:GetSpecialValueFor( "wave_damage" )
	local delay = self.ability:GetSpecialValueFor( "first_wave_delay" )
	self.radius = self.ability:GetSpecialValueFor( "radius" )
	self.count = self.ability:GetSpecialValueFor( "wave_count" )
	self.interval = self.ability:GetSpecialValueFor( "wave_interval" )
	self.burn_duration = self.ability:GetSpecialValueFor( "burn_duration" )
	self.burn_interval = self.ability:GetSpecialValueFor( "burn_interval" )
	self.burn_damage = self.ability:GetSpecialValueFor( "burn_damage" )
	if not IsServer() then return end
	self.wave = 0
	self.damageTable = {
		attacker = self.caster,
		damage = damage,
		damage_type = self.ability:GetAbilityDamageType(),
		ability = self.ability,
	}
	EmitSoundOn( "tetris", self.parent )
	self:StartIntervalThink( delay )
end

function modifier_underlord_firestorm_lua_thinker:OnRefresh( kv )
end
function modifier_underlord_firestorm_lua_thinker:OnRemoved()
end

function modifier_underlord_firestorm_lua_thinker:OnDestroy()
	if not IsServer() then return end
	UTIL_Remove( self:GetParent() )
end

function modifier_underlord_firestorm_lua_thinker:OnIntervalThink()
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
		ApplyDamage( self.damageTable )
		enemy:AddNewModifier(
			self.caster,
			self.ability,
			"modifier_underlord_firestorm_lua",
			{
				duration = self.burn_duration,
				interval = self.burn_interval,
				damage = self.burn_damage,
			}
		)
		enemy:AddNewModifier(
			self.caster,
			self.ability,
			"modifier_generic_stunned_lua", 
			{duration = self.burn_duration}
		)
	end
	self:PlayEffects()
	self.wave = self.wave + 1
	if self.wave>=self.count then
		StopSoundOn( "tetris", self.parent )
		self:Destroy()
	end
end

function modifier_underlord_firestorm_lua_thinker:PlayEffects()
	local particle_cast = "particles/abyssal_underlord_firestorm_wave_new.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, self.parent:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 4, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end