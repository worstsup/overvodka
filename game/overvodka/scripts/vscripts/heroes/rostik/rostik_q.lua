LinkLuaModifier( "modifier_rostik_q", "heroes/rostik/rostik_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )

rostik_q = class({})

function rostik_q:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor( "brew_explosion" )
	caster:AddNewModifier(
		caster,
		self,
		"modifier_rostik_q",
		{ duration = duration }
	)
	local ability = caster:FindAbilityByName( "rostik_q_throw" )
	if not ability then
		ability = caster:AddAbility( "rostik_q_throw" )
		ability:SetStolen( true )
	end
	ability:SetLevel( self:GetLevel() )
	caster:SwapAbilities(
		self:GetAbilityName(),
		ability:GetAbilityName(),
		false,
		true
	)
end

rostik_q_throw = class({})

function rostik_q_throw:GetAOERadius()
	return self:GetSpecialValueFor( "midair_explosion_radius" )
end
function rostik_q_throw:OnUpgrade()
	local ability = self:GetCaster():FindAbilityByName( "rostik_q" )
	ability:SetLevel( self:GetLevel() )
end

function rostik_q_throw:CastFilterResultLocation(location)
	return UF_SUCCESS
end
function rostik_q_throw:IsStealable()
	return false
end
function rostik_q_throw:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local point = self:GetCursorPosition()
	local max_brew = self:GetSpecialValueFor("brew_time")
	local projectile_name = "particles/rostik_q.vpcf"
	local projectile_name_2 = "particles/rostik_q_2.vpcf"
	local projectile_speed = self:GetSpecialValueFor("movement_speed")
	local projectile_vision = self:GetSpecialValueFor("vision_range")
	local brew_time

	local modifier = caster:FindModifierByName("modifier_rostik_q")
	if modifier then
		brew_time = math.min(GameRules:GetGameTime() - modifier:GetCreationTime(), max_brew)
		modifier:Destroy()
	elseif rostik_q_throw.reflected_brew_time then
		brew_time = rostik_q_throw.reflected_brew_time
	elseif self.stored_brew_time then
		brew_time = self.stored_brew_time
	else
		brew_time = 0
	end
	self.brew_time = brew_time

	local info = {
		Source = caster,
		Ability = self,
		bVisibleToEnemies = true,
		bProvidesVision = true,
		iVisionRadius = projectile_vision,
		iVisionTeamNumber = caster:GetTeamNumber(),
		ExtraData = {
			brew_time = brew_time,
		}
	}

	if target then
		info.Target = target
		info.iMoveSpeed = projectile_speed
		info.bDodgeable = false
		info.EffectName = projectile_name
		ProjectileManager:CreateTrackingProjectile(info)
	else
		info.vVelocity = (point - caster:GetOrigin()):Normalized() * projectile_speed
		info.fDistance = (point - caster:GetOrigin()):Length2D()
		info.vSpawnOrigin  = self:GetCaster():GetOrigin()
		info.EffectName = projectile_name_2
		ProjectileManager:CreateLinearProjectile(info)
	end

	local sound_cast = "rostik_q_fly"
	EmitSoundOn(sound_cast, caster)

	local ability = caster:FindAbilityByName("rostik_q")
	if not ability then return end
	caster:SwapAbilities(self:GetAbilityName(), ability:GetAbilityName(), false, true)
end

function rostik_q_throw:OnProjectileHit_ExtraData(target, location, ExtraData)
	if not target and not location then return end
	local sound_cast = "rostik_q_fly"
	StopSoundOn(sound_cast, self:GetCaster())
	local brew_time = ExtraData.brew_time
	rostik_q_throw.reflected_brew_time = brew_time
	local TRIGGERED = target and target:TriggerSpellAbsorb(self)
	rostik_q_throw.reflected_brew_time = nil
	if TRIGGERED then return end
	local max_brew = self:GetSpecialValueFor("brew_time")
	local min_stun = self:GetSpecialValueFor("min_stun")
	local max_stun = self:GetSpecialValueFor("max_stun")
	local min_damage = self:GetSpecialValueFor("min_damage")
	local max_damage = self:GetSpecialValueFor("max_damage")
	local radius = self:GetSpecialValueFor("midair_explosion_radius")
	local stun = (brew_time / max_brew) * (max_stun - min_stun) + min_stun
	local damage = (brew_time / max_brew) * (max_damage - min_damage) + min_damage
	local damageTable = {
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self,
	}
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),
		location or (target and target:GetOrigin()),
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		0,
		false
	)

	for _, enemy in pairs(enemies) do
		damageTable.victim = enemy
		ApplyDamage(damageTable)
		enemy:AddNewModifier(self:GetCaster(), self, "modifier_generic_stunned_lua", { duration = stun })
	end
	self:PlayEffects(location)
