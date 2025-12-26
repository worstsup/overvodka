LinkLuaModifier("modifier_leon_q_controller", "heroes/leon/leon_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_leon_q_attack_scale", "heroes/leon/leon_q", LUA_MODIFIER_MOTION_NONE)

leon_q = class({})

function leon_q:Spawn()
    if not IsServer() then
        if CustomIndicator and CustomIndicator.RegisterAbility then
            CustomIndicator:RegisterAbility(self)
        end
        return
    end
end

function leon_q:CreateCustomIndicator(pos, unit, behavior)
    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    self._ci_fx = self._ci_fx or {}

    local old = self._ci_fx[behavior]
    if old then
        ParticleManager:DestroyParticle(old, true)
        ParticleManager:ReleaseParticleIndex(old)
        self._ci_fx[behavior] = nil
    end

    local fx = ParticleManager:CreateParticle("particles/leon_range_finder.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

    self._ci_fx[behavior] = fx
    self:UpdateCustomIndicator(pos, unit, behavior)
end

function leon_q:UpdateCustomIndicator(pos, unit, behavior)
    if not self._ci_fx then return end
    local fx = self._ci_fx[behavior]
    if not fx then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local origin = caster:GetAbsOrigin()
    origin.z = 0

    local loc = pos or origin
    loc.z = 0

    local dir = (loc - origin)
    dir.z = 0
    if dir:Length2D() < 1 then
        dir = caster:GetForwardVector()
        dir.z = 0
    end
    dir = dir:Normalized()

    local cast_range = self:GetCastRange(loc, unit)
    if cast_range <= 0 then cast_range = caster:Script_GetAttackRange() end
    if cast_range <= 0 then cast_range = 600 end

    ParticleManager:SetParticleControl(fx, 0, origin)
    ParticleManager:SetParticleControl(fx, 1, origin + dir * (cast_range + 50))
end

function leon_q:DestroyCustomIndicator(pos, unit, behavior)
    if not self._ci_fx then return end
    local fx = self._ci_fx[behavior]
    if not fx then return end

    ParticleManager:DestroyParticle(fx, false)
    ParticleManager:ReleaseParticleIndex(fx)
    self._ci_fx[behavior] = nil
end

function leon_q:IsStealable() return false end
function leon_q:ProcsMagicStick() return false end

function leon_q:GetIntrinsicModifierName()
    return "modifier_leon_q_controller"
end

function leon_q:GetCastRange(location, target)
    local caster = self:GetCaster()
    if caster and not caster:IsNull() then
        return caster:Script_GetAttackRange()
    end
    return 0
end

local function Leon_GetSecondsPerAttack(caster)
    if not caster or caster:IsNull() then return 0.7 end

    if caster.GetSecondsPerAttack then
        local s = caster:GetSecondsPerAttack(false)
        if s and s > 0 then return s end
    end

    if caster.GetAttacksPerSecond then
        local aps = caster:GetAttacksPerSecond(false)
        if aps and aps > 0 then
            return 1.0 / aps
        end
    end

    return 0.7
end

function leon_q:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local aim_point = self:GetCursorPosition()
    aim_point.z = 0

    local attacks = math.max(1, self:GetSpecialValueFor("attacks_number"))

    local speed  = self:GetSpecialValueFor("projectile_speed")
    local spread = self:GetSpecialValueFor("spread_angle")
    local radius = self:GetSpecialValueFor("blade_radius")
    local dt     = self:GetSpecialValueFor("shot_interval")

    if dt <= 0 then dt = 0.03 end
    if radius <= 0 then radius = 14 end

    local half = spread * 0.5

    caster:EmitSound("Leon.Attack")
    local cd = Leon_GetSecondsPerAttack(caster)
    self:StartCooldown(math.max(0.03, cd))

    for i = 1, attacks do
        Timers:CreateTimer((i - 1) * dt, function()
            if not caster or caster:IsNull() then return end
            if not caster:IsAlive() then return end
            if not self or self:IsNull() then return end

            local origin = caster:GetAbsOrigin()
            origin.z = 0

            local range = caster:Script_GetAttackRange()
            if range <= 0 then range = 1 end

            local dir = (aim_point - origin)
            dir.z = 0
            if dir:Length2D() < 1 then
                dir = caster:GetForwardVector()
                dir.z = 0
            end
            dir = dir:Normalized()

            local t   = (attacks == 1) and 0 or ((i - 1) / (attacks - 1))
            local ang = half - spread * t

            local dir_i = RotatePosition(Vector(0,0,0), QAngle(0, ang, 0), dir)
            dir_i.z = 0
            dir_i = dir_i:Normalized()

            ProjectileManager:CreateLinearProjectile({
                Ability = self,
                EffectName = "particles/leon_attack.vpcf",
                vSpawnOrigin = origin,
                fDistance = range,

                fStartRadius = radius,
                fEndRadius   = radius,

                Source = caster,
                iUnitTargetTeam  = DOTA_UNIT_TARGET_TEAM_BOTH,
                iUnitTargetType  = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
                iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE,

                bDeleteOnHit = true,
                bProvidesVision = true,
                iVisionRadius = 100,
                iVisionTeamNumber = caster:GetTeamNumber(),

                vVelocity = dir_i * speed,

                ExtraData = {
                    ox = origin.x, oy = origin.y, oz = origin.z,
                    range = range,
                    pct   = self:GetSpecialValueFor("attack_damage_pct"),
                    far   = self:GetSpecialValueFor("damage_far_pct"),
                }
            })
        end)
    end
end

function leon_q:OnProjectileHit_ExtraData(target, location, ExtraData)
    if not IsServer() then return end
    if not target or target:IsNull() then return false end
    if target:IsInvulnerable() then return true end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return true end
    if target == caster then return false end

    if target:GetTeamNumber() == caster:GetTeamNumber() then
        if target.IsBuilding and target:IsBuilding() then
            return false
        end
        if not target:Script_IsDeniable() then
            return false
        end
    end

    local pct = tonumber(ExtraData.pct) or self:GetSpecialValueFor("attack_damage_pct")
    local far_pct = tonumber(ExtraData.far) or self:GetSpecialValueFor("damage_far_pct")
    local range = tonumber(ExtraData.range) or caster:Script_GetAttackRange()
    if range <= 0 then range = 1 end

    local origin = Vector(ExtraData.ox or 0, ExtraData.oy or 0, ExtraData.oz or 0)
    origin.z = 0

    local traveled = 0
    if location then
        local loc = Vector(location.x, location.y, 0)
        traveled = (loc - origin):Length2D()
    end

    local frac = math.min(math.max(traveled / range, 0), 1)
    local far_mult = (far_pct / 100.0)
    local dist_mult = 1.0 + (far_mult - 1.0) * frac

    local desired_mult = (pct / 100.0) * dist_mult
    local out_pct = desired_mult * 100.0 - 100.0

    local mod = caster:AddNewModifier(caster, self, "modifier_leon_q_attack_scale", { duration = 0.2, out_pct = out_pct })

    caster:PerformAttack(target, true, true, true, true, false, false, false)

    if mod and not mod:IsNull() then
        mod:Destroy()
    else
        caster:RemoveModifierByName("modifier_leon_q_attack_scale")
    end

    return true
end


modifier_leon_q_controller = class({})

function modifier_leon_q_controller:IsHidden() return true end
function modifier_leon_q_controller:IsPurgable() return false end

function modifier_leon_q_controller:OnCreated()
    if not IsServer() then return end
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    self._oldAcquire = parent:GetAcquisitionRange()
    parent:SetAcquisitionRange(0)
    parent:SetIdleAcquire(false)

    self._nextForceCastTime = 0
    self:StartIntervalThink(0.03)
end

function modifier_leon_q_controller:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true,
    }
