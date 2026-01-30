LinkLuaModifier("modifier_amor_e_skewer",        "heroes/amor/amor_e", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_amor_e_pinned_fx",     "heroes/amor/amor_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_stunned_lua",  "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_arc_lua",      "modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH)

amor_e = class({})
amor_e._proj = amor_e._proj or {}

function amor_e:Precache(ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_mars/mars_spear.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_mars/mars_spear_impact.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_mars/mars_spear_impact_debuff.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_mars.vsndevts", ctx)
    PrecacheResource("model", "models/props_tree/ti7/ggbranch.vmdl", ctx)
end

function amor_e:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if not caster or caster:IsNull() or not target or target:IsNull() then return end

    local speed  = self:GetSpecialValueFor("spear_speed")
    local vision = self:GetSpecialValueFor("spear_vision")

    local origin = caster:GetAbsOrigin()
    local tpos   = target:GetAbsOrigin()

    local init_dir = (tpos - origin)
    init_dir.z = 0
    if init_dir:Length2D() < 1 then
        init_dir = caster:GetForwardVector()
    else
        init_dir = init_dir:Normalized()
    end

    local info = {
        Target = target,
        Source = caster,
        Ability = self,

        EffectName = "particles/units/heroes/hero_mars/mars_spear.vpcf",
        iMoveSpeed = speed,

        bDodgeable = true,
        bVisibleToEnemies = true,
        bProvidesVision = true,
        iVisionRadius = vision,
        iVisionTeamNumber = caster:GetTeamNumber(),

        ExtraData = {
            ox = origin.x,
            oy = origin.y,
            oz = origin.z,
            dx = init_dir.x,
            dy = init_dir.y,
        }
    }
    
    local proj_id = ProjectileManager:CreateTrackingProjectile(info)

    self._proj[proj_id] = {
        caster_ent = caster:entindex(),
        target_ent = target:entindex(),
        last_pos   = origin,
        dir        = init_dir,
        init_dir   = init_dir,
        hit        = {},
    }

    self:_StartProjectileThink(proj_id)

    EmitSoundOn("Hero_Mars.Spear.Cast", caster)
    EmitSoundOn("Hero_Mars.Spear", caster)
end

local function _Rotate90(dir, sign)
    if sign >= 0 then
        return Vector(-dir.y, dir.x, 0)
    else
        return Vector(dir.y, -dir.x, 0)
    end
end

function amor_e:_FindProjByTargetEnt(target_ent)
    if not self._proj then return nil end
    for pid, d in pairs(self._proj) do
        if d and d.target_ent == target_ent then
            return pid
        end
    end
    return nil
end

function amor_e:_StartProjectileThink(proj_id)
    if not IsServer() then return end

    Timers:CreateTimer("amor_e_proj_" .. tostring(proj_id), {
        useGameTime = false,
        endTime = 0,
        callback = function()
            local data = self._proj and self._proj[proj_id]
            if not data then return nil end

            local caster = EntIndexToHScript(data.caster_ent or -1)
            if not caster or caster:IsNull() then
                self._proj[proj_id] = nil
                return nil
            end

            local cur = ProjectileManager:GetTrackingProjectileLocation(proj_id)
            if not cur then
                self._proj[proj_id] = nil
                return nil
            end

            local prev = data.last_pos
            local dir = (cur - prev); dir.z = 0
            if dir:Length2D() > 0.01 then
                dir = dir:Normalized()

                local init_dir = data.init_dir or dir
                if init_dir:Length2D() > 0.01 and dir:Dot(init_dir) < 0 then
                    dir = data.dir or init_dir
                end
                data.dir = dir
            else
                dir = data.dir or data.init_dir
            end

            local target = EntIndexToHScript(data.target_ent or -1)

            local width = self:GetSpecialValueFor("spear_width")
            if width <= 0 then width = 75 end

            local damage     = self:GetSpecialValueFor("damage")
            local knock_dur  = self:GetSpecialValueFor("sidestep_duration")
            local knock_dist = self:GetSpecialValueFor("sidestep_distance")

            local dmg = { attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self }

            local enemies = FindUnitsInLine(
                caster:GetTeamNumber(), prev,
                cur, nil, width,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NONE
            )

            for _, enemy in ipairs(enemies) do
                if enemy and not enemy:IsNull() and enemy:IsAlive() then
                    if target and not target:IsNull() and enemy == target then
                        -- skip main target
                    else
                        local eid = enemy:entindex()
                        if not data.hit[eid] then
                            data.hit[eid] = true

                            dmg.victim = enemy
                            ApplyDamage(dmg)

                            local to_unit = (enemy:GetAbsOrigin() - cur); to_unit.z = 0
                            local sign = (dir.x * to_unit.y - dir.y * to_unit.x) >= 0 and 1 or -1
                            local side = _Rotate90(dir, sign)

                            enemy:FaceTowards(enemy:GetAbsOrigin() + side * 100)

                            enemy:AddNewModifier(caster, self, "modifier_generic_arc_lua", {
                                dir_x = side.x, dir_y = side.y,
                                distance = knock_dist,
                                duration = knock_dur,
                                height = 0,
                                fix_duration = 1, fix_end = 1, fix_height = 1,
                                isStun = 0, isRestricted = 0, isForward = 1,
                            })

                            GridNav:DestroyTreesAroundPoint(enemy:GetAbsOrigin(), 75, false)
                            EmitSoundOn("Hero_Mars.Spear.Knockback", enemy)
                        end
                    end
                end
            end

            data.last_pos = cur
            return 0.03
        end
    })
end

function amor_e:OnProjectileHit_ExtraData(target, location, extra)
    if not IsServer() then return true end

    local pid = nil
    if target and not target:IsNull() then
        pid = self:_FindProjByTargetEnt(target:entindex())
    end
    if pid then
        self._proj[pid] = nil
        Timers:RemoveTimer("amor_e_proj_" .. tostring(pid))
    end

    if not target or target:IsNull() or not target:IsAlive() then
        return true
    end

    if target:TriggerSpellAbsorb(self) then
        return true
    end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return true end

    if not target:IsDebuffImmune() then
        local dir = Vector(tonumber(extra.dx) or 0, tonumber(extra.dy) or 0, 0)
        if dir:Length2D() < 0.01 then
            dir = (target:GetAbsOrigin() - caster:GetAbsOrigin()); dir.z = 0
            dir = (dir:Length2D() > 0.01) and dir:Normalized() or caster:GetForwardVector()
        else
            dir = dir:Normalized()
        end

        target:AddNewModifier(caster, self, "modifier_amor_e_skewer", { dir_x = dir.x, dir_y = dir.y })
        EmitSoundOn("Hero_Mars.Spear.Target", target)
    end

    ApplyDamage({ victim = target, attacker = caster, damage = self:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_PHYSICAL, ability = self })
    return true
end


modifier_amor_e_skewer = class({})

function modifier_amor_e_skewer:IsHidden() return false end
function modifier_amor_e_skewer:IsDebuff() return true end
function modifier_amor_e_skewer:IsStunDebuff() return true end
function modifier_amor_e_skewer:IsPurgable() return true end

function modifier_amor_e_skewer:OnCreated(kv)
    if not IsServer() then return end

    self.ability = self:GetAbility()
    self.caster  = self:GetCaster()
    self.parent  = self:GetParent()

    if not self.ability or self.ability:IsNull() then self:Destroy(); return end
    if not self.caster or self.caster:IsNull() then self:Destroy(); return end
    if not self.parent or self.parent:IsNull() then self:Destroy(); return end

    self.dir = Vector(tonumber(kv.dir_x) or 0, tonumber(kv.dir_y) or 0, 0)
    if self.dir:Length2D() < 0.01 then
        self.dir = self.caster:GetForwardVector()
    else
        self.dir = self.dir:Normalized()
    end

    self.drag_speed     = self.ability:GetSpecialValueFor("drag_speed")
    self.max_distance   = self.ability:GetSpecialValueFor("max_drag_distance")
    self.tree_radius    = self.ability:GetSpecialValueFor("pin_tree_radius")
    self.cliff_dist     = self.ability:GetSpecialValueFor("pin_cliff_check_dist")
    self.cliff_z_thresh = self.ability:GetSpecialValueFor("pin_cliff_z_threshold")

    self.scan_step = 50
    self.pin_distance, self.pin_pos, self.spawned_trees = self:_ComputePinPoint()

    self.start_pos = self.parent:GetAbsOrigin()
    self.traveled = 0

    self.parent:SetForwardVector(self.dir)
    self.parent:FaceTowards(self.parent:GetAbsOrigin() + self.dir * 100)

    if self:ApplyHorizontalMotionController() == false then
        self:Destroy()
        return
    end
end

function modifier_amor_e_skewer:_ComputePinPoint()
    if not IsServer() then return self.max_distance, (self.start_pos + self.dir * self.max_distance), false end

    local start = self.start_pos
    local dir = self.dir
    local maxd = math.max(0, self.max_distance or 0)

    local best_tree = nil
    local best_cliff = nil

    local step = math.max(10, self.scan_step or 50)

    local last_ground = GetGroundPosition(start, self.parent)
    for d = step, maxd, step do
        local p = start + dir * d

        -- 1) дерево
        if (not best_tree) and GridNav:IsNearbyTree(p, self.tree_radius, false) then
            best_tree = d
        end

        -- 2) уступ (аналог твоей логики, но “вдоль маршрута”)
        if not best_cliff then
            local base_loc = GetGroundPosition(p, self.parent)
            local ahead_loc = GetGroundPosition(base_loc + dir * (self.cliff_dist or 50), self.parent)

            if (ahead_loc.z - base_loc.z) > (self.cliff_z_thresh or 10) and (not GridNav:IsTraversable(ahead_loc)) then
                best_cliff = d
            end
        end

        if best_tree and best_cliff then break end
        last_ground = GetGroundPosition(p, self.parent)
    end

    local pin_d = maxd
    if best_tree and best_cliff then
        pin_d = math.min(best_tree, best_cliff)
    elseif best_tree then
        pin_d = best_tree
    elseif best_cliff then
        pin_d = best_cliff
    else
        local pin_pos = start + dir * maxd
        self:_SpawnTempTrees(pin_pos)
        return maxd, pin_pos, true
    end

    local pin_pos = start + dir * pin_d
    return pin_d, pin_pos, false
