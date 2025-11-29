LinkLuaModifier("modifier_peacemaker_scepter_handler",   "heroes/peacemaker/peacemaker_scepter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_peacemaker_scepter_vigilante", "heroes/peacemaker/peacemaker_scepter", LUA_MODIFIER_MOTION_NONE)

peacemaker_scepter = class({})

function peacemaker_scepter:Precache(ctx)
    PrecacheResource("particle", "particles/econ/items/void_spirit/void_spirit_immortal_2021/void_spirit_immortal_2021_astral_step.vpcf", ctx)
    PrecacheResource("particle", "particles/econ/items/void_spirit/void_spirit_immortal_2021/void_spirit_immortal_2021_astral_step_impact.vpcf", ctx)
    PrecacheResource("particle", "particles/econ/items/spectre/spectre_arcana/spectre_arcana_loadout_spawn_v2.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_void_spirit.vsndevts", ctx)
    PrecacheResource("soundfile", "soundevents/peacemaker_sounds.vsndevts", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_juggernaut.vsndevts", ctx)
    PrecacheUnitByNameSync("npc_peacemaker_vigilante", ctx)
end

function peacemaker_scepter:GetIntrinsicModifierName()
    return "modifier_peacemaker_scepter_handler"
end

function peacemaker_scepter:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end
    if self.vigilante and IsValidEntity(self.vigilante) then
        if self.vigilante:IsAlive() then
            self.vigilante:ForceKill(false)
        end
        self.vigilante = nil
    end
    
    local spawn_pos = caster:GetAbsOrigin() + RandomVector(175)

    local vigilante = CreateUnitByName("npc_peacemaker_vigilante", spawn_pos, true, caster, nil, caster:GetTeamNumber())
    if not vigilante or vigilante:IsNull() then
        return
    end

    vigilante:SetOwner(caster)
    self.vigilante = vigilante
    self:SetupVigilanteStats(vigilante, caster)
    vigilante:AddNewModifier(caster, self, "modifier_peacemaker_scepter_vigilante", {duration = self:GetSpecialValueFor("duration")})
    local p = ParticleManager:CreateParticle("particles/econ/items/spectre/spectre_arcana/spectre_arcana_loadout_spawn_v2.vpcf", PATTACH_ABSORIGIN_FOLLOW, vigilante)
    ParticleManager:ReleaseParticleIndex(p)
end

function peacemaker_scepter:SetupVigilanteStats(vigilante, caster)
    if not IsServer() then return end
    if not vigilante or vigilante:IsNull() then return end
    if not caster or caster:IsNull() then return end
    local avg = caster:GetAverageTrueAttackDamage(nil) or 0
    if avg <= 0 then avg = 1 end
    vigilante:SetBaseDamageMin(avg)
    vigilante:SetBaseDamageMax(avg)
end


modifier_peacemaker_scepter_handler = class({})

function modifier_peacemaker_scepter_handler:IsHidden()      return true end
function modifier_peacemaker_scepter_handler:IsPurgable()    return false end
function modifier_peacemaker_scepter_handler:RemoveOnDeath() return false end

function modifier_peacemaker_scepter_handler:OnCreated()
    if not IsServer() then return end
    self.current_target      = nil
    self.current_target_time = -1
end

function modifier_peacemaker_scepter_handler:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_peacemaker_scepter_handler:OnDeath(params)
    if not IsServer() then return end

    if not self.current_target or self.current_target:IsNull() then
        return
    end

    if params.unit == self.current_target then
        self.current_target      = nil
        self.current_target_time = -1
    end
end

function modifier_peacemaker_scepter_handler:OnAttackLanded(params)
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end
    if params.attacker ~= parent then return end

    local target = params.target
    if not target or target:IsNull() then
        self.current_target = nil
        return
    end

    if target:GetTeamNumber() == parent:GetTeamNumber() then
        self.current_target = nil
        return
    end
    if target:IsBuilding() or target:IsOther() or target:IsWard() then
        self.current_target = nil
        return
    end
    if not target:IsAlive() or target:IsInvulnerable() then
        self.current_target = nil
        return
    end

    self.current_target      = target
    self.current_target_time = GameRules:GetGameTime()
end

function modifier_peacemaker_scepter_handler:GetCurrentTarget()
    if not IsServer() then return nil end

    if self.current_target
        and not self.current_target:IsNull()
        and self.current_target:IsAlive()
        and not self.current_target:IsInvulnerable()
    then
        return self.current_target
    end

    return nil
end

function modifier_peacemaker_scepter_handler:GetCurrentTargetAfter(time_limit)
    if not IsServer() then return nil end

    if self.current_target
        and not self.current_target:IsNull()
        and self.current_target:IsAlive()
        and not self.current_target:IsInvulnerable()
        and self.current_target_time
        and self.current_target_time >= time_limit
    then
        return self.current_target
    end

    return nil
end


modifier_peacemaker_scepter_vigilante = class({})

function modifier_peacemaker_scepter_vigilante:IsHidden()      return true end
function modifier_peacemaker_scepter_vigilante:IsPurgable()    return false end
function modifier_peacemaker_scepter_vigilante:RemoveOnDeath() return true end

function modifier_peacemaker_scepter_vigilante:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE]   = true,
        [MODIFIER_STATE_UNSELECTABLE]   = true,
        [MODIFIER_STATE_NO_HEALTH_BAR]  = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_peacemaker_scepter_vigilante:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
    }
