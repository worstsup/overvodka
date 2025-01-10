vihor_q = class({})
LinkLuaModifier("modifier_vihor_q_slow", "heroes/vihor/vihor_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_vihor_q_fly", "heroes/vihor/vihor_q", LUA_MODIFIER_MOTION_NONE )

function vihor_q:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_clinkz/clinkz_tar_bomb_projectile.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_clinkz/clinkz_tar_bomb_debuff.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_clinkz/clinkz_tar_bomb_thinker.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/batrider/batrider_ti8_immortal_mount/batrider_ti8_immortal_firefly_mount_trail.vpcf", context)
    PrecacheResource("soundfile", "soundevents/vihor_q.vsndevts", context )
end
function vihor_q:OnSpellStart()
	self.range = self:GetSpecialValueFor("range")
	self.radius = self:GetSpecialValueFor("radius")
	self.damage = self:GetSpecialValueFor("damage")
	self.enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self.range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
	self.k = 0
	local target = self:GetCaster()
	for _, enemy in pairs(self.enemies) do
		if self.k > 0 then break end
		target = enemy
		self.k = self.k + 1
	end
	local projectile_speed = self:GetSpecialValueFor("blast_speed")
	local projectile_name = "particles/units/heroes/hero_clinkz/clinkz_tar_bomb_projectile.vpcf"
	local info = {
		EffectName = projectile_name,
		Ability = self,
		iMoveSpeed = projectile_speed,
		Source = self:GetCaster(),
		Target = target,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}
	ProjectileManager:CreateTrackingProjectile( info )
	self.targets = self:GetSpecialValueFor("targets")
	if self.targets == 2 then
		self.second = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self.range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		self.t = 0
		local target_2 = self:GetCaster()
		for _, enemy in pairs(self.second) do
			if self.t > 0 then break end
			if enemy ~= target then
				target = enemy
				self.t = self.t + 1
			end
		end
		local info_2 = {
			EffectName = projectile_name,
			Ability = self,
			iMoveSpeed = projectile_speed,
			Source = self:GetCaster(),
			Target = target,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
		}
		ProjectileManager:CreateTrackingProjectile( info_2 )
	end

	self.duration = self:GetSpecialValueFor( "duration" )
	self.duration_fly = self:GetSpecialValueFor( "duration_fly" )
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_vihor_q_fly", { duration = self.duration_fly })
	self:PlayEffects1()
end
function vihor_q:OnProjectileHit( hTarget, vLocation )
	local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), vLocation, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(targets) do
		enemy:AddNewModifier( self:GetCaster(), self, "modifier_vihor_q_slow", { duration = self.duration } )
		ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
	end
	self:PlayEffects2( hTarget )
	return true
end

function vihor_q:PlayEffects1()
	local sound_cast = "vihor_q"
	EmitSoundOn( sound_cast, self:GetCaster() )
end
function vihor_q:PlayEffects2( target )
	local particle_radius = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_tar_bomb_thinker.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_radius, 0, target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_radius)
end

modifier_vihor_q_slow = class({})
function modifier_vihor_q_slow:IsDebuff()
	return true
end
function modifier_vihor_q_slow:OnCreated( kv )
	self.dot_slow = self:GetAbility():GetSpecialValueFor( "blast_slow" )
end
function modifier_vihor_q_slow:OnRefresh( kv )
	self.dot_slow = self:GetAbility():GetSpecialValueFor( "blast_slow" )
end

function modifier_vihor_q_slow:OnDestroy()
end
function modifier_vihor_q_slow:DeclareFunctions()	
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end
function modifier_vihor_q_slow:GetModifierMoveSpeedBonus_Percentage( params )
	return self.dot_slow
end
function modifier_vihor_q_slow:GetEffectName()
	return "particles/units/heroes/hero_clinkz/clinkz_tar_bomb_debuff.vpcf"
end
function modifier_vihor_q_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

modifier_vihor_q_fly = class({})
function modifier_vihor_q_fly:OnCreated( kv )
	self.bonus_speed = self:GetAbility():GetSpecialValueFor("bonus_speed")
	self:GetParent():StartGesture(ACT_DOTA_FLEE)
end
function modifier_vihor_q_fly:OnRefresh( kv )
end

function modifier_vihor_q_fly:OnDestroy()
	self:GetParent():RemoveGesture(ACT_DOTA_FLEE)
	self:GetParent():StartGesture(ACT_DOTA_ECHO_SLAM)
end
function modifier_vihor_q_fly:CheckState()
	local state = {
		[MODIFIER_STATE_FLYING] = true,
		[MODIFIER_STATE_FORCED_FLYING_VISION] = true,
	}
	return state
end

function modifier_vihor_q_fly:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end

function modifier_vihor_q_fly:GetModifierMoveSpeedBonus_Percentage( params )
    return self.bonus_speed
end
function modifier_vihor_q_fly:GetEffectName()
	return "particles/econ/items/batrider/batrider_ti8_immortal_mount/batrider_ti8_immortal_firefly_mount_trail.vpcf"
end
function modifier_vihor_q_fly:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end