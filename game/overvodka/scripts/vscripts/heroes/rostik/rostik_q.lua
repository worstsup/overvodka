LinkLuaModifier( "modifier_rostik_q", "heroes/rostik/rostik_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_rostik_q_swap_state", "heroes/rostik/rostik_q", LUA_MODIFIER_MOTION_NONE)

modifier_rostik_q_swap_state = class({})

function modifier_rostik_q_swap_state:IsHidden() return true end
function modifier_rostik_q_swap_state:IsPurgable() return false end
function modifier_rostik_q_swap_state:RemoveOnDeath() return true end

local function Rostik_EnsureThrow(caster, base)
    if not IsServer() then return nil end
    if not caster or caster:IsNull() then return nil end

    local throw_ab = caster:FindAbilityByName("rostik_q_throw")
    if not throw_ab then
        throw_ab = caster:AddAbility("rostik_q_throw")
        if throw_ab then
            throw_ab:SetStolen(true)
        end
    end
    if not throw_ab or throw_ab:IsNull() then return nil end

    if base and not base:IsNull() then
        throw_ab:SetLevel(base:GetLevel())
    end

    throw_ab:SetHidden(true)
    throw_ab:SetActivated(false)
    return throw_ab
end

local function Rostik_CleanupThrow(caster)
    if not IsServer() then return end
    if not caster or caster:IsNull() then return end

    if not caster:HasModifier("modifier_rostik_q_swap_state") then
        local throw_ab = caster:FindAbilityByName("rostik_q_throw")
        if throw_ab and not throw_ab:IsNull() then
            throw_ab:SetHidden(true)
            throw_ab:SetActivated(false)
            throw_ab.stored_brew_time = nil
            throw_ab.brew_time = nil
        end
        if _G.rostik_q_throw then
            rostik_q_throw.reflected_brew_time = nil
        end
        return
    end

    local base = caster:FindAbilityByName("rostik_q")
    local throw_ab = caster:FindAbilityByName("rostik_q_throw")

    if not base or base:IsNull() then
        if throw_ab and not throw_ab:IsNull() then
            throw_ab:SetHidden(true)
            throw_ab:SetActivated(false)
            throw_ab.stored_brew_time = nil
            throw_ab.brew_time = nil
        end
        if _G.rostik_q_throw then
            rostik_q_throw.reflected_brew_time = nil
        end
        caster:RemoveModifierByName("modifier_rostik_q_swap_state")
        return
    end

    if throw_ab and not throw_ab:IsNull() then
        caster:SwapAbilities(base:GetAbilityName(), throw_ab:GetAbilityName(), true, false)
        throw_ab:SetHidden(true)
        throw_ab:SetActivated(false)
        throw_ab.stored_brew_time = nil
        throw_ab.brew_time = nil
    end

    base:SetHidden(false)
    base:SetActivated(true)

    if _G.rostik_q_throw then
        rostik_q_throw.reflected_brew_time = nil
    end

    caster:RemoveModifierByName("modifier_rostik_q_swap_state")
end

local function Rostik_ExplodeAt(caster, ability, origin, brew_time)
    if not caster or caster:IsNull() then return end
    if not ability or ability:IsNull() then return end
    if not origin then return end

    local max_brew   = ability:GetSpecialValueFor("brew_time")
    local min_stun   = ability:GetSpecialValueFor("min_stun")
    local max_stun   = ability:GetSpecialValueFor("max_stun")
    local min_damage = ability:GetSpecialValueFor("min_damage")
    local max_damage = ability:GetSpecialValueFor("max_damage")

    local radius = ability:GetSpecialValueFor("midair_explosion_radius")
    if radius <= 0 then
        radius = ability:GetSpecialValueFor("radius")
    end
    if radius <= 0 then radius = 300 end

    if max_brew <= 0 then max_brew = 1 end
    brew_time = math.max(0, math.min(brew_time or 0, max_brew))

    local stun = (brew_time / max_brew) * (max_stun - min_stun) + min_stun
    local damage = (brew_time / max_brew) * (max_damage - min_damage) + min_damage

    local particle_cast = "particles/rostik_q_exp.vpcf"
    local sound_cast = "rostik_q_exp"
    local fx = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, origin)
    ParticleManager:ReleaseParticleIndex(fx)
    EmitSoundOnLocationWithCaster(origin, sound_cast, caster)

    local damageTable = {attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability}

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(), origin,
		nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0, 0, false
    )
    for _, enemy in pairs(enemies) do
        if enemy and not enemy:IsNull() then
            damageTable.victim = enemy
            ApplyDamage(damageTable)
            enemy:AddNewModifier(caster, ability, "modifier_generic_stunned_lua", { duration = stun })
        end
    end
end

rostik_q = class({})

