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

function leon_q:GetCastPoint()
    if self:GetCaster():HasModifier("modifier_arsen_testosteron_debuff") or self:GetCaster():HasModifier("modifier_silvername_w_facet_2_forced") or self:GetCaster():HasModifier("modifier_vihor_r_debuff") or self:GetCaster():HasModifier("modifier_kachok_test") then
        return 0
    end
	return self:GetSpecialValueFor( "total_cast_time_tooltip" )
end

local function LeonQ_ConsumeOneCharge(ab)
    if not ab or ab:IsNull() then return false end
    if not ab.GetCurrentAbilityCharges then return false end

    local before = ab:GetCurrentAbilityCharges()
    if before <= 0 then return false end

    if ab.SpendCharge then
        ab:SpendCharge()
    else
        ab:UseResources(false, false, false, true)
    end

    local after = ab:GetCurrentAbilityCharges()
    if after < before then
        return true
    end

    if ab.SetCurrentAbilityCharges then
        ab:SetCurrentAbilityCharges(math.max(0, before - 1))
        return true
    end

    return false
end

local function Leon_IsExternallyDisarmedAbility(unit)
    if not unit or unit:IsNull() then return false end
    if not unit:IsDisarmed() then return false end
    for _, mod in pairs(unit:FindAllModifiers()) do
        local tables = {}
        mod:CheckStateToTable(tables)
        for state_name, mod_table in pairs(tables) do
            if tostring(state_name) == tostring(MODIFIER_STATE_DISARMED) and LEON_INTERNAL_DISARM_MODS[mod:GetName()] == nil then
                return true
            end
        end
    end
    return false
end

function leon_q:CastFilterResultLocation(location)
    if not IsServer() then return end
    local caster = self:GetCaster()
    if not caster or caster:IsNull() or not location then
        return UF_FAIL_CUSTOM
    end
    if Leon_IsExternallyDisarmedAbility(caster) then
        self._cast_err = "#dota_hud_error_leon_q_disarmed"
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end

function leon_q:GetCustomCastErrorLocation(location)
    if not IsServer() then return end
    return self._cast_err
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

function leon_q:FireAttack(aim_point, manual)
    if not IsServer() then return end
    if not aim_point then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() or (not caster:IsAlive()) then return end
    local effect_name = "particles/leon_attack.vpcf"
    if caster:HasModifier("modifier_overvodka_store_skin_8") then
        effect_name = "particles/leon_attack_skin.vpcf"
    end
    aim_point = Vector(aim_point.x, aim_point.y, 0)

    if manual then
        if not LeonQ_ConsumeOneCharge(self) then
            return
        end
    end

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

    local timeout = 0
    if caster:IsIllusion() then
        caster:AddNewModifier(caster, self, "modifier_rooted", { duration = self:GetCastPoint() + 0.1 })
        caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.0)
        timeout = self:GetSpecialValueFor("total_cast_time_tooltip")
        if not timeout or timeout < 0 then timeout = 0 end
    end

    Timers:CreateTimer(timeout, function()
        if not caster or caster:IsNull() or (not caster:IsAlive()) then return end
        if not self or self:IsNull() then return end

        for i = 1, attacks do
            Timers:CreateTimer((i - 1) * dt, function()
                if not caster or caster:IsNull() or (not caster:IsAlive()) then return end
                if not self or self:IsNull() then return end

                local spawn_origin = caster:GetAbsOrigin()
                local attach = caster:ScriptLookupAttachment("attach_attack1")
                if attach and attach > 0 then
                    spawn_origin = caster:GetAttachmentOrigin(attach)
                end

                local origin2d = Vector(spawn_origin.x, spawn_origin.y, 0)

                local range = caster:Script_GetAttackRange()
                if range <= 0 then range = 1 end

                local dir = (aim_point - origin2d); dir.z = 0
                if dir:Length2D() < 1 then
                    dir = caster:GetForwardVector(); dir.z = 0
                end
                dir = dir:Normalized()

                local t   = (attacks == 1) and 0 or ((i - 1) / (attacks - 1))
                local ang = half - spread * t
                local dir_i = RotatePosition(Vector(0,0,0), QAngle(0, ang, 0), dir)
                dir_i.z = 0
                dir_i = dir_i:Normalized()

                ProjectileManager:CreateLinearProjectile({
                    Ability = self,
                    EffectName = effect_name,
                    vSpawnOrigin = spawn_origin,
                    fDistance = range,
                    fStartRadius = radius,
                    fEndRadius   = radius,
                    Source = caster,
                    iUnitTargetTeam  = DOTA_UNIT_TARGET_TEAM_BOTH,
                    iUnitTargetType  = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_COURIER + DOTA_UNIT_TARGET_OTHER,
                    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                    bDeleteOnHit = true,
                    bProvidesVision = true,
                    iVisionRadius = 100,
                    iVisionTeamNumber = caster:GetTeamNumber(),
                    vVelocity = dir_i * speed,
                    ExtraData = {
                        ox = spawn_origin.x, oy = spawn_origin.y, oz = spawn_origin.z,
                        range = range,
                        pct   = self:GetSpecialValueFor("attack_damage_pct"),
                        far   = self:GetSpecialValueFor("damage_far_pct"),
                    }
                })
            end)
        end
    end)