end

function modifier_peacemaker_scepter_vigilante:GetFixedAttackRate()
    return self:GetAbility():GetSpecialValueFor("attack_interval") or 0.6
end

function modifier_peacemaker_scepter_vigilante:OnCreated()
    self.parent  = self:GetParent()
    self.caster  = self:GetCaster()
    self.ability = self:GetAbility()
    if not self.ability or self.ability:IsNull() then return end
    self.spawn_time    = GameRules:GetGameTime()
    self.idle_duration = self.ability:GetSpecialValueFor("idle_duration") or 0.5
    self.current_target        = nil
    self.dashed_on_this_target = false
    self.has_cut_target        = false
    self.dash_interval   = self.ability:GetSpecialValueFor("dash_interval") or 0.2
    self.next_dash_time  = self.spawn_time + self.idle_duration
    self.max_follow_range = self.ability:GetSpecialValueFor("max_follow_range") or 500
    self.dash_max_distance  = self.ability:GetSpecialValueFor("dash_max_distance")  or 1200

    if not IsServer() then return end
    self:StartIntervalThink(0.05)
end

function modifier_peacemaker_scepter_vigilante:OnIntervalThink()
    if not IsServer() then return end

    if not self.ability or self.ability:IsNull() then
        self:Destroy()
        return
    end
    if not self.caster or self.caster:IsNull() then
        self:Destroy()
        return
    end
    if not self.caster:IsAlive() then
        self:Destroy()
        return
    end

    local now = GameRules:GetGameTime()
    if now < self.spawn_time + self.idle_duration then
        return
    end

    local handler = self.caster:FindModifierByName("modifier_peacemaker_scepter_handler")
    local desired_target = nil
    if handler and not handler:IsNull() and handler.GetCurrentTargetAfter then
        desired_target = handler:GetCurrentTargetAfter(self.spawn_time + self.idle_duration)
    end

    if desired_target and not desired_target:IsNull() and desired_target:IsAlive() then
        local distance = (desired_target:GetAbsOrigin() - self.parent:GetAbsOrigin()):Length2D()
        if distance > (self.dash_max_distance or 1200)
            and not self.caster:CanEntityBeSeenByMyTeam(desired_target) then
            desired_target = nil
        end
    end

    if not desired_target or desired_target:IsNull() or not desired_target:IsAlive() then
        self.current_target   = nil
        self.has_cut_target   = false
        self.dashed_on_this_target = false
        self.parent:Stop()
        return
    end


    if desired_target ~= self.current_target then
        self.current_target        = desired_target
        self.has_cut_target        = false
        self.dashed_on_this_target = false
        self.next_dash_time        = now
    end

    if not self.current_target or self.current_target:IsNull() or not self.current_target:IsAlive() then
        self.parent:Stop()
        self.has_cut_target = false
        return
    end

    if not self.has_cut_target then
        if now >= self.next_dash_time then
            local cut = self:DoAstralDash(self.current_target)
            if cut then
                self.has_cut_target = true
            end
            self.next_dash_time = now + self.dash_interval
        end
        return
    end

    if self.current_target and not self.current_target:IsNull() then
        if self.current_target:IsAlive() then
            local distance = (self.current_target:GetAbsOrigin() - self.parent:GetAbsOrigin()):Length2D()

            if distance > (self.max_follow_range or 500) and now >= self.next_dash_time then
                self.parent:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 3.0)
                self:DoAstralDash(self.current_target)
                self.next_dash_time = now + self.dash_interval
            end

            self.parent:MoveToTargetToAttack(self.current_target)
        end
    else
        self.has_cut_target = false
        self.current_target = nil
        self.parent:Stop()
    end
