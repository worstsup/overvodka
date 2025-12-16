LinkLuaModifier("modifier_kolibri_r",       "heroes/kolibri/kolibri_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kolibri_r_orbit", "heroes/kolibri/kolibri_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_lifesteal_lua", "modifier_generic_lifesteal_lua", LUA_MODIFIER_MOTION_NONE)
kolibri_r = class({})

function kolibri_r:Precache(ctx)
	PrecacheResource( "particle", "particles/kolibri_r_attack.vpcf", ctx )
    PrecacheResource( "particle", "particles/kolibri_r.vpcf", ctx)
    PrecacheResource( "soundfile", "soundevents/kolibri_sounds.vsndevts", ctx )
    PrecacheResource( "particle", "particles/kolibri_r_buff.vpcf", ctx )
    PrecacheResource( "particle", "particles/kolibri_r_cast.vpcf", ctx )
    PrecacheResource( "particle", "particles/econ/items/jakiro/jakiro_ti10_immortal/jakiro_ti10_macropyre_projectile_flame_child_blue.vpcf", ctx )
end

function kolibri_r:OnAbilityPhaseStart()
    if not IsServer() then return true end
    EmitSoundOn( "kolibri_r", self:GetCaster() )
    self.precast_particle = ParticleManager:CreateParticle( "particles/kolibri_r_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:SetParticleControlEnt(self.precast_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
    ParticleManager:SetParticleControl(self.precast_particle, 1, self:GetCaster():GetAbsOrigin()+self:GetCaster():GetForwardVector()*100+Vector(0,0,150))
    ParticleManager:SetParticleControl(self.precast_particle, 3, self:GetCaster():GetAbsOrigin()+self:GetCaster():GetForwardVector()*100+Vector(0,0,150))
    return true
end

function kolibri_r:OnAbilityPhaseInterrupted()
    if not IsServer() then return end
    StopSoundOn( "kolibri_r", self:GetCaster() )
    if self.precast_particle then
        ParticleManager:DestroyParticle(self.precast_particle, true)
        ParticleManager:ReleaseParticleIndex(self.precast_particle)
        self.precast_particle = nil
    end
end

function kolibri_r:OnSpellStart()
    if not IsServer() then return end
    if self.precast_particle then
        ParticleManager:DestroyParticle(self.precast_particle, false)
        ParticleManager:ReleaseParticleIndex(self.precast_particle)
        self.precast_particle = nil
    end
    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end
    local duration = self:GetSpecialValueFor("duration")
    caster:AddNewModifier(caster, self, "modifier_kolibri_r", { duration = duration })
    caster:AddNewModifier(caster, self, "modifier_generic_lifesteal_lua", { duration = duration })
    local p = ParticleManager:CreateParticle("particles/kolibri_r.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(p, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
    ParticleManager:SetParticleControlEnt(p, 3, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
    ParticleManager:ReleaseParticleIndex(p)
    local p2 = ParticleManager:CreateParticle("particles/econ/items/jakiro/jakiro_ti10_immortal/jakiro_ti10_macropyre_projectile_flame_child_blue.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(p2, 3, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
    ParticleManager:ReleaseParticleIndex(p2)
end

modifier_kolibri_r = class({})

function modifier_kolibri_r:IsHidden()   return false end
function modifier_kolibri_r:IsPurgable() return false  end
function modifier_kolibri_r:GetEffectName() return "particles/kolibri_r_buff.vpcf" end

function modifier_kolibri_r:OnCreated()
    self.parent  = self:GetParent()
    self.ability = self:GetAbility()

    if not self.ability then return end

    self.bonus_as          = self.ability:GetSpecialValueFor("bonus_attack_speed")
    self.bonus_ms          = self.ability:GetSpecialValueFor("bonus_movement_speed")
    self.orbit_start_range = self.ability:GetSpecialValueFor("orbit_start_range")
    self.break_distance    = self.ability:GetSpecialValueFor("break_distance")
    self.think_interval    = self.ability:GetSpecialValueFor("think_interval")

    self.target_entindex   = -1
    self.pending_start     = false

    if not IsServer() then return end

    local ti = tonumber(self.think_interval) or 0.03
    if ti <= 0 then ti = 0.03 end
    self:StartIntervalThink(ti)
end

function modifier_kolibri_r:OnDestroy()
    if not IsServer() then return end
    self:_StopOrbit("buff_end")
end

function modifier_kolibri_r:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ORDER,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_kolibri_r:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_as or 0
end

function modifier_kolibri_r:GetModifierMoveSpeedBonus_Percentage()
    return self.bonus_ms or 0
end

function modifier_kolibri_r:_ResolveTarget()
    if self.target_entindex == nil or self.target_entindex < 0 then return nil end
    local ent = EntIndexToHScript(self.target_entindex)
    if ent and not ent:IsNull() then return ent end
    return nil
end

function modifier_kolibri_r:_IsMovementDisabled(unit)
    if not unit or unit:IsNull() then return true end
    if unit:IsStunned() then return true end
    if unit:IsRooted() then return true end
    if unit:IsHexed()  then return true end
    if unit.IsCommandRestricted and unit:IsCommandRestricted() then return true end
    return false
end

function modifier_kolibri_r:_CanSeeTarget(caster, target)
    if not caster or caster:IsNull() or not target or target:IsNull() then return false end
    if caster.CanEntityBeSeenByMyTeam then
        return caster:CanEntityBeSeenByMyTeam(target)
    end
    return true
end

function modifier_kolibri_r:_IsValidOrbitTarget(caster, target)
    if not caster or caster:IsNull() then return false end
    if not target or target:IsNull() then return false end
    if not target:IsAlive() then return false end
    if target:IsOutOfGame() then return false end
    if target:IsInvulnerable() then return false end
    if target:IsAttackImmune() then return false end
    if target:GetTeamNumber() == caster:GetTeamNumber() then return false end
    if not self:_CanSeeTarget(caster, target) then return false end
    return true
end

function modifier_kolibri_r:_StopOrbit(reason)
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end
    if self.parent:HasModifier("modifier_kolibri_r_orbit") then
        self.parent:RemoveModifierByName("modifier_kolibri_r_orbit")
    end
end

function modifier_kolibri_r:_StartOrbitIfPossible()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end
    if self.parent:HasModifier("modifier_kolibri_r_orbit") then
        self.pending_start = false
        return
    end

    local target = self:_ResolveTarget()
    if not self:_IsValidOrbitTarget(self.parent, target) then
        self.pending_start = false
        self.target_entindex = -1
        return
    end

    local dist = (self.parent:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
    if dist <= (self.orbit_start_range or 0) then
        self.pending_start = false
        self.parent:AddNewModifier(
            self.parent,
            self.ability,
            "modifier_kolibri_r_orbit",
            { target_entindex = target:entindex() }
        )
    end
end

function modifier_kolibri_r:GetModifierProcAttack_Feedback( params )
	self:PlayEffects( self:GetParent(), params.target )
end

function modifier_kolibri_r:OnIntervalThink()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end

    if self:_IsMovementDisabled(self.parent) then
        self:_StopOrbit("disabled")
        self.pending_start = false
        return
    end

    if self.parent:HasModifier("modifier_kolibri_r_orbit") then
        self.pending_start = false
        return
    end

    if self.pending_start then
        local target = self:_ResolveTarget()
        if not self:_IsValidOrbitTarget(self.parent, target) then
            self.pending_start = false
            self.target_entindex = -1
            return
        end

        local dist = (self.parent:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
        if (self.break_distance or 0) > 0 and dist > self.break_distance then
            self.pending_start = false
            self.target_entindex = -1
            return
        end

        self:_StartOrbitIfPossible()
    end
end

function modifier_kolibri_r:OnAbilityExecuted(event)
    if not IsServer() then return end
    if not event or not event.unit then return end
    if event.unit ~= self.parent then return end

    self:_StopOrbit("ability_executed")
    self.pending_start = false
    self.target_entindex = -1
end

function modifier_kolibri_r:OnOrder(event)
    if not IsServer() then return end
    if not event or not event.unit then return end
    if event.unit ~= self.parent then return end

    local order = event.order_type

    if order == DOTA_UNIT_ORDER_ATTACK_TARGET then
        local target = event.target
        if not target or target:IsNull() then
            self:_StopOrbit("attack_target_nil")
            self.pending_start = false
            self.target_entindex = -1
            return
        end

        if not self:_IsValidOrbitTarget(self.parent, target) then
            self:_StopOrbit("attack_target_invalid")
            self.pending_start = false
            self.target_entindex = -1
            return
        end

        local idx = target:entindex()

        local orbit = self.parent:FindModifierByName("modifier_kolibri_r_orbit")
        if orbit and not orbit:IsNull() and orbit.GetTargetEntIndex then
            local cur = orbit:GetTargetEntIndex()
            if cur ~= idx then
                self:_StopOrbit("switch_attack_target")
            end
        end

        orbit = self.parent:FindModifierByName("modifier_kolibri_r_orbit")
        if orbit and not orbit:IsNull() and orbit.GetTargetEntIndex and orbit:GetTargetEntIndex() == idx then
            self.pending_start = false
            self.target_entindex = idx
            return
        end

        self.target_entindex = idx
        self.pending_start = true
        return
    end

    self:_StopOrbit("other_order")
    self.pending_start = false
    self.target_entindex = -1
end


modifier_kolibri_r_orbit = class({})

function modifier_kolibri_r_orbit:IsHidden()   return true  end
function modifier_kolibri_r_orbit:IsPurgable() return false end

function modifier_kolibri_r_orbit:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_kolibri_r_orbit:GetTargetEntIndex()
    return self.target_entindex or -1
end

function modifier_kolibri_r_orbit:OnCreated(kv)
    self.parent  = self:GetParent()
    self.ability = self:GetAbility()

    if not self.ability then return end

    self.orbit_radius    = self.ability:GetSpecialValueFor("orbit_radius")
    self.break_distance  = self.ability:GetSpecialValueFor("break_distance")
    self.order_throttle  = self.ability:GetSpecialValueFor("order_throttle")
    self.think_interval  = self.ability:GetSpecialValueFor("think_interval")

    local ang_deg = self.ability:GetSpecialValueFor("angular_speed_deg_per_sec")
    self.ang_rad_per_sec = (ang_deg or 0) * math.pi / 180

    self.target_entindex = -1
    if kv and kv.target_entindex then
        self.target_entindex = tonumber(kv.target_entindex) or -1
    end

    self.angle = 0
    self._next_attack_order_time = 0
    self._last_time = 0

    if not IsServer() then return end

    if not self.parent or self.parent:IsNull() then
        self:Destroy()
        return
    end

    self._last_time = GameRules:GetGameTime()

    local target = self:_ResolveTarget()
    if not self:_IsValidTarget(target) then
        self:Destroy()
        return
    end

    local dp = self.parent:GetAbsOrigin() - target:GetAbsOrigin()
    dp.z = 0
    if dp:Length2D() > 1 then
        self.angle = math.atan2(dp.y, dp.x)
    else
        self.angle = RandomFloat(0, math.pi * 2)
    end

    local ti = tonumber(self.think_interval) or 0.03
    if ti <= 0 then ti = 0.03 end
    self:StartIntervalThink(ti)
end

function modifier_kolibri_r_orbit:OnDestroy()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end

    if self.parent:GetUnitName() ~= "npc_dota_hero_nyx_assassin" then
        FindClearSpaceForUnit(self.parent, self.parent:GetAbsOrigin(), true)
    end
end

function modifier_kolibri_r_orbit:_ResolveTarget()
    if self.target_entindex == nil or self.target_entindex < 0 then return nil end
    local ent = EntIndexToHScript(self.target_entindex)
    if ent and not ent:IsNull() then return ent end
    return nil
end

function modifier_kolibri_r_orbit:_IsMovementDisabled(unit)
    if not unit or unit:IsNull() then return true end
    if unit:IsStunned() then return true end
    if unit:IsRooted() then return true end
    if unit:IsHexed()  then return true end
    if unit.IsCommandRestricted and unit:IsCommandRestricted() then return true end
    return false
end

function modifier_kolibri_r_orbit:_CanSeeTarget(caster, target)
    if not caster or caster:IsNull() or not target or target:IsNull() then return false end
    if caster.CanEntityBeSeenByMyTeam then
        return caster:CanEntityBeSeenByMyTeam(target)
    end
    return true
end

function modifier_kolibri_r_orbit:_IsValidTarget(target)
    if not self.parent or self.parent:IsNull() then return false end
    if not target or target:IsNull() then return false end
    if not target:IsAlive() then return false end
    if target:IsOutOfGame() then return false end
    if target:IsInvulnerable() then return false end
    if target:IsAttackImmune() then return false end
    if target:GetTeamNumber() == self.parent:GetTeamNumber() then return false end
    if not self:_CanSeeTarget(self.parent, target) then return false end
    return true
end

function modifier_kolibri_r_orbit:_FindTraversablePosAround(target_pos, radius, angle)
    local tries = 8
    local step = 15 * math.pi / 180
    for i = 0, tries - 1 do
        local a = angle + step * i
        local pos = target_pos + Vector(math.cos(a), math.sin(a), 0) * radius
        pos = GetGroundPosition(pos, self.parent)

        if GridNav:IsTraversable(pos) and not GridNav:IsBlocked(pos) then
            return pos, a
        end
    end
    return nil, angle
end

function modifier_kolibri_r_orbit:OnIntervalThink()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then
        self:Destroy()
        return
    end

    local target = self:_ResolveTarget()
    if not self:_IsValidTarget(target) then
        self:Destroy()
        return
    end

    local atk = self.parent:GetAttackTarget()
    if atk and not atk:IsNull() and atk ~= target then
        self:Destroy()
        return
    end

    if self:_IsMovementDisabled(self.parent) then
        self:Destroy()
        return
    end

    local now = GameRules:GetGameTime()
    local dt = now - (self._last_time or now)
    if dt <= 0 then
        dt = tonumber(self.think_interval) or 0.03
    end
    self._last_time = now

    local parent_pos = self.parent:GetAbsOrigin()
    local target_pos = target:GetAbsOrigin()

    local dist = (parent_pos - target_pos):Length2D()
    if (self.break_distance or 0) > 0 and dist > self.break_distance then
        self:Destroy()
        return
    end

    self.angle = (self.angle or 0) + (self.ang_rad_per_sec or 0) * dt

    local radius = self.orbit_radius or 0
    if radius < 50 then radius = 50 end

    local desired_pos, new_angle = self:_FindTraversablePosAround(target_pos, radius, self.angle)
    if not desired_pos then
        self:Destroy()
        return
    end
    self.angle = new_angle

    self.parent:SetAbsOrigin(desired_pos)

    local dir = target_pos - desired_pos
    dir.z = 0
    if dir:Length2D() > 0.1 then
        dir = dir:Normalized()
        self.parent:SetForwardVector(dir)
    end

    if now >= (self._next_attack_order_time or 0) then
        self.parent:MoveToTargetToAttack(target)
        local throttle = self.order_throttle or 0.15
        if throttle < 0.05 then throttle = 0.05 end
        self._next_attack_order_time = now + throttle
    end
end

function modifier_kolibri_r:PlayEffects( caster, target )
	local particle_cast = "particles/kolibri_r_attack.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt(effect_cast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end