LinkLuaModifier("modifier_amor_e_skewer",        "heroes/amor/amor_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_amor_e_pinned_fx",     "heroes/amor/amor_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_stunned_lua",  "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_arc_lua",      "modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH)

amor_e = class({})
amor_e._proj = amor_e._proj or {}

function amor_e:Precache(ctx)
    PrecacheResource("particle", "particles/amor_e.vpcf", ctx)
    PrecacheResource("particle", "particles/amor_e_impact.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_mars/mars_spear_impact_debuff.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_mars.vsndevts", ctx)
    PrecacheResource("model", "models/props_tree/ti7/ggbranch.vmdl", ctx)
end

function amor_e:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if not caster or caster:IsNull() or not target or target:IsNull() then return end

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

        EffectName = "particles/amor_e.vpcf",
        iMoveSpeed = self:GetSpecialValueFor("spear_speed"),

        bDodgeable = true,
        bVisibleToEnemies = true,
        bProvidesVision = true,
        iVisionRadius = self:GetSpecialValueFor("spear_vision"),
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

        local drag_speed = self:GetSpecialValueFor("drag_speed")
        local max_dist   = self:GetSpecialValueFor("max_drag_distance")

        local dur = 0.1
        if drag_speed and drag_speed > 0 and max_dist and max_dist > 0 then
            dur = (max_dist / drag_speed)
        end

        target:AddNewModifier(caster, self, "modifier_generic_arc_lua", {
            dir_x = dir.x, dir_y = dir.y,
            distance = max_dist,
            duration = dur, height = 0,

            fix_duration = 1, fix_end = 1, fix_height = 1,
            isStun = 1, isRestricted = 0, isForward = 1,
        })

        target:AddNewModifier(caster, self, "modifier_amor_e_skewer", {
            duration = dur + 0.1,
            dir_x = dir.x,
            dir_y = dir.y,
            max_dist = max_dist,
        })


        EmitSoundOn("Hero_Mars.Spear.Target", target)
    end

    ApplyDamage({ victim = target, attacker = caster, damage = self:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_PHYSICAL, ability = self })
    return true
end


modifier_amor_e_skewer = class({})

function modifier_amor_e_skewer:IsHidden() return false end
function modifier_amor_e_skewer:IsDebuff() return true end
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

    self.max_distance   = tonumber(kv.max_dist) or self.ability:GetSpecialValueFor("max_drag_distance")
    self.tree_radius    = self.ability:GetSpecialValueFor("pin_tree_radius")
    self.cliff_dist     = self.ability:GetSpecialValueFor("pin_cliff_check_dist")
    self.cliff_z_thresh = self.ability:GetSpecialValueFor("pin_cliff_z_threshold")

    self.start_pos = self.parent:GetAbsOrigin()
    self.end_pos   = self.start_pos + self.dir * self.max_distance

    self.tree_pos = GetGroundPosition(self.end_pos + self.dir * 80, self.parent)
    self.spawned_trees = false

    local fx = ParticleManager:CreateParticle("particles/amor_e_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(fx, 0, self.parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(fx, 1, self.dir * 1000)
    ParticleManager:SetParticleControl(fx, 2, Vector(kv.duration + self.ability:GetSpecialValueFor("stun_duration"), 0, 0))
    ParticleManager:SetParticleControlForward(fx, 0, self.dir)
    ParticleManager:ReleaseParticleIndex(fx)

    self:StartIntervalThink(0.03)
end

function modifier_amor_e_skewer:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_amor_e_skewer:OnIntervalThink()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() or not self.parent:IsAlive() then
        self:Destroy()
        return
    end

    local cur = self.parent:GetAbsOrigin()

    if self:_ShouldPin(cur) then
        self:_Pin(cur)
        return
    end

    local traveled_vec = (cur - self.start_pos); traveled_vec.z = 0
    local traveled = traveled_vec:Length2D()

    if (not self.spawned_trees) and traveled >= (self.max_distance * 0.5) then
        self.spawned_trees = true
        self:_SpawnTempTrees(self.tree_pos)
    end

    if traveled >= (self.max_distance - 20) then
        if not self.spawned_trees then
            self.spawned_trees = true
            self:_SpawnTempTrees(self.tree_pos)
        end

        self:_Pin(self.end_pos)
        return
    end

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

function modifier_amor_e_skewer:_StopArc()
    if self.parent and not self.parent:IsNull() then
        local arc = self.parent:FindModifierByName("modifier_generic_arc_lua")
        if arc and not arc:IsNull() then
            arc:Destroy()
        end
    end
end

function modifier_amor_e_skewer:_SpawnTempTrees(pin_pos)
    if not IsServer() then return end

    local duration = (self.ability and self.ability:GetSpecialValueFor("stun_duration") or 1.0) + 2.0

    local dir = self.dir or Vector(1,0,0)
    dir.z = 0
    dir = dir:Normalized()

    local right = Vector(-dir.y, dir.x, 0)

    local step = 90
    local offsets = {right * step, -right * step, right * (2*step), -right * (2*step), dir * 40}

    for _, off in ipairs(offsets) do
        local p = GetGroundPosition(pin_pos + off, self.parent)
        CreateTempTreeWithModel(p, duration, "models/props_tree/ti7/ggbranch.vmdl")
    end
end


function modifier_amor_e_skewer:_Pin(location)
    if not IsServer() then return end

    local parent = self.parent
    local caster = self.caster
    local ability = self.ability
    if not parent or parent:IsNull() then self:Destroy(); return end

    self:_StopArc()

    parent:SetAbsOrigin(GetGroundPosition(location, parent))
    FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)

    if not self.spawned_trees then
        GridNav:DestroyTreesAroundPoint(parent:GetAbsOrigin(), 120, false)
    end

    local stun = ability:GetSpecialValueFor("stun_duration")
    parent:AddNewModifier(caster, ability, "modifier_generic_stunned_lua", { duration = stun })
    parent:AddNewModifier(caster, ability, "modifier_amor_e_pinned_fx", { duration = stun })

    EmitSoundOn("Hero_Mars.Spear.Root", parent)

    self:Destroy()
end

function modifier_amor_e_skewer:GetEffectName()
    return "particles/units/heroes/hero_mars/mars_spear_impact_debuff.vpcf"
end

function modifier_amor_e_skewer:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

modifier_amor_e_pinned_fx = class({})

function modifier_amor_e_pinned_fx:IsHidden() return true end
function modifier_amor_e_pinned_fx:IsDebuff() return true end
function modifier_amor_e_pinned_fx:IsPurgable() return false end

function modifier_amor_e_pinned_fx:GetEffectName()
    return "particles/units/heroes/hero_mars/mars_spear_impact_debuff.vpcf"
end

function modifier_amor_e_pinned_fx:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end