end

function modifier_leon_q_controller:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    if self._oldAcquire ~= nil then
        parent:SetAcquisitionRange(self._oldAcquire)
    end

    if self._oldAttackCap ~= nil then
        parent:SetAttackCapability(self._oldAttackCap)
    end
end

local function Leon_CanCastAttackAbility(unit, ab)
    if not unit or unit:IsNull() then return false end
    if not ab or ab:IsNull() then return false end
    if ab:GetLevel() <= 0 then return false end
    if ab:IsHidden() or (not ab:IsActivated()) then return false end

    if Leon_IsExternallyDisarmed(unit) or unit:IsStunned() or unit:IsHexed() or unit:IsSilenced() then
        return false
    end

    if ab.GetCurrentAbilityCharges and ab:GetCurrentAbilityCharges() <= 0 then
        return false
    end

    if not ab:IsCooldownReady() then
        return false
    end

    return true
end

function modifier_leon_q_controller:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()
    if not parent or parent:IsNull() or (not parent:IsAlive()) then return end

    local forced = parent:GetForceAttackTarget()
    if not forced or forced:IsNull() or (not forced:IsAlive()) then
        return
    end

    local now = GameRules:GetGameTime()
    if now < (self._nextForceCastTime or 0) then return end
    self._nextForceCastTime = now + 0.06

    local ab = parent:FindAbilityByName("leon_q")
    if not ab or ab:IsNull() then
        parent:MoveToTargetToAttack(forced)
        return
    end

    if not Leon_CanCastAttackAbility(parent, ab) then
        parent:MoveToTargetToAttack(forced)
        return
    end

    local pos = forced:GetAbsOrigin()
    pos.z = 0

    local pid = parent:GetPlayerOwnerID()
    if pid == nil then pid = -1 end

    parent:CastAbilityOnPosition(pos, ab, pid)
end

modifier_leon_q_attack_scale = class({})

function modifier_leon_q_attack_scale:IsHidden() return true end
function modifier_leon_q_attack_scale:IsPurgable() return false end
function modifier_leon_q_attack_scale:RemoveOnDeath() return true end

function modifier_leon_q_attack_scale:OnCreated(kv)
    if not IsServer() then return end
    self.out_pct = tonumber(kv.out_pct) or 0
end

function modifier_leon_q_attack_scale:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }
end

function modifier_leon_q_attack_scale:GetModifierDamageOutgoing_Percentage()
    return self.out_pct or 0
end