end

function modifier_peacemaker_scepter_vigilante:DoAstralDash(target)
    if not IsServer() then return end
    if not target or target:IsNull() or not target:IsAlive() then return end

    local parent = self.parent
    local origin = parent:GetAbsOrigin()
    local target_pos = target:GetAbsOrigin()
    parent:FaceTowards(target_pos)
    local direction = target_pos - origin
    direction.z = 0
    local distance = direction:Length2D()
    if distance < 50 then
        return
    end
    direction = direction:Normalized()

    local min_dist   = self.ability:GetSpecialValueFor("dash_min_distance") or 150
    local max_dist   = self.ability:GetSpecialValueFor("dash_max_distance") or 1200
    local radius     = self.ability:GetSpecialValueFor("dash_radius")       or 150
    local overshoot  = self.ability:GetSpecialValueFor("dash_overshoot")    or 120

    local desired = distance + overshoot
    local dist = math.max(math.min(max_dist, desired), min_dist)
    local dash_end = GetGroundPosition(origin + direction * dist, parent)

    local cut_target = false

    local enemies = FindUnitsInLine(
        parent:GetTeamNumber(),
        origin, dash_end, nil, radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE
    )

    for _,enemy in ipairs(enemies) do
        if enemy and not enemy:IsNull() and enemy:IsAlive() then
            if enemy == target then
                cut_target = true
            end
            local impact = ParticleManager:CreateParticle("particles/econ/items/void_spirit/void_spirit_immortal_2021/void_spirit_immortal_2021_astral_step_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
            ParticleManager:ReleaseParticleIndex(impact)
            parent:PerformAttack(enemy, true, true, true, false, true, false, true)
        end
    end

    FindClearSpaceForUnit(parent, dash_end, true)

    local fx = ParticleManager:CreateParticle("particles/econ/items/void_spirit/void_spirit_immortal_2021/void_spirit_immortal_2021_astral_step.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, origin)
    ParticleManager:SetParticleControl(fx, 1, dash_end)
    ParticleManager:ReleaseParticleIndex(fx)

    EmitSoundOnLocationWithCaster(origin, "Hero_VoidSpirit.AstralStep.Start", parent)
    EmitSoundOnLocationWithCaster(dash_end, "Hero_VoidSpirit.AstralStep.End", parent)

    return cut_target
end

function modifier_peacemaker_scepter_vigilante:OnDestroy()
    if not IsServer() then return end
    if self.parent and not self.parent:IsNull() then
        local p = ParticleManager:CreateParticle("particles/econ/items/spectre/spectre_arcana/spectre_arcana_loadout_spawn_v2.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(p, 0, self.parent:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(p)
        self.parent:AddNoDraw()
        self.parent:ForceKill(false)
    end
end