function rostik_q:OnOwnerSpawned()
    if not IsServer() then return end
    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    Timers:CreateTimer(0, function()
        if not caster or caster:IsNull() then return end
        Rostik_CleanupThrow(caster)
    end)
end

function rostik_q:OnSpellStart()
    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end
    if caster:HasModifier("modifier_rostik_q") then return end

    local duration = self:GetSpecialValueFor("brew_explosion")
    caster:AddNewModifier(caster, self, "modifier_rostik_q", { duration = duration })

    local base = self
    local throw_ab = Rostik_EnsureThrow(caster, base)
    if not throw_ab then return end

    throw_ab:SetHidden(false)
    throw_ab:SetActivated(true)
    throw_ab:EndCooldown()

    caster:SwapAbilities(base:GetAbilityName(), throw_ab:GetAbilityName(), false, true)
	caster:AddNewModifier(caster, self, "modifier_rostik_q_swap_state", {})

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

function rostik_q_throw:OnOwnerSpawned()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    Timers:CreateTimer(0, function()
        if not caster or caster:IsNull() then return end

        local base = caster:FindAbilityByName("rostik_q")
        if (not caster:HasModifier("modifier_rostik_q")) or (not base or base:IsNull()) then
            self:SetHidden(true)
            self:SetActivated(false)
            self.stored_brew_time = nil
            self.brew_time = nil
        end
    end)
end


function rostik_q_throw:OnSpellStart()
	local caster = self:GetCaster()
	if not caster:HasModifier("modifier_rostik_q") and not rostik_q_throw.reflected_brew_time and not self.stored_brew_time then
		Rostik_CleanupThrow(caster)
		return
	end
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
		info.vVelocity.z = 0
		info.fDistance = (point - caster:GetOrigin()):Length2D()
		info.vSpawnOrigin  = self:GetCaster():GetOrigin()
		info.EffectName = projectile_name_2
		ProjectileManager:CreateLinearProjectile(info)
	end

	local sound_cast = "rostik_q_fly"
	EmitSoundOn(sound_cast, caster)

	local base = caster:FindAbilityByName("rostik_q")
	if base and caster:HasModifier("modifier_rostik_q_swap_state") then
		caster:SwapAbilities(self:GetAbilityName(), base:GetAbilityName(), false, true)
		caster:RemoveModifierByName("modifier_rostik_q_swap_state")
	end
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
		if enemy and not enemy:IsNull() then
			enemy:AddNewModifier(self:GetCaster(), self, "modifier_generic_stunned_lua", { duration = stun })
		end
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

function modifier_rostik_q:IsHidden() return true end
function modifier_rostik_q:IsDebuff() return false end
function modifier_rostik_q:IsStunDebuff() return false end
function modifier_rostik_q:IsPurgable() return false end
function modifier_rostik_q:RemoveOnDeath() return true end

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

function modifier_rostik_q:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_rostik_q:OnDeath(params)
    if not IsServer() then return end
    if not params or params.unit ~= self:GetParent() then return end
    if self._cleaned then return end
    self._cleaned = true

    local caster = self:GetCaster()
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not caster or caster:IsNull() then return end
    if not ability or ability:IsNull() then
        Rostik_CleanupThrow(caster)
        return
    end

    local max_brew = ability:GetSpecialValueFor("brew_time")
    if max_brew <= 0 then max_brew = 1 end
    local brew_time = math.min(GameRules:GetGameTime() - self:GetCreationTime(), max_brew)

    Rostik_ExplodeAt(caster, ability, parent:GetAbsOrigin(), brew_time)
    Rostik_CleanupThrow(caster)
end

function modifier_rostik_q:OnDestroy()
    if not IsServer() then return end

    StopSoundOn("rostik_q_start", self:GetParent())
    StopSoundOn("rostik_q_start_fitil", self:GetParent())

    if not self._cleaned then
        self._cleaned = true
        Rostik_CleanupThrow(self:GetCaster())
    end
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
		self:GetParent():GetOrigin(), nil,
		self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0, 0, false
	)
	for _,enemy in pairs(enemies) do
		damageTable.victim = enemy
		ApplyDamage( damageTable )
		if enemy and not enemy:IsNull() then
			enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_generic_stunned_lua", { duration = self.max_stun })
		end
	end
	if not self:GetParent():IsInvulnerable() then
		self.fail_damage = self:GetAbility():GetSpecialValueFor( "fail_damage" )
		damageTable.damage = self.fail_damage * self:GetParent():GetMaxHealth() * 0.01
		damageTable.victim = self:GetParent()
		damageTable.damage_type = DAMAGE_TYPE_PURE
		damageTable.damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS
		ApplyDamage( damageTable )
		if self:GetParent() and not self:GetParent():IsNull() then
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_generic_stunned_lua", { duration = self.max_stun })
		end
	end
	Rostik_CleanupThrow(self:GetCaster())

	self:PlayEffects1(self:GetParent())
	self._cleaned = true
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