end


function leon_q:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local aim_point = self:GetCursorPosition()
    aim_point.z = 0
    self:FireAttack(aim_point, false)
end

function leon_q:OnProjectileHit_ExtraData(target, location, ExtraData)
    if not IsServer() then return end
    if not target or target:IsNull() then return false end
    if target:IsInvulnerable() then return true end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return true end
    if target == caster then return false end

    if ExtraData and tonumber(ExtraData.lolli) == 1 then
        local src   = tonumber(ExtraData.src) or 0
        local tick  = tonumber(ExtraData.tick) or -1
        local phase = tonumber(ExtraData.phase) or 0

        if src > 0 and tick >= 0 then
            self._lolliHit = self._lolliHit or {}

            local pack = self._lolliHit[src]
            if not pack or pack.tick ~= tick then
                pack = { tick = tick, phases = {} }
                self._lolliHit[src] = pack
            end

            pack.phases[phase] = pack.phases[phase] or {}
            local hitSet = pack.phases[phase]

            local tidx = target:entindex()
            if hitSet[tidx] then
            end
            hitSet[tidx] = true
        end
    end

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

function modifier_leon_q_controller:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
    }
end

local function LeonQ_AddChargesSafe(ab, add)
    if not ab or ab:IsNull() then return end

    add = tonumber(add) or 0
    if add <= 0 then return end

    local lvl = ab:GetLevel()
    if lvl <= 0 then return end

    local cur = ab:GetCurrentAbilityCharges()
    local max = nil
    if ab.GetMaxAbilityCharges then
        max = ab:GetMaxAbilityCharges(lvl)
    end

    if max and max > 0 then
        local new = cur + add
        if new > max then new = max end
        if new ~= cur then
            ab:SetCurrentAbilityCharges(new)
        end
        if new >= max and ab.RefreshCharges then
            ab:RefreshCharges()
        end
    else
        ab:SetCurrentAbilityCharges(cur + add)
    end
end

function modifier_leon_q_controller:OnDeath(params)
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    if not parent:IsRealHero() then return end
    if parent:IsIllusion() then return end
    if parent == params.unit then
        EmitSoundOnClient("Leon.Death", parent:GetPlayerOwner())
        return
    end

    if not parent:HasTalent("special_bonus_unique_leon_5") then return end

    local victim = params.unit
    local attacker = params.attacker
    if not victim or victim:IsNull() then return end
    if not attacker or attacker:IsNull() then return end

    if not victim:IsRealHero() or victim:IsIllusion() then return end
    if victim:GetTeamNumber() == parent:GetTeamNumber() then return end

    local credited = false
    if attacker == parent then
        credited = true
    else
        if attacker.GetOwnerEntity then
            local owner = attacker:GetOwnerEntity()
            if owner == parent then
                credited = true
            end
        end
    end
    if not credited then return end

    local ab = self:GetAbility()
    if not ab or ab:IsNull() then return end
    local bonus_charges = ab:GetSpecialValueFor("restore_charges") or 0
    LeonQ_AddChargesSafe(ab, bonus_charges)
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

    if Leon_IsExternallyDisarmedAbility(unit) or unit:IsStunned() or unit:IsHexed() or unit:IsSilenced() then
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