end

function modifier_amor_e_skewer:_SpawnTempTrees(pin_pos)
    if not IsServer() then return end

    local duration = (self.ability and self.ability:GetSpecialValueFor("stun_duration") or 1.0) + 2.0

    local offsets = {Vector(0, 0, 0), Vector(80, 0, 0), Vector(-80, 0, 0), Vector(0, 80, 0), Vector(0, -80, 0)}

    for _, off in ipairs(offsets) do
        local p = GetGroundPosition(pin_pos + off, self.parent)
        CreateTempTreeWithModel(p, duration, "models/props_tree/ti7/ggbranch.vmdl")
    end
end

function modifier_amor_e_skewer:OnRemoved()
    if not IsServer() then return end
    self.parent:InterruptMotionControllers(false)
end

function modifier_amor_e_skewer:DeclareFunctions()
    return { MODIFIER_PROPERTY_OVERRIDE_ANIMATION }
end

function modifier_amor_e_skewer:GetOverrideAnimation()
    return ACT_DOTA_FLAIL
end

function modifier_amor_e_skewer:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_amor_e_skewer:UpdateHorizontalMotion(me, dt)
    if not IsServer() then return end

    if not self.parent or self.parent:IsNull() or not self.parent:IsAlive() then
        self:Destroy()
        return
    end

    local step = self.drag_speed * dt

    local remaining = (self.pin_distance or self.max_distance) - self.traveled
    if remaining <= 0 then
        self:_Pin(me:GetAbsOrigin())
        return
    end

    local move = math.min(step, remaining)
    local next_pos = self.start_pos + self.dir * (self.traveled + move)

    me:SetAbsOrigin(next_pos)
    me:SetForwardVector(self.dir)
    me:FaceTowards(next_pos + self.dir * 100)

    self.traveled = self.traveled + move

    if self.traveled >= (self.pin_distance or self.max_distance) - 0.01 then
        self:_Pin(next_pos)
        return
    end
