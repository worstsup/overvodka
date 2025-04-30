cheater_granades = class({})
LinkLuaModifier( "modifier_cheater_granades", "heroes/cheater/modifier_cheater_granades", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_cheater_slow", "heroes/cheater/modifier_cheater_slow", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_cheater_smoke", "heroes/cheater/modifier_cheater_smoke", LUA_MODIFIER_MOTION_NONE )

function cheater_granades:OnAbilityUpgrade( hAbility )
	if not IsServer() then return end
	self.BaseClass.OnAbilityUpgrade( self, hAbility )
	self:EnableAbilityChargesOnTalentUpgrade( hAbility, "special_bonus_unique_cheater_8" )
end

function cheater_granades:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end
Chance = 0

function cheater_granades:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local vector = point-caster:GetOrigin()
	local projectile_name = ""
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
	local projectile_distance = vector:Length2D()
	local projectile_direction = vector
	projectile_direction.z = 0
	projectile_direction = projectile_direction:Normalized()
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_NONE,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = 0,
	    fEndRadius = 0,
		vVelocity = projectile_direction * projectile_speed,
	}
	ProjectileManager:CreateLinearProjectile(info)
	if Chance == 0 then
		self:PlayEffects( point )
	elseif Chance == 1 then
		self:PlayEffects2( point )
	elseif Chance == 2 then
		self:PlayEffects4( point )
	end
end

function cheater_granades:OnProjectileHit( target, location )
	if Chance == 0 then
		local duration = self:GetSpecialValueFor( "duration" )
		CreateModifierThinker(
			self:GetCaster(),
			self,
			"modifier_cheater_granades",
			{ duration = duration },
			location,
			self:GetCaster():GetTeamNumber(),
			false
		)
		Chance = 1
	elseif Chance == 1 then
		local slow_duration = self:GetSpecialValueFor( "slow_dur" )
		local damage = self:GetSpecialValueFor( "damage_exp" )
		local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
			location,
			nil,
			self:GetSpecialValueFor( "radius" ),
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false)
		for _,unit in pairs(targets) do
			local dmg_far = damage + self:GetSpecialValueFor( "damage_exp_percent_far" ) * unit:GetHealth() * 0.01
			ApplyDamage({victim = unit, attacker = self:GetCaster(), damage = dmg_far, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
			unit:AddNewModifier(
				self:GetCaster(),
				self,
				"modifier_cheater_slow",
				{ duration = slow_duration }
			)
		end
		local targets1 = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
			location,
			nil,
			250,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false)
		for _,unit in pairs(targets1) do
			local dmg_mid = self:GetSpecialValueFor( "damage_exp_percent_mid" ) * unit:GetHealth() * 0.01
			ApplyDamage({victim = unit, attacker = self:GetCaster(), damage = dmg_mid, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
		end
		local targets2 = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
			location,
			nil,
			100,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false)
		for _,unit in pairs(targets2) do
			local dmg_close = self:GetSpecialValueFor( "damage_exp_percent_close" ) * unit:GetHealth() * 0.01
			ApplyDamage({victim = unit, attacker = self:GetCaster(), damage = dmg_close, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
		end
		 EmitSoundOnLocationWithCaster(location, "grenade_explosion", self:GetCaster())
		 self:PlayEffects3( location )
		 Chance = 2
	elseif Chance == 2 then
		local duration = self:GetSpecialValueFor( "duration" )
		CreateModifierThinker(
			self:GetCaster(),
			self,
			"modifier_cheater_smoke",
			{ duration = duration },
			location,
			self:GetCaster():GetTeamNumber(),
			false
		)
		Chance = 0
	end

end

function cheater_granades:PlayEffects( point )
	local particle_cast = "particles/viper_immortal_ti8_nethertoxin_proj_new.vpcf"
	local sound_cast = "molotov_throw"
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( projectile_speed, 0, 0 ) )
	ParticleManager:SetParticleControl( effect_cast, 5, point )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( sound_cast, self:GetCaster() )
end

function cheater_granades:PlayEffects2( point )
	local particle_cast = "particles/grenade_proj.vpcf"
	local sound_cast = "grenade_throw"
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( projectile_speed, 0, 0 ) )
	ParticleManager:SetParticleControl( effect_cast, 5, point )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( sound_cast, self:GetCaster() )
end
function cheater_granades:PlayEffects3( point )
    local particle_cast = "particles/grenade_explosion.vpcf"
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:ReleaseParticleIndex( effect_cast )
    ParticleManager:ReleaseParticleIndex(effect_cast)
end

function cheater_granades:PlayEffects4( point )
	local particle_cast = "particles/smoke_proj.vpcf"
	local sound_cast = "smoke_throw"
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( projectile_speed, 0, 0 ) )
	ParticleManager:SetParticleControl( effect_cast, 5, point )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( sound_cast, self:GetCaster() )
end