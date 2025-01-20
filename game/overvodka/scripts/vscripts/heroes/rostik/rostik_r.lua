rostik_r = class({})
LinkLuaModifier( "modifier_rostik_r", "heroes/rostik/rostik_r", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_rostik_r_slow", "heroes/rostik/rostik_r", LUA_MODIFIER_MOTION_HORIZONTAL )

function rostik_r:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local direction = point - caster:GetOrigin()
	direction.z = 0
	direction = direction:Normalized()
	self.direction = direction
	self.hit_targets = {}
	self.modifier = caster:AddNewModifier(
		caster,
		self,
		"modifier_rostik_r",
		{
			x = direction.x,
			y = direction.y,
		}
	)
	local sound_cast = "rostik_r"
	EmitSoundOn(sound_cast, caster)
end

function rostik_r:OnProjectileHitHandle(target, location, iHandle)
	if not IsServer() then return end
	if not target then return end

	if self.hit_targets[target:entindex()] then
		return false
	end

	local rock_speed = self:GetSpecialValueFor("rock_speed")
	local rock_distance = self:GetSpecialValueFor("rock_distance")
	local damage = self:GetSpecialValueFor("damage")
	local slow_duration = self:GetSpecialValueFor("slow_duration")
	local filter = UnitFilter(
		target,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		self:GetCaster():GetTeamNumber()
	)
	if filter ~= UF_SUCCESS then
		return false
	end

	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self, 
	}
	ApplyDamage(damageTable)
	self.hit_targets[target:entindex()] = true

	if target:IsHero() then
		if self.modifier and (not self.modifier:IsNull()) then
			self.modifier:End(self:GetCaster():GetOrigin())
			self.modifier = nil
			self:GetCaster():SetOrigin(target:GetOrigin() + self.direction * 80)
			FindClearSpaceForUnit(self:GetCaster(), target:GetOrigin() + self.direction * 80, false)
			target:AddNewModifier(
				self:GetCaster(),
				self,
				"modifier_rostik_r_slow",
				{ duration = slow_duration }
			)
			return true
		end
	end

	return false
end

modifier_rostik_r_slow = class({})

function modifier_rostik_r_slow:IsHidden()
	return false
end
function modifier_rostik_r_slow:IsDebuff()
	return true
end
function modifier_rostik_r_slow:IsStunDebuff()
	return false
end
function modifier_rostik_r_slow:IsPurgable()
	return true
end

function modifier_rostik_r_slow:OnCreated( kv )
	self.slow = self:GetAbility():GetSpecialValueFor( "move_slow" )
end

function modifier_rostik_r_slow:OnRefresh( kv )
	self.slow = self:GetAbility():GetSpecialValueFor( "move_slow" )
end

function modifier_rostik_r_slow:OnDestroy( kv )
end

function modifier_rostik_r_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end
function modifier_rostik_r_slow:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow
end

modifier_rostik_r = class({})

function modifier_rostik_r:IsHidden()
	return false
end
function modifier_rostik_r:IsDebuff()
	return false
end
function modifier_rostik_r:IsPurgable()
	return false
end

function modifier_rostik_r:OnCreated( kv )
	self.delay = self:GetAbility():GetSpecialValueFor( "delay" )
	self.speed = self:GetAbility():GetSpecialValueFor( "speed" )
	self.distance = self:GetAbility():GetSpecialValueFor( "distance" )
	if IsServer() then
		self.direction = Vector( kv.x, kv.y, 0 )
		self.origin = self:GetParent():GetOrigin()
		self:StartIntervalThink( self.delay )
		self:PlayEffects()
	end
end

function modifier_rostik_r:OnRefresh( kv )	
end

function modifier_rostik_r:OnDestroy( kv )
	if IsServer() then
		self:GetParent():InterruptMotionControllers( true )
	end
end

function modifier_rostik_r:OnRemoved( kv )
	if IsServer() then
		if self.pre_collide then
			ParticleManager:SetParticleControl( self.effect_cast, 3, self.pre_collide )
		else
			ParticleManager:SetParticleControl( self.effect_cast, 3, self:GetParent():GetOrigin() )
		end
		local sound_loop = "Hero_EarthSpirit.RollingBoulder.Loop"
		StopSoundOn( sound_loop, self:GetParent() )
		local sound_end = "Hero_EarthSpirit.RollingBoulder.Destroy"
		EmitSoundOn( sound_end, self:GetParent() )
	end
end

function modifier_rostik_r:CheckState()
	local state = {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}
	return state
end
function modifier_rostik_r:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION ,
	}
	return funcs
end
function modifier_rostik_r:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_6
end
function modifier_rostik_r:OnIntervalThink()
	if self:ApplyHorizontalMotionController() == false then
		self:Destroy()
		return
	end
	local info = {
		Source = self:GetCaster(),
		Ability = self:GetAbility(),
		vSpawnOrigin = self:GetParent():GetAbsOrigin(),
		
	    bDeleteOnHit = true,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
	    iUnitTargetType = DOTA_UNIT_TARGET_ALL,
	    
	    EffectName = "",
	    fDistance = self.distance,
	    fStartRadius = 150,
	    fEndRadius =150,
		vVelocity = self.direction * self.speed,
	
		bHasFrontalCone = false,
		bReplaceExisting = false,
	}
	ProjectileManager:CreateLinearProjectile(info)
end

function modifier_rostik_r:UpdateHorizontalMotion( me, dt )
	local pos = self:GetParent():GetOrigin()
	if (pos-self.origin):Length2D()>=self.distance then
		self:Destroy()
		return
	end
	local target = pos + self.direction * (self.speed*dt)
	self:GetParent():SetOrigin( target )
end

function modifier_rostik_r:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

function modifier_rostik_r:End( vector )
	self.pre_collide = vector
	self:Destroy()
end

function modifier_rostik_r:PlayEffects()
	local particle_cast = "particles/rostik_r.vpcf"
	local sound_loop = "Hero_EarthSpirit.RollingBoulder.Loop"
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	self:AddParticle(
		self.effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
	EmitSoundOn( sound_loop, self:GetParent() )
end
