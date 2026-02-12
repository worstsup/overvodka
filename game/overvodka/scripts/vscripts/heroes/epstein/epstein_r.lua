LinkLuaModifier("modifier_epstein_r_house",          "heroes/epstein/epstein_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_r_pull",           "heroes/epstein/epstein_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_r_grab_warning",   "heroes/epstein/epstein_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_r_hand_pull",      "heroes/epstein/epstein_r", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_epstein_r_imprisoned",     "heroes/epstein/epstein_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_r_grab_cd",        "heroes/epstein/epstein_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_r_diddy_state",    "heroes/epstein/epstein_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_r_diddy_ai",       "heroes/epstein/epstein_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_r_diddy_oil",      "heroes/epstein/epstein_r", LUA_MODIFIER_MOTION_NONE)

epstein_r = class({})

function epstein_r:Precache(ctx)
    PrecacheResource("particle", "particles/epstein_r_warn.vpcf", ctx)
    PrecacheResource("particle", "particles/epstein_hand.vpcf", ctx)
    PrecacheResource("particle", "particles/epstein_house_spawn.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/epstein_sounds.vsndevts", ctx)
    PrecacheUnitByNameSync("npc_epstein_house", ctx)
    PrecacheUnitByNameSync("npc_epstein_clone", ctx)
    PrecacheUnitByNameSync("npc_diddy", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_batrider/batrider_stickynapalm_impact.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_batrider/batrider_stickynapalm_debuff.vpcf", ctx)
    PrecacheResource("particle", "particles/status_fx/status_effect_stickynapalm.vpcf", ctx)
end

function epstein_r:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    self.already_playing_sound = false
    local house_duration = self:GetSpecialValueFor("house_duration")

    local house = CreateUnitByName("npc_epstein_house", point, true, caster, caster, caster:GetTeamNumber())
    if not house or house:IsNull() then return end
    house:SetOwner(caster)
    house:SetAngles(0, -90, 0)
    house:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
    FindClearSpaceForUnit(house, point, true)

    house:AddNewModifier(house, nil, "modifier_kill", { duration = house_duration })
    house:AddNewModifier(house, self, "modifier_epstein_r_house", { duration = house_duration })

    local p = ParticleManager:CreateParticle("particles/epstein_house_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, house)
    ParticleManager:ReleaseParticleIndex(p)
end

modifier_epstein_r_house = class({})

function modifier_epstein_r_house:IsHidden() return true end
function modifier_epstein_r_house:IsPurgable() return false end

function modifier_epstein_r_house:OnCreated(kv)
    local ability = self:GetAbility()
    local caster = ability:GetCaster()
    self.pull_radius = ability:GetSpecialValueFor("pull_radius")
    self.grab_radius = ability:GetSpecialValueFor("grab_radius")

    if not IsServer() then return end
    self:StartIntervalThink(0.15)

    if caster:HasScepter() then
        local house_eidx = self:GetParent():entindex()
        local caster_eidx = caster:entindex()
        local delay = ability:GetSpecialValueFor("scepter_delay")
        Timers:CreateTimer(delay, function()
            local house = EntIndexToHScript(house_eidx)
            local c = EntIndexToHScript(caster_eidx)
            if not house or house:IsNull() or not IsValidEntity(house) then return end
            if not c or c:IsNull() or not IsValidEntity(c) then return end
            if not c:HasScepter() then return end

            if self._diddy_spawned then return end
            self._diddy_spawned = true

            local diddy_duration = ability:GetSpecialValueFor("diddy_duration")
            local diddy = CreateUnitByName("npc_diddy", house:GetAbsOrigin(), true, c, c, c:GetTeamNumber())
            if not diddy or diddy:IsNull() then return end

            diddy:SetOwner(c)
            diddy:SetControllableByPlayer(c:GetPlayerOwnerID(), false)
            FindClearSpaceForUnit(diddy, house:GetAbsOrigin(), true)

            diddy:AddNewModifier(diddy, nil, "modifier_kill", { duration = diddy_duration })
            diddy:AddNewModifier(c, ability, "modifier_epstein_r_diddy_state", { duration = diddy_duration })

            diddy:AddNewModifier(c, ability, "modifier_epstein_r_diddy_ai", {
                duration = diddy_duration,
                caster_entindex = c:entindex(),
                house_entindex  = house:entindex(),
            })
        end)
    end
end

function modifier_epstein_r_house:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not parent or parent:IsNull() or not IsValidEntity(parent) then
        self:Destroy()
        return
    end
    if not ability then
        return
    end

    local enemies = FindUnitsInRadius(
        parent:GetTeamNumber(),
        parent:GetAbsOrigin(),
        nil,
        self.grab_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_CLOSEST,
        false
    )

    for _, enemy in pairs(enemies) do
        if enemy and not enemy:IsNull() and IsValidEntity(enemy) and enemy:IsAlive() then
            if not enemy:HasModifier("modifier_epstein_r_imprisoned")
                and not enemy:HasModifier("modifier_epstein_r_hand_pull")
                and not enemy:HasModifier("modifier_epstein_r_grab_warning")
                and not enemy:HasModifier("modifier_epstein_r_grab_cd")
                and not enemy:IsOutOfGame()
            then
                enemy:AddNewModifier(parent, ability, "modifier_epstein_r_grab_warning", {
                    house_entindex = parent:entindex()
                })
            end
        end
    end
end

function modifier_epstein_r_house:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    if parent and not parent:IsNull() and IsValidEntity(parent) then
        UTIL_Remove(parent)
    end
end

function modifier_epstein_r_house:IsAura() return true end
function modifier_epstein_r_house:GetModifierAura() return "modifier_epstein_r_pull" end
function modifier_epstein_r_house:GetAuraRadius() return self.pull_radius or 0 end
function modifier_epstein_r_house:GetAuraDuration() return 0.2 end
function modifier_epstein_r_house:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_epstein_r_house:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_epstein_r_house:GetAuraSearchFlags() return 0 end

function modifier_epstein_r_house:GetAuraEntityReject(ent)
    if not ent then return true end
    if ent:IsNull() then return true end
    if ent:IsOutOfGame() then return true end
    if ent:HasModifier("modifier_epstein_r_imprisoned") then return true end
    if ent:HasModifier("modifier_epstein_r_hand_pull") then return true end
    return false
end

function modifier_epstein_r_house:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
    }
end

modifier_epstein_r_pull = class({})

function modifier_epstein_r_pull:IsHidden() return false end
function modifier_epstein_r_pull:IsDebuff() return true end
function modifier_epstein_r_pull:IsPurgable() return false end

function modifier_epstein_r_pull:OnCreated(kv)
    if not IsServer() then return end
    if self:GetParent():HasModifier("modifier_epstein_r_imprisoned") or self:GetParent():HasModifier("modifier_epstein_r_hand_pull") or self:GetParent():IsDebuffImmune() then
        self:Destroy()
        return
    end
    self.pull_speed = self:GetAbility():GetSpecialValueFor("pull_speed")
    self:StartIntervalThink(FrameTime())
end

function modifier_epstein_r_pull:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    local house = self:GetCaster()
    if not parent or parent:IsNull() or not IsValidEntity(parent) then
        self:Destroy()
        return
    end
    if not house or house:IsNull() or not IsValidEntity(house) then
        self:Destroy()
        return
    end
    if not parent:IsAlive() or parent:IsOutOfGame() or parent:IsDebuffImmune() then
        self:Destroy()
        return
    end

    if parent:HasModifier("modifier_epstein_r_imprisoned") or parent:HasModifier("modifier_epstein_r_hand_pull") then
        self:Destroy()
        return
    end

    local center = house:GetAbsOrigin()
    local pos = parent:GetAbsOrigin()
    local delta = center - pos
    delta.z = 0
    local dist = delta:Length2D()

    if dist <= 60 then
        return
    end

    local dir = delta:Normalized()
    local step = self.pull_speed * FrameTime()
    if step > dist then step = dist end

    parent:SetAbsOrigin(pos + dir * step)
end

function modifier_epstein_r_pull:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    if parent and not parent:IsNull() and IsValidEntity(parent) and parent:IsAlive() and not parent:IsOutOfGame() and not parent:HasModifier("modifier_epstein_r_imprisoned") and not parent:HasModifier("modifier_epstein_r_hand_pull") and not parent:IsDebuffImmune() then
        FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
    end
end

modifier_epstein_r_grab_warning = class({})

function modifier_epstein_r_grab_warning:IsHidden() return false end
function modifier_epstein_r_grab_warning:IsDebuff() return true end
function modifier_epstein_r_grab_warning:IsPurgable() return true end

function modifier_epstein_r_grab_warning:OnCreated(kv)
    if not IsServer() then return end

    self.grab_radius = self:GetAbility():GetSpecialValueFor("grab_radius")
    self.grab_windup = self:GetAbility():GetSpecialValueFor("grab_windup")
    self.time = 0

    self.house = nil
    if kv and kv.house_entindex then
        self.house = EntIndexToHScript(tonumber(kv.house_entindex))
    end

    local p = ParticleManager:CreateParticle("particles/epstein_r_warn.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    self:AddParticle(p, false, false, -1, false, false)
    if self:GetParent():IsRealHero() and not self:GetAbility().already_playing_sound then
        self:GetParent():EmitSound("epstein_warning")
        self:GetAbility().already_playing_sound = true
    end
    self.fired = false
    self:StartIntervalThink(FrameTime())
end

function modifier_epstein_r_grab_warning:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() or not IsValidEntity(parent) then
        self:Destroy()
        return
    end
    if not parent:IsAlive() or parent:IsOutOfGame() then
        self:Destroy()
        return
    end

    if parent:HasModifier("modifier_epstein_r_imprisoned") or parent:HasModifier("modifier_epstein_r_hand_pull") then
        self:Destroy()
        return
    end

    local house = self.house
    if not house or house:IsNull() or not IsValidEntity(house) then
        self:Destroy()
        return
    end

    self.time = self.time + FrameTime()

    local dist = (house:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D()
    if dist > self.grab_radius then
        parent:AddNewModifier(house, self:GetAbility(), "modifier_epstein_r_grab_cd", { duration = 0.5 })
        self:Destroy()
        return
    end

    if not self.fired and self.time >= self.grab_windup then
        self.fired = true
        self:FireHandProjectile(house, parent)
        self:Destroy()
    end
end

function modifier_epstein_r_grab_warning:FireHandProjectile(house, target)
    if not IsServer() then return end
    if not house or house:IsNull() or not IsValidEntity(house) then return end
    if not target or target:IsNull() or not IsValidEntity(target) then return end

    target:RemoveModifierByNameAndCaster("modifier_epstein_r_pull", house)

    local info = {
        Target = target,
        Source = house,
        Ability = self:GetAbility(),
        EffectName = "particles/epstein_hand.vpcf",
        iMoveSpeed = 1200,
        bDodgeable = true,
        bVisibleToEnemies = true,
        bProvidesVision = true,
        iVisionRadius = 200,
        iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
        ExtraData = {
            house_entindex = house:entindex()
        }
    }
    ProjectileManager:CreateTrackingProjectile(info)
    house:EmitSound("Item.Harpoon.Cast")
end

function modifier_epstein_r_grab_warning:OnDestroy()
    if not IsServer() then return end
    self:GetParent():StopSound("epstein_warning")
    if self:GetAbility() then
        self:GetAbility().already_playing_sound = false
    end
end

modifier_epstein_r_grab_cd = class({})
function modifier_epstein_r_grab_cd:IsHidden() return true end
function modifier_epstein_r_grab_cd:IsPurgable() return false end

function epstein_r:OnProjectileHit_ExtraData(target, location, extraData)
    if not IsServer() then return end
    if not target or target:IsNull() or not IsValidEntity(target) then return true end
    if not target:IsAlive() then return true end

    local house = nil
    if extraData and extraData.house_entindex then
        house = EntIndexToHScript(tonumber(extraData.house_entindex))
    end
    if not house or house:IsNull() or not IsValidEntity(house) then
        return true
    end

    if target:HasModifier("modifier_epstein_r_imprisoned") or target:HasModifier("modifier_epstein_r_hand_pull") then
        return true
    end
    target:EmitSound("Item.Harpoon.Target")
    target:AddNewModifier(house, self, "modifier_epstein_r_hand_pull", {
        duration = 2.5,
        house_entindex = house:entindex()
    })

    return true
end

modifier_epstein_r_hand_pull = class({})

function modifier_epstein_r_hand_pull:IsHidden() return true end
function modifier_epstein_r_hand_pull:IsPurgable() return false end
function modifier_epstein_r_hand_pull:RemoveOnDeath() return true end

function modifier_epstein_r_hand_pull:OnCreated(kv)
    if not IsServer() then return end

    self.hand_pull_speed = 1200
    self.hand_pull_stop_distance = 80

    self.house = nil
    if kv and kv.house_entindex then
        self.house = EntIndexToHScript(tonumber(kv.house_entindex))
    end

    if not self.house or self.house:IsNull() or not IsValidEntity(self.house) then
        self:Destroy()
        return
    end

    if not self:ApplyHorizontalMotionController() then
        self:Destroy()
        return
    end
end

function modifier_epstein_r_hand_pull:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_epstein_r_hand_pull:UpdateHorizontalMotion(unit, dt)
    if not IsServer() then return end

    local house = self.house
    if not house or house:IsNull() or not IsValidEntity(house) then
        self:Destroy()
        return
    end
    if not unit or unit:IsNull() or not IsValidEntity(unit) then
        self:Destroy()
        return
    end

    local center = house:GetAbsOrigin()
    local pos = unit:GetAbsOrigin()
    local delta = center - pos
    delta.z = 0
    local dist = delta:Length2D()

    if dist <= self.hand_pull_stop_distance then
        self:Imprison(unit, house)
        self:Destroy()
        return
    end

    local dir = delta:Normalized()
    local step = self.hand_pull_speed * dt
    if step > dist then step = dist end

    unit:SetAbsOrigin(pos + dir * step)
end

function modifier_epstein_r_hand_pull:OnHorizontalMotionInterrupted(unit)
    if not IsServer() then return end
    self:Destroy()
end

function modifier_epstein_r_hand_pull:Imprison(unit, house)
    if not IsServer() then return end
    if not unit or unit:IsNull() or not IsValidEntity(unit) then return end
    if not house or house:IsNull() or not IsValidEntity(house) then return end

    local dur = self:GetAbility():GetSpecialValueFor("house_duration")
    local kill = house:FindModifierByName("modifier_kill")
    if kill then
        dur = kill:GetRemainingTime()
    end
    if dur < 0.1 then dur = 0.1 end

    unit:AddNewModifier(house, self:GetAbility(), "modifier_epstein_r_imprisoned", {
        duration = dur,
        house_entindex = house:entindex()
    })
end

function modifier_epstein_r_hand_pull:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    if parent and not parent:IsNull() and IsValidEntity(parent) and parent:IsAlive() and not parent:IsOutOfGame() then
        FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
    end
end

modifier_epstein_r_imprisoned = class({})

function modifier_epstein_r_imprisoned:IsHidden() return false end
function modifier_epstein_r_imprisoned:IsDebuff() return true end
function modifier_epstein_r_imprisoned:IsPurgable() return false end

function modifier_epstein_r_imprisoned:OnCreated(kv)
    if not IsServer() then return end

    self.damage_interval = self:GetAbility():GetSpecialValueFor("imprison_damage_interval")
    self.damage_base = self:GetAbility():GetSpecialValueFor("imprison_damage_base")
    self.damage_pct = self:GetAbility():GetSpecialValueFor("imprison_damage_pct")

    self.house = nil
    if kv and kv.house_entindex then
        self.house = EntIndexToHScript(tonumber(kv.house_entindex))
    end

    local parent = self:GetParent()
    parent:AddNoDraw()

    self._acc = 0
    self:StartIntervalThink(FrameTime())
end

function modifier_epstein_r_imprisoned:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() or not IsValidEntity(parent) or not parent:IsAlive() then
        self:Destroy()
        return
    end

    local house = self.house
    if not house or house:IsNull() or not IsValidEntity(house) then
        self:Destroy()
        return
    end

    parent:SetAbsOrigin(house:GetAbsOrigin())

    self._acc = (self._acc or 0) + FrameTime()
    if self._acc < (self.damage_interval or 0.5) then return end
    self._acc = 0

    local caster_hero = self:GetAbility():GetCaster()
    if not caster_hero or caster_hero:IsNull() or not IsValidEntity(caster_hero) then
        return
    end

    local maxhp = parent:GetMaxHealth()
    local damage_per_sec = self.damage_base + (maxhp * self.damage_pct * 0.01)
    local damage = damage_per_sec * self.damage_interval
    ApplyDamage({victim = parent, attacker = caster_hero, ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
end

function modifier_epstein_r_imprisoned:CheckState()
    return {
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_FROZEN] = true,
        [MODIFIER_STATE_NIGHTMARED] = true,
        [MODIFIER_STATE_HEXED] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
    }
end

function modifier_epstein_r_imprisoned:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_AVOID_DAMAGE
    }
end

function modifier_epstein_r_imprisoned:GetModifierAvoidDamage(params)
    if not IsServer() then return 0 end
    local caster_hero = self:GetAbility() and self:GetAbility():GetCaster() or nil
    if not caster_hero or caster_hero:IsNull() or not IsValidEntity(caster_hero) then
        return 0
    end

    if params and params.attacker and params.attacker ~= caster_hero then
        return 1
    end
    return 0
end

function modifier_epstein_r_imprisoned:OnDestroy()
    if not IsServer() then return end

    local parent = self:GetParent()
    if parent and not parent:IsNull() and IsValidEntity(parent) then
        parent:RemoveNoDraw()

        if parent:IsAlive() and not parent:IsOutOfGame() then
            FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
            return
        end

        local house = self.house
        if house and not house:IsNull() and IsValidEntity(house) then
            local center = house:GetAbsOrigin()
            local release_pos = center + RandomVector(180)
            FindClearSpaceForUnit(parent, release_pos, true)
        else
            FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
        end
    end
end


modifier_epstein_r_diddy_state = class({})

function modifier_epstein_r_diddy_state:IsHidden() return true end
function modifier_epstein_r_diddy_state:IsPurgable() return false end

function modifier_epstein_r_diddy_state:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }
end

modifier_epstein_r_diddy_ai = class({})

function modifier_epstein_r_diddy_ai:IsHidden() return true end
function modifier_epstein_r_diddy_ai:IsPurgable() return false end

function modifier_epstein_r_diddy_ai:OnCreated(kv)
    if not IsServer() then return end

    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.caster = self:GetCaster()

    self.caster_entindex = kv and kv.caster_entindex and tonumber(kv.caster_entindex) or -1
    self.house_entindex  = kv and kv.house_entindex and tonumber(kv.house_entindex) or -1

    self.guard_radius = 800
    self.guard_tp_dist = 1000
    self.follow_tp_dist = 2000
    self.follow_dist_min = 300
    self.follow_dist_max = 400

    self.enemy_search_radius = self.ability:GetSpecialValueFor("diddy_enemy_search_radius")
    self.oil_interval = math.max(0.3, self.ability:GetSpecialValueFor("diddy_oil_cooldown"))

    self.oil_aoe = self.ability:GetSpecialValueFor("diddy_oil_aoe") or 275

    self.oil_duration = self.ability:GetSpecialValueFor("diddy_oil_duration") or 6
    if self.oil_duration <= 0 then self.oil_duration = 6 end

    self._next_order_t = 0
    self._orbit_angle = RandomFloat(0, math.pi * 2)
    self._orbit_dir = (RandomInt(0, 1) == 1) and 1 or -1
    self._next_oil_t = GameRules:GetGameTime()

    self:StartIntervalThink(0.20)
end

local function _Valid(u)
    return u and (not u:IsNull()) and IsValidEntity(u)
end

function modifier_epstein_r_diddy_ai:OnIntervalThink()
    if not IsServer() then return end
    if not _Valid(self.parent) then self:Destroy(); return end

    local caster = EntIndexToHScript(self.caster_entindex or -1)
    local house  = EntIndexToHScript(self.house_entindex or -1)
    local now = GameRules:GetGameTime()
    local house_alive = _Valid(house)
    local caster_alive = _Valid(caster) and caster:IsAlive() and (not caster:IsOutOfGame())

    if house_alive then
        local hpos = house:GetAbsOrigin()
        local ppos = self.parent:GetAbsOrigin()
        local dist = (hpos - ppos):Length2D()

        if dist > self.guard_tp_dist then
            FindClearSpaceForUnit(self.parent, hpos, true)
        else
            self._orbit_angle = self._orbit_angle + self._orbit_dir * 0.35
            local desired = hpos + Vector(math.cos(self._orbit_angle), math.sin(self._orbit_angle), 0) * self.guard_radius

            if now >= (self._next_order_t or 0) then
                self._next_order_t = now + 0.35
                self.parent:MoveToPosition(desired)
            end
        end
    elseif caster_alive then
        local cpos = caster:GetAbsOrigin()
        local ppos = self.parent:GetAbsOrigin()
        local dist = (cpos - ppos):Length2D()

        if dist > self.follow_tp_dist then
            local dir = caster:GetForwardVector()
            dir.z = 0
            dir = dir:Normalized()
            local r = RotatePosition(Vector(0,0,0), QAngle(0, RandomInt(-110,110), 0), dir * RandomInt(self.follow_dist_min, self.follow_dist_max))
            local tp = cpos + r
            FindClearSpaceForUnit(self.parent, tp, true)
        else
            if now >= (self._next_order_t or 0) then
                self._next_order_t = now + 0.35

                local owner_dir = caster:GetForwardVector()
                owner_dir.z = 0
                owner_dir = owner_dir:Normalized()

                local base = owner_dir * RandomInt(self.follow_dist_min, self.follow_dist_max)
                local right = RotatePosition(Vector(0,0,0), QAngle(0, -90, 0), base) + cpos
                local left  = RotatePosition(Vector(0,0,0), QAngle(0,  90, 0), base) + cpos

                if (ppos - right):Length2D() > (ppos - left):Length2D() then
                    self.parent:MoveToPosition(left)
                else
                    self.parent:MoveToPosition(right)
                end
            end
        end
    end

    if now < (self._next_oil_t or 0) then return end
    if not caster_alive then return end

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        self.parent:GetAbsOrigin(), nil,
        self.enemy_search_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_CLOSEST, false
    )

    if not enemies or #enemies == 0 then return end
    local sortedEnemies = SortUnits_HeroesFirst(enemies)

    local target = sortedEnemies[1]
    if not _Valid(target) or (not target:IsAlive()) or target:IsOutOfGame() then return end

    self._next_oil_t = now + self.oil_interval
    self:OilAt(target:GetAbsOrigin(), caster)
end

function modifier_epstein_r_diddy_ai:OilAt(pos, caster)
    if not IsServer() then return end
    if not _Valid(self.parent) or not _Valid(caster) then return end

    local p = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_stickynapalm_impact.vpcf", PATTACH_WORLDORIGIN, self.parent)
	ParticleManager:SetParticleControl(p, 0, pos)
	ParticleManager:SetParticleControl(p, 1, Vector(self.oil_aoe, 0, 0))
	ParticleManager:SetParticleControl(p, 2, self.parent:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(p)

    local victims = FindUnitsInRadius(
        caster:GetTeamNumber(), pos, nil, self.oil_aoe,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_ANY_ORDER, false
    )

    for _, v in pairs(victims) do
        if _Valid(v) and v:IsAlive() and (not v:IsOutOfGame()) then
            v:AddNewModifier(caster, self.ability, "modifier_epstein_r_diddy_oil", { duration = self.oil_duration })
        end
    end
end


modifier_epstein_r_diddy_oil = class({})

function modifier_epstein_r_diddy_oil:IsHidden() return false end
function modifier_epstein_r_diddy_oil:IsDebuff() return true end
function modifier_epstein_r_diddy_oil:IsPurgable() return true end

function modifier_epstein_r_diddy_oil:GetStatusEffectName()
    return "particles/status_fx/status_effect_stickynapalm.vpcf"
end

function modifier_epstein_r_diddy_oil:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end

function modifier_epstein_r_diddy_oil:GetModifierMoveSpeedBonus_Percentage()
    local s = self:GetStackCount() or 0
    return -(self.ms_slow_per_stack or 0) * s
end

function modifier_epstein_r_diddy_oil:GetModifierAttackSpeedBonus_Constant()
    local s = self:GetStackCount() or 0
    return -(self.as_slow_per_stack or 0) * s
end

function modifier_epstein_r_diddy_oil:_ReadSpecials()
    local ability = self:GetAbility()
    self.ability = ability
    self.caster = self:GetCaster()

    self.ms_slow_per_stack = (ability and ability:GetSpecialValueFor("diddy_oil_ms_slow")) or 0
    self.as_slow_per_stack = (ability and ability:GetSpecialValueFor("diddy_oil_as_slow")) or 0
    self.damage_per_stack = (ability and ability:GetSpecialValueFor("diddy_oil_damage")) or 0
    self.max_stacks = (ability and ability:GetSpecialValueFor("diddy_oil_max_stacks")) or 20
end

function modifier_epstein_r_diddy_oil:_EnsureFx()
    if self._fx_applied then return end
    self._fx_applied = true

    local parent = self:GetParent()
    local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_stickynapalm_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    self:AddParticle(fx, false, false, -1, false, false)
end

function modifier_epstein_r_diddy_oil:_DealOilDamage(stacks)
    if not IsServer() then return end
    local dmg = (self.damage_per_stack or 0) * (stacks or 0)
    if dmg <= 0 then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() or not IsValidEntity(parent) or not parent:IsAlive() or parent:IsOutOfGame() then return end

    local attacker = self.caster
    if not attacker or attacker:IsNull() or not IsValidEntity(attacker) then
        attacker = parent
    end

    ApplyDamage({victim = parent, attacker = attacker, ability = self.ability, damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL})
end

function modifier_epstein_r_diddy_oil:OnCreated()
    self:_ReadSpecials()
    if not IsServer() then return end
    self:SetStackCount(1)
    self:_EnsureFx()
    self:_DealOilDamage(1)
end

function modifier_epstein_r_diddy_oil:OnRefresh()
    self:_ReadSpecials()
    if not IsServer() then return end

    local s = (self:GetStackCount() or 0) + 1
    local cap = self.max_stacks or 0
    if cap > 0 then s = math.min(s, cap) end

    self:SetStackCount(s)
    self:_EnsureFx()
    self:_DealOilDamage(s)
end