end

function rostik_q_throw:PlayEffects( location )
	local particle_cast = "particles/rostik_q_exp.vpcf"
	local sound_cast = "rostik_q_exp"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, location)
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOnLocationWithCaster( location, sound_cast, self:GetCaster() )
end

modifier_rostik_q = class({})

function modifier_rostik_q:IsHidden()
	return true
end
function modifier_rostik_q:IsDebuff()
	return false
end
function modifier_rostik_q:IsStunDebuff()
	return false
end
function modifier_rostik_q:IsPurgable()
	return false
end

function modifier_rostik_q:OnCreated( kv )
	self.min_stun = self:GetAbility():GetSpecialValueFor( "min_stun" )
	self.max_stun = self:GetAbility():GetSpecialValueFor( "max_stun" )
	self.min_damage = self:GetAbility():GetSpecialValueFor( "min_damage" )
	self.max_damage = self:GetAbility():GetSpecialValueFor( "max_damage" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	if not IsServer() then return end
	self.tick_interval = 0.5
	self.tick = kv.duration
	self.tick_halfway = true
	self:StartIntervalThink( self.tick_interval )
	local sound_cast = "rostik_q_start"
	EmitSoundOn( sound_cast, self:GetParent() )
	local sound_cast_2 = "rostik_q_start_fitil"
	EmitSoundOn( sound_cast_2, self:GetParent() )
end

function modifier_rostik_q:OnRefresh( kv )
end
function modifier_rostik_q:OnRemoved()
end

function modifier_rostik_q:OnDestroy()
	if not IsServer() then return end
	local sound_cast = "rostik_q_start"
	StopSoundOn( sound_cast, self:GetParent() )
	local sound_cast_2 = "rostik_q_start_fitil"
	StopSoundOn( sound_cast_2, self:GetParent() )
end

function modifier_rostik_q:OnIntervalThink()
	self.tick = self.tick - self.tick_interval
	if self.tick>0 then
		self.tick_halfway = not self.tick_halfway
		self:PlayEffects2()
		return
	end
	local damageTable = {
		attacker = self:GetCaster(),
		damage = self.max_damage,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(),
	}
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),
		self:GetParent():GetOrigin(),
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		0,
		false
	)
	for _,enemy in pairs(enemies) do
		damageTable.victim = enemy
		ApplyDamage( damageTable )
		enemy:AddNewModifier(
			self:GetCaster(),
			self:GetAbility(),
			"modifier_generic_stunned_lua",
			{ duration = self.max_stun }
		)
	end
	if not self:GetParent():IsInvulnerable() then
		self.fail_damage = self:GetAbility():GetSpecialValueFor( "fail_damage" )
		damageTable.damage = self.fail_damage * self:GetParent():GetMaxHealth() * 0.01
		damageTable.victim = self:GetParent()
		damageTable.damage_type = DAMAGE_TYPE_PURE
		ApplyDamage( damageTable )
		self:GetParent():AddNewModifier(
			self:GetParent(),
			self:GetAbility(),
			"modifier_generic_stunned_lua",
			{ duration = self.max_stun }
		)
	end
	local ability = self:GetCaster():FindAbilityByName( "rostik_q_throw" )
	self:GetCaster():SwapAbilities(
		self:GetAbility():GetAbilityName(),
		ability:GetAbilityName(),
		true,
		false
	)
	if ability:IsStolen() then
		self:GetCaster():RemoveAbilityByHandle( ability )
	end
	self:PlayEffects1( self:GetParent() )
	self:Destroy()
end

function modifier_rostik_q:PlayEffects1( target )
	local particle_cast = "particles/rostik_q_exp.vpcf"
	local sound_cast = "rostik_q_exp"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( sound_cast, target )
end

function modifier_rostik_q:PlayEffects2()
	local particle_cast = "particles/rostik_q_timer.vpcf"
	local time = math.floor( self.tick )
	local mid = 1
	if self.tick_halfway then mid = 8 end
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( 1, time, mid ) )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( 2, 0, 0 ) )
	if time<1 then
		ParticleManager:SetParticleControl( effect_cast, 2, Vector( 1, 0, 0 ) )
	end
	ParticleManager:ReleaseParticleIndex( effect_cast )
end