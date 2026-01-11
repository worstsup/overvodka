LinkLuaModifier("modifier_pistol_r_drag", "heroes/pistol/pistol_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pistol_mute", "heroes/pistol/pistol_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pistol_r_torrent_slow", "heroes/pistol/pistol_r", LUA_MODIFIER_MOTION_NONE)

pistol_r = class({})

function pistol_r:Precache(ctx)
    PrecacheResource("particle", "particles/econ/items/kunkka/kunkka_immortal/kunkka_immortal_ghost_ship_cannons.vpcf", ctx)
    PrecacheResource("particle", "particles/econ/items/kunkka/kunkka_immortal/kunkka_immortal_ghost_ship_marker.vpcf", ctx)
    PrecacheResource("particle", "particles/pistol_r_cannon.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_kunkka/kunkka_spell_torrent_bubbles.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_kunkka/kunkka_spell_torrent_splash.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_kunkka.vsndevts", ctx)
    PrecacheResource("soundfile", "soundevents/pistol_sounds.vsndevts", ctx)
end

local function SetUnitOnClearGround(unit)
    Timers:CreateTimer(FrameTime(), function()
        if not unit or unit:IsNull() then return end
        local p = unit:GetAbsOrigin()
        unit:SetAbsOrigin(Vector(p.x, p.y, GetGroundPosition(p, unit).z))
        FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
        ResolveNPCPositions(unit:GetAbsOrigin(), 64)
    end)
end

