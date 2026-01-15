LinkLuaModifier("modifier_azazin_q_pull", "heroes/azazin/azazin_q", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_azazin_q_tree_walk_aura", "heroes/azazin/azazin_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_azazin_q_tree_walk", "heroes/azazin/azazin_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_azazin_tether_aura", "heroes/azazin/azazin_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_azazin_tether", "heroes/azazin/azazin_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_azazin_q_hook", "heroes/azazin/azazin_q", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_azazin_q_hook_self", "heroes/azazin/azazin_q", LUA_MODIFIER_MOTION_NONE)

azazin_q = class({})
k = 0
function azazin_q:Precache(context)
    PrecacheResource("particle", "particles/azazin_q.vpcf", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_hero_pudge.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/azazin_q_1.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/azazin_q_2.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/azazin_q_3.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/azazin_q.vsndevts", context)
    PrecacheResource("particle", "particles/units/heroes/hero_pudge/pudge_meathook.vpcf", context)
	PrecacheResource("model", "models/props_tree/ti7/ggbranch.vmdl", context)
end

function azazin_q:GetBehavior()
    if self:GetSpecialValueFor("hook") == 1 then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function azazin_q:GetCastRange(location, target)
    if self:GetSpecialValueFor("hook") == 1 then
        if IsClient() then
            return self:GetSpecialValueFor("cast_range")
        end
    else
        return self:GetSpecialValueFor("cast_range")
    end
end

function azazin_q:GetCastPoint()
	return self:GetSpecialValueFor("cast_point")
end

function azazin_q:OnSpellStart()
    local caster = self:GetCaster()
    self.is_hook = self:GetSpecialValueFor("hook") == 1
    if not IsServer() then return end
    if self.is_hook then
        local point = self:GetCursorPosition()
        local projectile_name = ""
        local projectile_distance = self:GetSpecialValueFor( "hook_distance" )
        if caster:HasTalent("special_bonus_unique_azazin_3") then
            projectile_distance = projectile_distance + 150
        end
        local projectile_speed = self:GetSpecialValueFor( "hook_speed" )
        local projectile_radius = self:GetSpecialValueFor( "hook_width" )
        local origin = caster:GetAbsOrigin()
        local dir = point - origin
        dir.z = 0
        local projectile_direction = dir:Normalized()

        local target = origin + projectile_direction * projectile_distance

        local info = {
            Source = caster,
            Ability = self,
            vSpawnOrigin = caster:GetAbsOrigin(),
        
            bDeleteOnHit = true,
        
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        
            EffectName = projectile_name,
            fDistance = projectile_distance,
            fStartRadius = projectile_radius,
            fEndRadius = projectile_radius,
            vVelocity = projectile_direction * projectile_speed,
        }
        local id = ProjectileManager:CreateLinearProjectile(info)

        local data = {}
        data.cast_location = origin
        self.projectiles[id] = data

        local duration = projectile_distance / projectile_speed
        caster:AddNewModifier(caster, self, "modifier_azazin_q_hook_self", { duration = duration })

        self:PlayEffects( target, data )
    else
        local target = self:GetCursorTarget()
        if target:TriggerSpellAbsorb(self) then return end
        if not target or target:IsInvulnerable() then
            return
        end

        local projectile_speed = 1600

        local info = {
            Target = target,
            Source = caster,
            Ability = self,
            EffectName = "particles/azazin_q.vpcf",
            iMoveSpeed = projectile_speed,
            bDodgeable = true,
            bProvidesVision = false,
        }
        ProjectileManager:CreateTrackingProjectile(info)
    end
    EmitSoundOn("azazin_q", caster)
    if k == 0 then
        EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(),"azazin_q_1", caster)
        k = 1
    elseif k == 1 then
        EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(),"azazin_q_2", caster)
        k = 2
    elseif k == 2 then
        EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(),"azazin_q_3", caster)
        k = 0
    end
end

function azazin_q:PlayEffects( point, data )

	local speed = self:GetSpecialValueFor( "hook_speed" )
	local distance = self:GetSpecialValueFor( "hook_distance" )
    if self:GetCaster():HasTalent("special_bonus_unique_azazin_3") then
        distance = distance + 150
    end
	local radius = self:GetSpecialValueFor( "hook_width" )
	local duration = distance/speed * 2

	local effect_cast = ParticleManager:CreateParticle( "particles/azazin_q_hook.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( effect_cast, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", Vector(0,0,0), true )
	ParticleManager:SetParticleControl( effect_cast, 1, point )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( speed, distance, radius ) )
	ParticleManager:SetParticleControl( effect_cast, 3, Vector( duration, 0, 0 ) )
	ParticleManager:SetParticleControl( effect_cast, 4, Vector( 1, 0, 0 ) )
	ParticleManager:SetParticleControl( effect_cast, 5, Vector( 0, 0, 0 ) )
	ParticleManager:SetParticleControlEnt( effect_cast, 7, self:GetCaster(), PATTACH_CUSTOMORIGIN, "attach_hitloc", Vector(0,0,0), true )
	ParticleManager:SetParticleAlwaysSimulate( effect_cast )
	ParticleManager:SetParticleShouldCheckFoW( effect_cast, false )

	data.effect_cast = effect_cast