end

function modifier_amor_e_skewer:OnHorizontalMotionInterrupted()
    if not IsServer() then return end
    self:Destroy()
end

function modifier_amor_e_skewer:_ShouldPin(location)
    if GridNav:IsNearbyTree(location, self.tree_radius, false) then
        return true
    end

    local base_loc = GetGroundPosition(location, self.parent)
    local search_loc = GetGroundPosition(base_loc + self.dir * self.cliff_dist, self.parent)

    if (search_loc.z - base_loc.z) > self.cliff_z_thresh and (not GridNav:IsTraversable(search_loc)) then
        return true
    end

    return false
end

function modifier_amor_e_skewer:_Pin(location)
    local parent = self.parent
    local caster = self.caster
    local ability = self.ability

    if not parent or parent:IsNull() then
        self:Destroy()
        return
    end

    parent:SetAbsOrigin(GetGroundPosition(location, parent))
    FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
    GridNav:DestroyTreesAroundPoint(parent:GetAbsOrigin(), 120, false)
    local stun = ability:GetSpecialValueFor("stun_duration")
    parent:AddNewModifier(caster, ability, "modifier_generic_stunned_lua", { duration = stun })
    parent:AddNewModifier(caster, ability, "modifier_amor_e_pinned_fx", { duration = stun })

    local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_spear_impact.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(fx, 1, self.dir * 1000)
    ParticleManager:SetParticleControl(fx, 2, Vector(stun, 0, 0))
    ParticleManager:SetParticleControlForward(fx, 0, self.dir)
    ParticleManager:ReleaseParticleIndex(fx)

    EmitSoundOn("Hero_Mars.Spear.Root", parent)

    self:Destroy()
end

modifier_amor_e_pinned_fx = class({})

function modifier_amor_e_pinned_fx:IsHidden() return false end
function modifier_amor_e_pinned_fx:IsDebuff() return true end
function modifier_amor_e_pinned_fx:IsPurgable() return false end

function modifier_amor_e_pinned_fx:GetEffectName()
    return "particles/units/heroes/hero_mars/mars_spear_impact_debuff.vpcf"
end

function modifier_amor_e_pinned_fx:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end