function pistol_r:_StartTorrentStorm(center)
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() or (not caster:IsAlive()) then return end
    if not self or self:IsNull() then return end

    local storm_duration = self:GetSpecialValueFor("storm_duration") or 3.5
    local interval       = self:GetSpecialValueFor("storm_interval") or 0.25
    local min_r          = self:GetSpecialValueFor("storm_min_radius") or 300
    local max_r          = self:GetSpecialValueFor("storm_max_radius") or 1000

    local torrent_delay  = self:GetSpecialValueFor("storm_torrent_delay") or 1.6
    local torrent_radius = self:GetSpecialValueFor("storm_torrent_radius") or 225
    local torrent_damage = self:GetSpecialValueFor("storm_torrent_damage") or 240
    local slow_pct       = self:GetSpecialValueFor("storm_slow_pct") or 25
    local slow_dur       = self:GetSpecialValueFor("storm_slow_dur") or 2.25

    local lift_duration  = self:GetSpecialValueFor("storm_lift_duration") or 1.0

    local start = GameRules:GetGameTime()
    local next_tick = 0

    Timers:CreateTimer(0, function()
        if not self or self:IsNull() then return end
        if not caster or caster:IsNull() or (not caster:IsAlive()) then return end

        local now = GameRules:GetGameTime()
        local elapsed = now - start
        if elapsed > storm_duration + 0.01 then
            return
        end

        if elapsed + 0.001 < next_tick then
            return 0.03
        end
        next_tick = next_tick + interval

        local ang = RandomFloat(0, 360)
        local r   = RandomFloat(min_r, max_r)
        local offset = RotatePosition(Vector(0,0,0), QAngle(0, ang, 0), Vector(r, 0, 0))
        local pos = center + Vector(offset.x, offset.y, 0)
        pos.z = GetGroundPosition(pos, caster).z

        local bubbles = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_bubbles.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(bubbles, 0, pos)
        ParticleManager:SetParticleControl(bubbles, 1, Vector(torrent_radius, 0, 0))

        EmitSoundOnLocationWithCaster(pos, "Ability.pre.Torrent", caster)

        Timers:CreateTimer(torrent_delay + 0.05, function()
            if bubbles then
                ParticleManager:DestroyParticle(bubbles, false)
                ParticleManager:ReleaseParticleIndex(bubbles)
            end
        end)

        Timers:CreateTimer(torrent_delay, function()
            if not self or self:IsNull() then return end
            if not caster or caster:IsNull() then return end

            EmitSoundOnLocationWithCaster(pos, "Ability.Torrent", caster)

            local splash = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_splash.vpcf", PATTACH_CUSTOMORIGIN, caster)
            ParticleManager:SetParticleControl(splash, 0, pos)
            ParticleManager:SetParticleControl(splash, 1, Vector(torrent_radius, 0, 0))
            ParticleManager:ReleaseParticleIndex(splash)

            self:CreateVisibilityNode(pos, torrent_radius, 2.0)

            local enemies = FindUnitsInRadius(
                caster:GetTeamNumber(), pos, nil,
                torrent_radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                FIND_ANY_ORDER, false
            )

            for _, enemy in pairs(enemies) do
                if enemy and not enemy:IsNull() and enemy:IsAlive() then

                    enemy:RemoveModifierByName("modifier_knockback")

                    local kb = {
                        should_stun = 1,
                        knockback_duration = lift_duration,
                        duration = lift_duration,
                        knockback_distance = 0,
                        knockback_height = 350,
                        center_x = pos.x,
                        center_y = pos.y,
                        center_z = pos.z
                    }
                    enemy:AddNewModifier(caster, nil, "modifier_knockback", kb):SetDuration(lift_duration, true)
                    enemy:AddNewModifier(caster, self, "modifier_phased", { duration = lift_duration })
                    enemy:AddNewModifier(caster, self, "modifier_pistol_r_torrent_slow",
                        { duration = (slow_dur + lift_duration) * (1 - enemy:GetStatusResistance()), slow = slow_pct }
                    )

                    ApplyDamage({victim = enemy, attacker = caster, damage = torrent_damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
                end
            end
        end)

        return interval
    end)
end

function pistol_r:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local crash_pos = self:GetCursorPosition()
    crash_pos.z = 0

    if (crash_pos - caster:GetAbsOrigin()):Length2D() < 1 then
        crash_pos = crash_pos + caster:GetForwardVector()
        crash_pos.z = 0
    end

    self._cast_id = (self._cast_id or 0) + 1
    local cast_id = self._cast_id

    local ship_interval = self:GetSpecialValueFor("ship_interval")
    EmitSoundOnLocationWithCaster(crash_pos, "pistol_r", caster)
    StopGlobalSound( "5opka_r" )
    StopGlobalSound( "stray_scepter" )
    StopGlobalSound( "evelone_r_ambient" )
	StopGlobalSound( "golden_rain" )
    StopGlobalSound( "flash_r" )
    caster:StopSound("pistol_e")
    caster:StopSound("pistol_w")
    caster:AddNewModifier(caster, self, "modifier_pistol_mute", {duration = 12})
    for i = 1, 4 do
        Timers:CreateTimer((i - 1) * ship_interval, function()
            if not self or self:IsNull() then return end
            if not caster or caster:IsNull() or (not caster:IsAlive()) then return end
            self:_LaunchOneShip(cast_id, i, crash_pos)
        end)
    end
end

function pistol_r:_LaunchOneShip(cast_id, ship_index, crash_pos)
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local crash_delay = self:GetSpecialValueFor("crash_delay")

    local width = self:GetSpecialValueFor("width")
    local damage = self:GetSpecialValueFor("damage")
    local stun = self:GetSpecialValueFor("stun_duration")

    local ship_speed = self:GetSpecialValueFor("ship_speed")

    local dir = (crash_pos - caster:GetAbsOrigin())
    dir.z = 0
    if dir:Length2D() < 1 then dir = caster:GetForwardVector() end
    dir = dir:Normalized()

    local travel_dist = ship_speed * crash_delay
    local spawn_pos = crash_pos - dir * travel_dist
    spawn_pos.z = GetGroundPosition(spawn_pos, caster).z

    local marker = ParticleManager:CreateParticleForTeam("particles/econ/items/kunkka/kunkka_immortal/kunkka_immortal_ghost_ship_marker.vpcf", PATTACH_CUSTOMORIGIN, caster, caster:GetTeamNumber())
    ParticleManager:SetParticleControl(marker, 0, crash_pos)
    Timers:CreateTimer(crash_delay + 0.1, function()
        ParticleManager:DestroyParticle(marker, false)
        ParticleManager:ReleaseParticleIndex(marker)
    end)

    EmitSoundOnLocationWithCaster(spawn_pos, "Ability.Ghostship.bell", caster)
    EmitSoundOnLocationWithCaster(spawn_pos, "Ability.Ghostship", caster)

    ProjectileManager:CreateLinearProjectile({
        Ability = self,
        EffectName = "particles/econ/items/kunkka/kunkka_immortal/kunkka_immortal_ghost_ship_cannons.vpcf",
        vSpawnOrigin = spawn_pos,
        fDistance = travel_dist,
        fStartRadius = width,
        fEndRadius = width,
        Source = caster,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        bDeleteOnHit = false,
        bProvidesVision = true,
        iVisionRadius = width,
        iVisionTeamNumber = caster:GetTeamNumber(),
        vVelocity = dir * ship_speed,
        ExtraData = {
            kind = 1,
            cast_id = cast_id,
            ship = ship_index,
            crash_x = crash_pos.x, crash_y = crash_pos.y, crash_z = crash_pos.z,
            spawn_x = spawn_pos.x, spawn_y = spawn_pos.y, spawn_z = spawn_pos.z,
            crash_delay = crash_delay,
            speed = ship_speed,
            width = width,
            tree = 1,
        }
    })

    local cannon_pct = self:GetSpecialValueFor("cannon_damage_pct")
    local cannon_range = self:GetSpecialValueFor("cannon_range")
    local cannon_speed = self:GetSpecialValueFor("cannon_speed")
    local cannon_radius = self:GetSpecialValueFor("cannon_radius")
    local pair_spread = 15

    local cannon_damage = damage * (cannon_pct / 100.0)

    for j = 1, 3 do
        local t = (crash_delay / 4) * j
        Timers:CreateTimer(t, function()
            if not self or self:IsNull() then return end
            if not caster or caster:IsNull() or (not caster:IsAlive()) then return end

            local ship_pos = spawn_pos + dir * (ship_speed * t)
            ship_pos.z = GetGroundPosition(ship_pos, caster).z

            local left = RotatePosition(Vector(0,0,0), QAngle(0, 90, 0), dir);  left.z = 0; left = left:Normalized()
            local right = RotatePosition(Vector(0,0,0), QAngle(0,-90, 0), dir); right.z = 0; right = right:Normalized()

            local BROADSIDE_ANGLES = { 10, 25, 40, 55 }
            local function FireBroadside(side_dir, towards_sign)
                for i = 1, #BROADSIDE_ANGLES do
                    local a = BROADSIDE_ANGLES[i]

                    local jitter = RandomFloat(-1.0, 1.0)

                    local d = RotatePosition(Vector(0,0,0), QAngle(0, towards_sign * (a + jitter), 0), side_dir)
                    d.z = 0
                    d = d:Normalized()

                    local spawn = ship_pos + side_dir * math.min(120, width * 0.25)
                    spawn.z = ship_pos.z

                    ProjectileManager:CreateLinearProjectile({
                        Ability = self,
                        EffectName = "particles/pistol_r_cannon.vpcf",
                        vSpawnOrigin = spawn,
                        fDistance = cannon_range,
                        fStartRadius = cannon_radius,
                        fEndRadius   = cannon_radius,
                        Source = caster,
                        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
                        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
                        bDeleteOnHit = true,
                        bProvidesVision = false,
                        vVelocity = d * cannon_speed,
                        ExtraData = {
                            kind = 2,
                            dmg  = cannon_damage,
                        }
                    })
                end
            end

            FireBroadside(left, -1)
            FireBroadside(right, 1)
        end)
    end

    Timers:CreateTimer(crash_delay, function()
        if not self or self:IsNull() then return end
        if not caster or caster:IsNull() then return end
        if caster:HasScepter() then
            self:_StartTorrentStorm(crash_pos)
        end
        EmitSoundOnLocationWithCaster(crash_pos, "Ability.Ghostship.crash", caster)
        self:CreateVisibilityNode(crash_pos, width, 2.0)
        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), crash_pos, nil,
            width, DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false
        )

        for _, enemy in pairs(enemies) do
            if enemy and not enemy:IsNull() and enemy:IsAlive() then
                enemy:AddNewModifier(caster, self, "modifier_generic_stunned_lua", { duration = stun })
                ApplyDamage({victim = enemy, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
            end
        end
    end)
end

function pistol_r:OnProjectileThink_ExtraData(location, ExtraData)
    if not IsServer() then return end
    if not location or not ExtraData then return end

    if tonumber(ExtraData.kind) ~= 1 then
        return
    end

    if tonumber(ExtraData.tree) ~= 1 then
        return
    end

    local width = tonumber(ExtraData.width) or self:GetSpecialValueFor("width")
    if width <= 0 then width = 425 end

    local tree_radius = math.min(220, width * 0.45)

    GridNav:DestroyTreesAroundPoint(location, tree_radius, false)
end


function pistol_r:OnProjectileHit_ExtraData(target, location, ExtraData)
    if not IsServer() then return end
    if not ExtraData then return false end

    local kind = tonumber(ExtraData.kind) or 0

    if kind == 2 then
        if not target or target:IsNull() or (not target:IsAlive()) then return false end
        local caster = self:GetCaster()
        if not caster or caster:IsNull() then return false end

        local dmg = tonumber(ExtraData.dmg) or 0
        if dmg > 0 then
            ApplyDamage({victim = target, attacker = caster, damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
        end
        return true
    end

    if kind == 1 then
        if not target or target:IsNull() or (not target:IsAlive()) then return false end

        local caster = self:GetCaster()
        if not caster or caster:IsNull() then return false end

        if target:HasModifier("modifier_pistol_r_drag") or target:IsDebuffImmune() then return false end

        local crash_pos = Vector(tonumber(ExtraData.crash_x) or 0, tonumber(ExtraData.crash_y) or 0, tonumber(ExtraData.crash_z) or 0)
        crash_pos.z = GetGroundPosition(crash_pos, target).z

        local spawn_pos = Vector(tonumber(ExtraData.spawn_x) or 0, tonumber(ExtraData.spawn_y) or 0, tonumber(ExtraData.spawn_z) or 0)
        spawn_pos.z = 0

        local speed = tonumber(ExtraData.speed) or 800
        local crash_delay = tonumber(ExtraData.crash_delay) or 2.5

        local hit_loc = location
        if hit_loc then
            hit_loc = Vector(hit_loc.x, hit_loc.y, 0)
        else
            local p = target:GetAbsOrigin()
            hit_loc = Vector(p.x, p.y, 0)
        end

        local traveled = (hit_loc - spawn_pos):Length2D()
        local elapsed = traveled / math.max(1, speed)
        local remaining = math.max(0.05, crash_delay - elapsed)

        local mod = target:AddNewModifier(caster, self, "modifier_pistol_r_drag", {
            duration = remaining + 0.1,
            crash_x = crash_pos.x,
            crash_y = crash_pos.y,
            crash_z = crash_pos.z,
            speed = speed
        })

        if mod then end
        return false
    end

    return false
end


modifier_pistol_r_drag = class({})

function modifier_pistol_r_drag:IsHidden() return true end
function modifier_pistol_r_drag:IsPurgable() return false end
function modifier_pistol_r_drag:IsDebuff() return true end
function modifier_pistol_r_drag:IsMotionController() return true end
function modifier_pistol_r_drag:GetMotionControllerPriority()
    return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH
end

function modifier_pistol_r_drag:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_pistol_r_drag:OnCreated(kv)
    if not IsServer() then return end

    self.speed = tonumber(kv.speed) or 800
    self.crash_pos = Vector(tonumber(kv.crash_x) or 0, tonumber(kv.crash_y) or 0, tonumber(kv.crash_z) or 0)
    self.crash_pos.z = GetGroundPosition(self.crash_pos, self:GetParent()).z

    self.tick = FrameTime()
    self:StartIntervalThink(self.tick)
end

function modifier_pistol_r_drag:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()
    if self:CheckMotionControllers() and not parent:IsDebuffImmune() and not parent:IsOutOfGame() then
        if not parent or parent:IsNull() or (not parent:IsAlive()) then
            self:Destroy()
            return
        end

        local cur = parent:GetAbsOrigin()
        local to = (self.crash_pos - cur)
        to.z = 0
        local dist = to:Length2D()

        if dist <= 20 then
            parent:SetAbsOrigin(self.crash_pos)
            SetUnitOnClearGround(parent)
            self:Destroy()
            return
        end

        local dir = to:Normalized()
        local step = math.min(dist, self.speed * self.tick)
        parent:SetAbsOrigin(cur + dir * step)
    else
        self:Destroy()
    end
end

function modifier_pistol_r_drag:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    if parent and not parent:IsNull() then
        SetUnitOnClearGround(parent)
    end
end

modifier_pistol_r_torrent_slow = class({})

function modifier_pistol_r_torrent_slow:IsHidden() return false end
function modifier_pistol_r_torrent_slow:IsPurgable() return true end
function modifier_pistol_r_torrent_slow:IsDebuff() return true end

function modifier_pistol_r_torrent_slow:OnCreated(kv)
    self.slow = -(tonumber(kv.slow) or 25)
end

function modifier_pistol_r_torrent_slow:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_pistol_r_torrent_slow:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end


modifier_pistol_mute = class({})
function modifier_pistol_mute:IsHidden() return true end
function modifier_pistol_mute:IsPurgable() return false end