end

function azazin_q:SetEffects1( data )
	ParticleManager:SetParticleControlEnt( data.effect_cast, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
	ParticleManager:ReleaseParticleIndex( data.effect_cast )
end

function azazin_q:SetEffects2( data, target )
	ParticleManager:SetParticleControlEnt( data.effect_cast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	ParticleManager:SetParticleControl( data.effect_cast, 4, Vector( 0, 0, 0 ) )
	ParticleManager:SetParticleControl( data.effect_cast, 5, Vector( 1, 0, 0 ) )

	EmitSoundOn( "Hero_Pudge.AttackHookImpact", target )
	EmitSoundOn( "Hero_Pudge.AttackHookRetract", self:GetCaster() )
end

function azazin_q:OnProjectileHitHandle( target, location, handle )
    if self.is_hook then
        self:HookHit( target, location, handle )
    else
        self:BaseHit( target, location )
    end
end

function azazin_q:BaseHit( target, location )
    if not IsServer() then return end
    if not target then return end

    local caster = self:GetCaster()
    local min_pull = self:GetSpecialValueFor("min_pull")
    local max_pull = self:GetSpecialValueFor("max_pull")
    local pull_duration = 0.25
    local current_distance = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
    local effective_distance = math.min(current_distance, max_pull)
    local pull_distance = effective_distance - min_pull
    if pull_distance <= 0 then 
        pull_distance = -pull_distance
    end
    if target:IsMagicImmune() or target:IsDebuffImmune() then
        local direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
        caster:AddNewModifier(caster, self, "modifier_azazin_q_pull", {
            duration = pull_duration,
            distance = pull_distance,
            dir_x = direction.x,
            dir_y = direction.y,
            other_ent = target:entindex()
        })
        caster:EmitSound("Hero_Pudge.AttackHookImpact")
        return
    end

    if target:IsInvulnerable() then return end
    local directionCaster = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
    local directionTarget = -directionCaster

    caster:AddNewModifier(caster, self, "modifier_azazin_q_pull", {
        duration = pull_duration,
        distance = pull_distance,
        dir_x = directionCaster.x,
        dir_y = directionCaster.y,
        other_ent = target:entindex()
    })
    target:AddNewModifier(caster, self, "modifier_azazin_q_pull", {
        duration = pull_duration,
        distance = pull_distance,
        dir_x = directionTarget.x,
        dir_y = directionTarget.y,
        other_ent = caster:entindex()
    })

    caster:EmitSound("Hero_Pudge.AttackHookImpact")
    target:EmitSound("Hero_Pudge.AttackHookImpact")
end

azazin_q.projectiles = {}
function azazin_q:HookHit( target, location, handle )
	local data = self.projectiles[handle]
	if not data then return true end

	if not target then
		self.projectiles[handle] = nil
		self:SetEffects1( data )
		return true
	end

	if target==self:GetCaster() then
		return false
	end

	target:AddNewModifier( self:GetCaster(), self, "modifier_azazin_q_hook", { handle = handle } )

	if target:GetTeamNumber()~=self:GetCaster():GetTeamNumber() then
		ApplyDamage( { victim = target, attacker = self:GetCaster(), damage = self:GetSpecialValueFor( "damage" ), damage_type = DAMAGE_TYPE_PURE, ability = self } )
		if target:IsCreep() and not target:IsCreepHero() and not target:IsAncient() then
			target:Kill( self, self:GetCaster() )
		end
	end

	local radius = self:GetSpecialValueFor( "vision_radius" )
	local duration = self:GetSpecialValueFor( "vision_duration" )
	AddFOWViewer( self:GetCaster():GetTeamNumber(), target:GetAbsOrigin(), radius, duration, false )
	self:SetEffects2( data, target )

	return true
end


modifier_azazin_q_pull = class({})

function modifier_azazin_q_pull:IsHidden() return true end
function modifier_azazin_q_pull:IsPurgable() return false end
function modifier_azazin_q_pull:RemoveOnDeath() return true end
function modifier_azazin_q_pull:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_azazin_q_pull:OnCreated(kv)
    if not IsServer() then return end
    self.distance = kv.distance or 0
    self.duration = kv.duration or 0.3
    self.dir = Vector(kv.dir_x or 0, kv.dir_y or 0, 0):Normalized()
    self.speed = self.distance / self.duration
    self.elapsed = 0
    self.origin = self:GetParent():GetAbsOrigin()
    if kv.other_ent then
        self.other_ent = EntIndexToHScript(tonumber(kv.other_ent))
    end
    if not self:ApplyHorizontalMotionController() then
        self:Destroy()
    end
end

function modifier_azazin_q_pull:UpdateHorizontalMotion(unit, dt)
    if not IsServer() then return end
    self.elapsed = self.elapsed + dt
    if self.elapsed >= self.duration then
        dt = self.duration - (self.elapsed - dt)
        local newPos = unit:GetAbsOrigin() + self.dir * self.speed * dt
        unit:SetAbsOrigin(newPos)
        self:OnHorizontalMotionInterrupted(unit)
        return
    end
    local newPos = unit:GetAbsOrigin() + self.dir * self.speed * dt
    unit:SetAbsOrigin(newPos)
end

function modifier_azazin_q_pull:OnHorizontalMotionInterrupted(unit)
    if not IsServer() then return end
    self:Destroy()
end

function modifier_azazin_q_pull:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveHorizontalMotionController(self)
	self:GetCaster():StopSound("azazin_q")
    local parent = self:GetParent()
    if self.other_ent and not self.other_ent:IsNull() then
        local diff = self.other_ent:GetAbsOrigin() - parent:GetAbsOrigin()
        diff.z = 0
        local new_forward = diff:Normalized()
        if parent:IsRealHero() then
            parent:SetForwardVector(new_forward)
		    parent:MoveToTargetToAttack(self.other_ent)
        end
        local midpoint = (parent:GetAbsOrigin() + self.other_ent:GetAbsOrigin()) * 0.5
        self:GetAbility():SpawnTreeRing(midpoint)
        if self:GetCaster():HasShard() then
            CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_azazin_q_tree_walk_aura", {duration = self:GetAbility():GetSpecialValueFor("ring_duration")}, midpoint, self:GetCaster():GetTeamNumber(), false)
        end
        if self:GetAbility():GetSpecialValueFor("tether") == 1 then
            CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_azazin_tether_aura", {duration = self:GetAbility():GetSpecialValueFor("ring_duration")}, midpoint, self:GetCaster():GetTeamNumber(), false)
        end
    end
end

function azazin_q:SpawnTreeRing(point)
    if not IsServer() then return end
    local ring_radius = self:GetSpecialValueFor("radius")
    local ring_duration = self:GetSpecialValueFor("ring_duration")
    local num_trees = 24
    for i = 1, num_trees do
        local angle = math.rad((360 / num_trees) * i)
        local treePos = point + Vector(math.cos(angle), math.sin(angle), 0) * ring_radius
        CreateTempTreeWithModel(treePos, ring_duration, "models/props_tree/ti7/ggbranch.vmdl")
    end
	GridNav:DestroyTreesAroundPoint( point, ring_radius - 50, false )
    AddFOWViewer(self:GetCaster():GetTeamNumber(), point, ring_radius, ring_duration, false)
end

function modifier_azazin_q_pull:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

modifier_azazin_q_tree_walk_aura = class({})
function modifier_azazin_q_tree_walk_aura:IsHidden() return true end
function modifier_azazin_q_tree_walk_aura:IsPurgable() return false end
function modifier_azazin_q_tree_walk_aura:IsAura() return true end
function modifier_azazin_q_tree_walk_aura:GetModifierAura() return "modifier_azazin_q_tree_walk" end
function modifier_azazin_q_tree_walk_aura:GetAuraDuration() return 0.1 end
function modifier_azazin_q_tree_walk_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") + 100 end
function modifier_azazin_q_tree_walk_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_azazin_q_tree_walk_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_azazin_q_tree_walk_aura:GetAuraSearchFlags() return 0 end

modifier_azazin_q_tree_walk = class({})
function modifier_azazin_q_tree_walk:IsHidden() return true end
function modifier_azazin_q_tree_walk:IsPurgable() return false end
function modifier_azazin_q_tree_walk:CheckState()
    return {
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = self:GetCaster() == self:GetParent(),
    }
end

modifier_azazin_tether_aura = class({})
function modifier_azazin_tether_aura:IsHidden() return true end
function modifier_azazin_tether_aura:IsPurgable() return false end
function modifier_azazin_tether_aura:IsAura() return true end
function modifier_azazin_tether_aura:GetModifierAura() return "modifier_azazin_tether" end
function modifier_azazin_tether_aura:GetAuraDuration() return 0.1 end
function modifier_azazin_tether_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") + 25 end
function modifier_azazin_tether_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_azazin_tether_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_azazin_tether_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end

modifier_azazin_tether = class({})
function modifier_azazin_tether:IsHidden() return false end
function modifier_azazin_tether:IsPurgable() return false end
function modifier_azazin_tether:CheckState()
    return {
        [MODIFIER_STATE_TETHERED] = true,
    }
end


modifier_azazin_q_hook = class({})

function modifier_azazin_q_hook:IsHidden() return false end
function modifier_azazin_q_hook:IsDebuff() return self.enemy end
function modifier_azazin_q_hook:IsStunDebuff() return true end
function modifier_azazin_q_hook:IsPurgable() return true end
function modifier_azazin_q_hook:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_azazin_q_hook:RemoveOnDeath() return false end

function modifier_azazin_q_hook:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.offset = 80
	self.threshold = 80
	self.speed = self:GetAbility():GetSpecialValueFor( "hook_speed" )

	if not IsServer() then return end

	self.data = self.ability.projectiles[kv.handle]
	if not self.data then
		self.failed = true
		self:Destroy()
		return
	end
	self.origin = self.data.cast_location

	self.ability.projectiles[kv.handle] = nil

	self.enemy = self.parent:GetTeamNumber()~=self.caster:GetTeamNumber()
	self.stunned = self.enemy and (not self.parent:IsMagicImmune())
	self.interrupted = false

	self.direction = self.origin - self.parent:GetAbsOrigin()
	self.direction.z = 0

	self.distance = self.direction:Length2D() - self.offset
	self.direction = self.direction:Normalized()

	self.duration = self.distance/self.speed
	self:SetDuration(self.duration,true)

	self.parent:SetForwardVector( self.direction )

	if not self:ApplyHorizontalMotionController() then
		self:GetParent():RemoveHorizontalMotionController( self )
	end

end

function modifier_azazin_q_hook:OnDestroy()
    StopSoundOn("azazin_q", self:GetCaster())
	if not IsServer() then return end
	if self.failed then return end

	ParticleManager:DestroyParticle( self.data.effect_cast, true )
	ParticleManager:ReleaseParticleIndex( self.data.effect_cast )

	if not self.interrupted then
		self:GetParent():RemoveHorizontalMotionController( self )
	end

	FindClearSpaceForUnit( self.parent, self.origin - self.direction * self.offset, true )

    if self.parent:GetTeamNumber()~=self.caster:GetTeamNumber() then
        local midpoint = self.parent:GetAbsOrigin()
        self:GetAbility():SpawnTreeRing(midpoint)
        if self.caster:HasShard() then
            CreateModifierThinker(self.caster, self:GetAbility(), "modifier_azazin_q_tree_walk_aura", {duration = self:GetAbility():GetSpecialValueFor("ring_duration")}, midpoint, self.caster:GetTeamNumber(), false)
        end
        if self:GetAbility():GetSpecialValueFor("tether") == 1 then
            CreateModifierThinker(self.caster, self:GetAbility(), "modifier_azazin_tether_aura", {duration = self:GetAbility():GetSpecialValueFor("ring_duration")}, midpoint, self.caster:GetTeamNumber(), false)
        end
    end
	EmitSoundOn( "Hero_Pudge.AttackHookRetractStop", self.caster )
end

function modifier_azazin_q_hook:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end

function modifier_azazin_q_hook:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_azazin_q_hook:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = self.stunned,
    }
end

function modifier_azazin_q_hook:UpdateHorizontalMotion( me, dt )
	if self.interrupted then return end

	local nextpos = me:GetAbsOrigin() + self.direction * self.speed * dt
	nextpos = GetGroundPosition( nextpos, me )
	me:SetOrigin( nextpos )

	if (self.caster:GetAbsOrigin()-self.origin):Length2D() > self.threshold then
		ParticleManager:SetParticleControlEnt( self.data.effect_cast, 0, self:GetCaster(), PATTACH_WORLDORIGIN, "attach_hitloc", self.origin, true )
		ParticleManager:SetParticleControl( self.data.effect_cast, 0, self.origin )
	end
end

function modifier_azazin_q_hook:OnHorizontalMotionInterrupted()
	ParticleManager:SetParticleControlEnt( self.data.effect_cast, 0, self:GetCaster(), PATTACH_WORLDORIGIN, "attach_hitloc", self.origin, true )
	ParticleManager:SetParticleControlEnt( self.data.effect_cast, 1, self:GetCaster(), PATTACH_WORLDORIGIN, "attach_hitloc", self.origin, true )
	ParticleManager:SetParticleControl( self.data.effect_cast, 0, self.origin )
	ParticleManager:SetParticleControl( self.data.effect_cast, 1, self.origin )

	self:GetParent():RemoveHorizontalMotionController( self )
	self.interrupted = true
end


modifier_azazin_q_hook_self = class({})

function modifier_azazin_q_hook_self:IsHidden() return true end
function modifier_azazin_q_hook_self:IsDebuff() return false end
function modifier_azazin_q_hook_self:IsPurgable() return false end

function modifier_azazin_q_hook_self:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true
	}
end