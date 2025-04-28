rostik_r = class({})
LinkLuaModifier( "modifier_rostik_r", "heroes/rostik/rostik_r", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_rostik_r_slow", "heroes/rostik/rostik_r", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_rostik_r_thinker", "heroes/rostik/rostik_r", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rostik_r_fire", "heroes/rostik/rostik_r", LUA_MODIFIER_MOTION_NONE )

function rostik_r:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local direction = point - caster:GetOrigin() +Vector(3,3,0)
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
	self.facet = self:GetAbility():GetSpecialValueFor( "hasfacet" )
	if self.facet == 1 then
		self.hasfacet = true
	else
		self.hasfacet = false
	end
	if IsServer() then
		self.direction = Vector( kv.x, kv.y, 0 )
		self.start_point = self:GetParent():GetOrigin()
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
	if self:GetParent():HasModifier("modifier_item_aghanims_shard") then
		local dir = self.start_point - self:GetParent():GetOrigin()
		dir.z = 0
		dir = dir:Normalized()
		local duration = self:GetAbility():GetSpecialValueFor( "fire_duration" )
		CreateModifierThinker(
			self:GetParent(),
			self:GetAbility(),
			"modifier_rostik_r_thinker",
			{
				duration = duration,
				x = dir.x,
				y = dir.y,
				range = (self.start_point - self:GetParent():GetOrigin()):Length2D(),
			},
			self:GetParent():GetOrigin(),
			self:GetParent():GetTeamNumber(),
			false
		)
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
		[MODIFIER_STATE_DEBUFF_IMMUNE] = self.hasfacet,
		[MODIFIER_STATE_UNSELECTABLE] = self.hasfacet,
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
	    fEndRadius = 150,
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

modifier_rostik_r_thinker = class({})

function modifier_rostik_r_thinker:IsHidden()
	return false
end
function modifier_rostik_r_thinker:IsDebuff()
	return false
end
function modifier_rostik_r_thinker:IsStunDebuff()
	return false
end
function modifier_rostik_r_thinker:IsPurgable()
	return false
end

function modifier_rostik_r_thinker:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" ) + 30
	self.duration = self:GetAbility():GetSpecialValueFor( "fire_effect_duration" )
	self.interval = 0.4
	self.range = kv.range
	self.damage = self:GetAbility():GetSpecialValueFor( "fire_damage" )

	if not IsServer() then return end
	self.abilityDamageType = self:GetAbility():GetAbilityDamageType()
	self.abilityTargetTeam = self:GetAbility():GetAbilityTargetTeam()
	self.abilityTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	self.abilityTargetFlags = self:GetAbility():GetAbilityTargetFlags()
	local start_range = -50
	self.direction = Vector( kv.x, kv.y, 0 )
	self.startpoint = self.parent:GetOrigin() + self.direction * start_range
	self.endpoint = self.startpoint + self.direction * self.range
	local step = 0
	while step < self.range do
		local loc = self.startpoint + self.direction * step
		GridNav:DestroyTreesAroundPoint( loc, self.radius, true )

		step = step + self.radius
	end
	self:StartIntervalThink( self.interval )
	self:PlayEffects()
end

function modifier_rostik_r_thinker:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_rostik_r_thinker:OnRemoved()
end

function modifier_rostik_r_thinker:OnDestroy()
	if not IsServer() then return end
	UTIL_Remove( self:GetParent() )
end

function modifier_rostik_r_thinker:OnIntervalThink()
	local enemies = FindUnitsInLine(
		self.caster:GetTeamNumber(),
		self.startpoint,
		self.endpoint,
		nil,
		self.radius,
		self.abilityTargetTeam,
		self.abilityTargetType,
		self.abilityTargetFlags
	)

	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(
			self.caster,
			self:GetAbility(),
			"modifier_rostik_r_fire",
			{
				duration = self.duration,
				interval = self.interval,
				damage = self.damage * self.interval,
				damage_type = self.abilityDamageType,
			}
		)
	end

end

function modifier_rostik_r_thinker:PlayEffects()
	local particle_cast = "particles/rostik_r_fire.vpcf"
	local duration = self:GetAbility():GetSpecialValueFor( "fire_duration" )

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self.parent )
	ParticleManager:SetParticleControl( effect_cast, 0, self.startpoint )
	ParticleManager:SetParticleControl( effect_cast, 1, self.endpoint )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( duration, 0, 0 ) )
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
end

modifier_rostik_r_fire = class({})

function modifier_rostik_r_fire:IsHidden()
	return false
end

function modifier_rostik_r_fire:IsDebuff()
	return true
end

function modifier_rostik_r_fire:IsStunDebuff()
	return false
end

function modifier_rostik_r_fire:IsPurgable()
	return false
end

function modifier_rostik_r_fire:OnCreated( kv )
	if not IsServer() then return end
	local interval = kv.interval
	local damage = kv.damage
	local damage_type = kv.damage_type

	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = damage_type,
		ability = self:GetAbility(),
	}

	self:StartIntervalThink( interval )
end

function modifier_rostik_r_fire:OnRefresh( kv )
	if not IsServer() then return end
	local damage = kv.damage
	local damage_type = kv.damage_type

	self.damageTable.damage = damage
	self.damageTable.damage_type = damage_type
end

function modifier_rostik_r_fire:OnRemoved()
end

function modifier_rostik_r_fire:OnDestroy()
end


function modifier_rostik_r_fire:OnIntervalThink()
	ApplyDamage( self.damageTable )
end


function modifier_rostik_r_fire:GetEffectName()
	return "particles/rostik_r_fire_debuff.vpcf"
end

function modifier_rostik_r_fire:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end