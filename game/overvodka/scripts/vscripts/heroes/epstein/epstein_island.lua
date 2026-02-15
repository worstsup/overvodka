LinkLuaModifier("modifier_epstein_island_controller",    "heroes/epstein/epstein_island", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_island_collapse",      "heroes/epstein/epstein_island", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_epstein_island_caster_lock",   "heroes/epstein/epstein_island", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_island_aura_thinker",  "heroes/epstein/epstein_island", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_island_caster_buff",   "heroes/epstein/epstein_island", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_island_enemy_aura_thinker", "heroes/epstein/epstein_island", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_island_enemy_tethered", "heroes/epstein/epstein_island", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_island_zone_thinker", "heroes/epstein/epstein_island", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_island_on_island",    "heroes/epstein/epstein_island", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_arc_lua",              "modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH)

local forbidden_units = {
    ["npc_dota_c4_bomb"] = true,
	["npc_gaster_blaster"] = true,
	["npc_gaster_blaster_arcana"] = true,
    ["npc_telka"] = true,
    ["npc_dota_azazin_clone"] = true,
    ["npc_bombardiro"] = true,
    ["npc_overvodka_pet"] = true,
    ["npc_dota_arsen_tg_soldier"] = true,
    ["npc_sunflower"] = true,
}

epstein_island = class({})

function epstein_island:Precache(ctx)
    PrecacheResource("particle", "particles/epstein_island_pull.vpcf", ctx)
    PrecacheResource("particle", "particles/epstein_island_screen_effect.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/epstein_sounds.vsndevts", ctx)
    PrecacheResource("particle", "particles/epstein_innate.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_void_spirit/dissimilate/void_spirit_dissimilate_exit.vpcf", ctx)
    PrecacheResource("particle", "particles/econ/events/ti7/blink_dagger_end_ti7_lvl2.vpcf", ctx)
    PrecacheResource("particle", "particles/econ/events/ti7/blink_dagger_start_ti7_lvl2.vpcf", ctx)
    PrecacheResource("particle", "particles/epstein_island_smoke.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_void_spirit.vsndevts", ctx)
end

function epstein_island:OnAbilityPhaseStart()
    if not IsServer() then return end
    EmitSoundOn("epstein_island_cast", self:GetCaster())
    return true
end

function epstein_island:OnAbilityPhaseInterrupted()
    if not IsServer() then return end
    StopSoundOn("epstein_island_cast", self:GetCaster())
end

function epstein_island:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    EmitSoundOn("epstein_island_music", caster)
    local origin = caster:GetAbsOrigin()
    caster:StopSound("epstein_dance")
    StopGlobalSound( "5opka_r" )
    StopGlobalSound( "stray_scepter" )
    StopGlobalSound( "evelone_r_ambient" )
	StopGlobalSound( "golden_rain" )
    StopGlobalSound( "flash_r" )
    if caster._epstein_island_ctrl_entindex then
        local old = EntIndexToHScript(caster._epstein_island_ctrl_entindex)
        if old and IsValidEntity(old) and not old:IsNull() then
            UTIL_Remove(old)
        end
        caster._epstein_island_ctrl_entindex = nil
    end

    local collapse_duration = self:GetSpecialValueFor("collapse_duration")
    local island_duration = self:GetSpecialValueFor("island_duration")
    local return_collapse_duration = self:GetSpecialValueFor("return_collapse_duration")

    local total = collapse_duration + island_duration + return_collapse_duration + 1.0

    local thinker = CreateModifierThinker(
        caster, self, "modifier_epstein_island_controller", 
        {duration = total, origin_x = origin.x, origin_y = origin.y, origin_z = origin.z},
        origin, caster:GetTeamNumber(), false
    )

    if thinker and IsValidEntity(thinker) and not thinker:IsNull() then
        caster._epstein_island_ctrl_entindex = thinker:entindex()
    end

    local effect_cast = ParticleManager:CreateParticle( "particles/epstein_island_pull.vpcf", PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, origin )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( 700, 700, 700 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

local function _IsValidAliveUnit(u)
    if not u then return false end
    if u:GetUnitName() == "npc_epstein_house" then return true end
    if u:IsNull() then return false end
    if not IsValidEntity(u) then return false end
    if not u:IsAlive() then return false end
    if u:IsOutOfGame() then return false end
    if u:IsBuilding() then return false end
    if u:IsCourier() then return false end
    if u:IsOther() then return false end
    return true
end

modifier_epstein_island_controller = class({})

function modifier_epstein_island_controller:IsHidden() return true end
function modifier_epstein_island_controller:IsPurgable() return false end

function modifier_epstein_island_controller:OnCreated(kv)
    if not IsServer() then return end

    self.ability = self:GetAbility()
    self.caster = self.ability and self.ability:GetCaster() or nil

    if not self.ability or not self.caster or self.caster:IsNull() or not IsValidEntity(self.caster) then
        self:Destroy()
        return
    end

    self.ability:SetActivated(false)

    self.main_center = Vector(kv.origin_x or 0, kv.origin_y or 0, kv.origin_z or 0)

    self.island_center = Vector(4608, 4864, 408)

    if GetMapName() == "overvodka_duo" then
        self.island_center = Vector(-5376, -5376, 500)
    end

    self.collapse_radius = self.ability:GetSpecialValueFor("collapse_radius")
    self.collapse_duration = self.ability:GetSpecialValueFor("collapse_duration")

    self.scatter_radius = self.ability:GetSpecialValueFor("scatter_radius")
    if GetMapName() == "overvodka_5x5" then
        self.island_center = Vector(-7790, 9590, 408)
        self.scatter_radius = 300
    end
    self.scatter_duration = self.ability:GetSpecialValueFor("scatter_duration")
    self.scatter_height = self.ability:GetSpecialValueFor("scatter_height")
    self.scatter_min_radius = self.ability:GetSpecialValueFor("scatter_min_radius")
    if self.scatter_min_radius <= 0 then
        self.scatter_min_radius = math.floor(self.scatter_radius * 0.35)
    end

    self.island_duration = self.ability:GetSpecialValueFor("island_duration")
    self.island_effect_radius = self.ability:GetSpecialValueFor("island_effect_radius")
    self.island_aura_radius = self.ability:GetSpecialValueFor("island_aura_radius")

    self.return_collapse_duration = self.ability:GetSpecialValueFor("return_collapse_duration")
    if self.return_collapse_duration <= 0 then
        self.return_collapse_duration = self.collapse_duration
    end

    self.units_main = {}
    self.units_island = {}

    self.t0 = GameRules:GetGameTime()
    self.phase = 1
    self.phase2_started = false
    self.phase3_started = false

    self:CollectUnitsAt(self.main_center, self.collapse_radius, self.units_main)

    self.units_main[self.caster:entindex()] = true

    self:ApplyCollapseToSet(self.units_main, self.main_center, self.collapse_duration)

    self.caster:AddNewModifier(self.caster, self.ability, "modifier_epstein_island_caster_lock", { duration = self.collapse_duration })

    self:StartIntervalThink(0.03)
end

function modifier_epstein_island_controller:OnIntervalThink()
    if not IsServer() then return end

    if not self.ability or not self.caster or self.caster:IsNull() or not IsValidEntity(self.caster) then
        self:Destroy()
        return
    end

    local now = GameRules:GetGameTime()
    local elapsed = now - self.t0

    if self.phase == 1 and (elapsed >= self.collapse_duration) and not self.phase2_started then
        self.phase2_started = true
        self.phase = 2

        self:TeleportAndScatterSet(self.units_main, self.island_center)

        self.caster:StartGesture(ACT_DOTA_SPAWN)

        self.aura_thinker = CreateModifierThinker(
            self.caster,
            self.ability,
            "modifier_epstein_island_aura_thinker",
            {
                duration = self.island_duration + self.return_collapse_duration + 1.0,
                caster_entindex = self.caster:entindex()
            },
            self.island_center,
            self.caster:GetTeamNumber(),
            false
        )

        self.enemy_aura_thinker = CreateModifierThinker(
            self.caster,
            self.ability,
            "modifier_epstein_island_enemy_aura_thinker",
            {
                duration = self.island_duration + self.return_collapse_duration + 1.0
            },
            self.island_center,
            self.caster:GetTeamNumber(),
            false
        )

        self.zone_thinker = CreateModifierThinker(
            self.caster,
            self.ability,
            "modifier_epstein_island_zone_thinker",
            {
                duration = self.island_duration + self.return_collapse_duration + 1.0
            },
            self.island_center,
            self.caster:GetTeamNumber(),
            false
        )
    end

    if self.phase == 2 and (elapsed >= self.collapse_duration + self.island_duration) and not self.phase3_started then
        self.phase3_started = true
        self.phase = 3

        self.units_island = {}
        self:CollectUnitsAt(self.island_center, self.island_effect_radius, self.units_island)

        self:ApplyCollapseToSet(self.units_island, self.island_center, self.return_collapse_duration)
    end

    if self.phase == 3 and (elapsed >= self.collapse_duration + self.island_duration + self.return_collapse_duration) then
        self.phase = 4
        self:TeleportAndScatterSet(self.units_island, self.main_center)
        self.caster:StartGesture(ACT_DOTA_SPAWN)
        self:Destroy()
        return
    end
end

function modifier_epstein_island_controller:OnDestroy()
    if not IsServer() then return end
    if self.ability then
        self.ability:SetActivated(true)
    end
    local parent = self:GetParent()
    if parent and not parent:IsNull() and IsValidEntity(parent) then
        UTIL_Remove(parent)
    end

    if self.aura_thinker and not self.aura_thinker:IsNull() and IsValidEntity(self.aura_thinker) then
        UTIL_Remove(self.aura_thinker)
        self.aura_thinker = nil
    end

    if self.enemy_aura_thinker and not self.enemy_aura_thinker:IsNull() and IsValidEntity(self.enemy_aura_thinker) then
        UTIL_Remove(self.enemy_aura_thinker)
        self.enemy_aura_thinker = nil
    end

    if self.zone_thinker and not self.zone_thinker:IsNull() and IsValidEntity(self.zone_thinker) then
        UTIL_Remove(self.zone_thinker)
        self.zone_thinker = nil
    end

    if self.caster and not self.caster:IsNull() and IsValidEntity(self.caster) then
        if self.caster._epstein_island_ctrl_entindex == self:GetParent():entindex() then
            self.caster._epstein_island_ctrl_entindex = nil
        end
    end
end

function modifier_epstein_island_controller:CollectUnitsAt(center, radius, out_set)
    if not IsServer() then return end
    if not out_set then return end

    local friends = FindUnitsInRadius(self.caster:GetTeamNumber(), center, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_OTHER, DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false)

    for _, u in pairs(friends) do
        if _IsValidAliveUnit(u) then
            out_set[u:entindex()] = true
        end
    end

    local enemies = FindUnitsInRadius(
        self.caster:GetTeamNumber(), center,
        nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false
    )

    for _, u in pairs(enemies) do
        if _IsValidAliveUnit(u) then
            out_set[u:entindex()] = true
        end
    end
end

function modifier_epstein_island_controller:ApplyCollapseToSet(entindex_set, center, duration)
    if not IsServer() then return end
    if not entindex_set then return end

    for entindex, _ in pairs(entindex_set) do
        local u = EntIndexToHScript(entindex)
        if _IsValidAliveUnit(u) then
            u:AddNewModifier(self.caster, self.ability, "modifier_epstein_island_collapse", {
                duration = duration, center_x = center.x, center_y = center.y, center_z = center.z,
            })
        end
    end
end

function modifier_epstein_island_controller:TeleportAndScatterSet(entindex_set, target_center)
    if not IsServer() then return end
    if not entindex_set then return end
    
    local camera_lock = math.max(0.15, (self.scatter_duration or 0.3) + 0.15)

    local from = fx_origin
    if not from then
        if self.caster and not self.caster:IsNull() and IsValidEntity(self.caster) then
            from = self.caster:GetAbsOrigin()
        else
            from = target_center
        end
    end

    local start = ParticleManager:CreateParticle("particles/econ/events/ti7/blink_dagger_start_ti7_lvl2.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(start, 0, from)
    ParticleManager:ReleaseParticleIndex(start)

    local p = ParticleManager:CreateParticle("particles/econ/events/ti7/blink_dagger_end_ti7_lvl2.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(p, 0, target_center)
    ParticleManager:ReleaseParticleIndex(p)

    local p2 = ParticleManager:CreateParticle("particles/epstein_island_smoke.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(p2, 0, target_center)
    ParticleManager:ReleaseParticleIndex(p2)
    
    for entindex, _ in pairs(entindex_set) do
        local u = EntIndexToHScript(entindex)
        if _IsValidAliveUnit(u) then

            if u:IsRealHero() then
                local pid = u:GetPlayerOwnerID()
                if pid ~= nil and pid >= 0 then
                    Timers:CreateTimer(FrameTime(), function()
                        local hero = EntIndexToHScript(entindex)
                        if hero and not hero:IsNull() and IsValidEntity(hero) then
                            PlayerResource:SetCameraTarget(pid, hero)
                        end
                    end)

                    Timers:CreateTimer(camera_lock + FrameTime(), function()
                        PlayerResource:SetCameraTarget(pid, nil)
                    end)
                end
            end
            ProjectileManager:ProjectileDodge(u)
            u:SetAbsOrigin(Vector(target_center.x, target_center.y, target_center.z))

            local dir2 = RandomVector(1)
            dir2.z = 0
            dir2 = dir2:Normalized()

            local dist = RandomInt(self.scatter_min_radius, self.scatter_radius)
            local kv = {
                duration = self.scatter_duration, distance = dist, height = self.scatter_height,
                dir_x = dir2.x, dir_y = dir2.y,
                fix_end = 1, fix_duration = 1, fix_height = 1,
                isStun = 1, isRestricted = 0, isForward = 0,
                activity = ACT_DOTA_FLAIL,
            }

            local mod = u:AddNewModifier(self.caster, self.ability, "modifier_generic_arc_lua", kv)
            if mod and not mod:IsNull() then
                mod:SetEndCallback(function(interrupted)
                    local unit = EntIndexToHScript(entindex)
                    if _IsValidAliveUnit(unit) then
                        FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
                    end
                end)
            else
                FindClearSpaceForUnit(u, u:GetAbsOrigin(), true)
            end
        end
    end
end

modifier_epstein_island_collapse = class({})

function modifier_epstein_island_collapse:IsHidden() return false end
function modifier_epstein_island_collapse:IsDebuff() return true end
function modifier_epstein_island_collapse:IsStunDebuff() return true end
function modifier_epstein_island_collapse:IsPurgable() return false end
function modifier_epstein_island_collapse:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_epstein_island_collapse:OnCreated(kv)
    if not IsServer() then return end

    local parent = self:GetParent()
    if not _IsValidAliveUnit(parent) then
        self:Destroy()
        return
    end

    self.center = Vector(kv.center_x or 0, kv.center_y or 0, kv.center_z or 0)
    self.duration = self:GetDuration()

    local delta = self.center - parent:GetAbsOrigin()
    delta.z = 0
    local dist = delta:Length2D()

    if dist <= 1 or self.duration <= 0.03 then
        self:Destroy()
        return
    end

    self.speed = dist / self.duration

    if not self:ApplyHorizontalMotionController() then
        self:Destroy()
        return
    end
end

function modifier_epstein_island_collapse:DeclareFunctions()
    return { MODIFIER_PROPERTY_OVERRIDE_ANIMATION }
end

function modifier_epstein_island_collapse:GetOverrideAnimation()
    return ACT_DOTA_FLAIL
end

function modifier_epstein_island_collapse:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_epstein_island_collapse:UpdateHorizontalMotion(me, dt)
    if not IsServer() then return end
    if not _IsValidAliveUnit(me) then
        self:Destroy()
        return
    end

    local pos = me:GetAbsOrigin()
    local delta = self.center - pos
    delta.z = 0
    local dist = delta:Length2D()

    if dist <= 5 then
        me:SetAbsOrigin(Vector(self.center.x, self.center.y, pos.z))
        return
    end

    local dir = delta:Normalized()
    local step = self.speed * dt
    if step > dist then step = dist end

    me:SetAbsOrigin(pos + dir * step)
end

function modifier_epstein_island_collapse:OnHorizontalMotionInterrupted()
    if not IsServer() then return end
    self:Destroy()
end

function modifier_epstein_island_collapse:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    if parent and not parent:IsNull() and IsValidEntity(parent) then
        parent:RemoveHorizontalMotionController(self)
        if parent:IsAlive() and not parent:IsOutOfGame() then
            FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
        end
    end
end

modifier_epstein_island_caster_lock = class({})
function modifier_epstein_island_caster_lock:IsHidden() return true end
function modifier_epstein_island_caster_lock:IsPurgable() return false end
function modifier_epstein_island_caster_lock:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }
end

modifier_epstein_island_aura_thinker = class({})

function modifier_epstein_island_aura_thinker:IsHidden() return true end
function modifier_epstein_island_aura_thinker:IsPurgable() return false end

function modifier_epstein_island_aura_thinker:OnCreated(kv)
    if not IsServer() then return end
    self.ability = self:GetAbility()
    self.caster = self.ability and self.ability:GetCaster() or nil
    self.caster_entindex = kv and kv.caster_entindex and tonumber(kv.caster_entindex) or nil
    self.radius = self.ability and self.ability:GetSpecialValueFor("island_aura_radius") or 0
end

function modifier_epstein_island_aura_thinker:IsAura() return true end
function modifier_epstein_island_aura_thinker:GetModifierAura() return "modifier_epstein_island_caster_buff" end
function modifier_epstein_island_aura_thinker:GetAuraRadius() return self.radius or 0 end
function modifier_epstein_island_aura_thinker:GetAuraDuration() return 0.3 end
function modifier_epstein_island_aura_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_epstein_island_aura_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_epstein_island_aura_thinker:GetAuraSearchFlags() return 0 end

function modifier_epstein_island_aura_thinker:GetAuraEntityReject(ent)
    if not ent or ent:IsNull() or not IsValidEntity(ent) then return true end
    if not self.caster_entindex then return true end
    return ent:entindex() ~= self.caster_entindex
end

function modifier_epstein_island_aura_thinker:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    if parent and not parent:IsNull() and IsValidEntity(parent) then
        UTIL_Remove(parent)
    end
end

modifier_epstein_island_caster_buff = class({})

function modifier_epstein_island_caster_buff:IsHidden() return false end
function modifier_epstein_island_caster_buff:IsPurgable() return false end

function modifier_epstein_island_caster_buff:OnCreated()
    self.ability = self:GetAbility()
    if not self.ability then return end
    self.talent = self:GetCaster():HasTalent("special_bonus_unique_epstein_8")
    self.damage_reduction_pct = self.ability:GetSpecialValueFor("caster_damage_reduction_pct")
    self.status_resist = self.ability:GetSpecialValueFor("caster_status_resistance")
    local effect_cast = ParticleManager:CreateParticle( "particles/epstein_island_screen_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector(1,0,0) )
	self:AddParticle(effect_cast, false, false, -1, false, false)
    if not self.talent then return end
    local bkb = ParticleManager:CreateParticle("particles/items_fx/black_king_bar_avatar.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(bkb, false, false, -1, false, false)
end

function modifier_epstein_island_caster_buff:CheckState()
    return {
        [MODIFIER_STATE_DEBUFF_IMMUNE] = self.talent
    }
end

function modifier_epstein_island_caster_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_STATUS_RESISTANCE,
    }
end

function modifier_epstein_island_caster_buff:GetModifierIncomingDamage_Percentage()
    return -self.damage_reduction_pct or 0
end

function modifier_epstein_island_caster_buff:GetModifierStatusResistance()
    return self.status_resist or 0
end

modifier_epstein_island_enemy_aura_thinker = class({})

function modifier_epstein_island_enemy_aura_thinker:IsHidden() return true end
function modifier_epstein_island_enemy_aura_thinker:IsPurgable() return false end

function modifier_epstein_island_enemy_aura_thinker:OnCreated(kv)
    if not IsServer() then return end
    self.ability = self:GetAbility()
    self.radius = self.ability and self.ability:GetSpecialValueFor("island_effect_radius") or 0
end

function modifier_epstein_island_enemy_aura_thinker:IsAura() return true end
function modifier_epstein_island_enemy_aura_thinker:GetModifierAura() return "modifier_epstein_island_enemy_tethered" end
function modifier_epstein_island_enemy_aura_thinker:GetAuraRadius() return self.radius or 0 end
function modifier_epstein_island_enemy_aura_thinker:GetAuraDuration() return 0.3 end
function modifier_epstein_island_enemy_aura_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_epstein_island_enemy_aura_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_epstein_island_enemy_aura_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end

function modifier_epstein_island_enemy_aura_thinker:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    if parent and not parent:IsNull() and IsValidEntity(parent) then
        UTIL_Remove(parent)
    end
end

modifier_epstein_island_enemy_tethered = class({})

function modifier_epstein_island_enemy_tethered:IsHidden() return true end
function modifier_epstein_island_enemy_tethered:IsDebuff() return true end
function modifier_epstein_island_enemy_tethered:IsPurgable() return false end

function modifier_epstein_island_enemy_tethered:OnCreated()
    local effect_cast = ParticleManager:CreateParticle("particles/epstein_island_screen_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(effect_cast, 1, Vector(1,0,0))
    self:AddParticle(effect_cast, false, false, -1, false, false)
    self.enemy_as = self:GetAbility():GetSpecialValueFor("enemy_as")
end

function modifier_epstein_island_enemy_tethered:CheckState()
    return {
        [MODIFIER_STATE_TETHERED] = true,
    }
end

function modifier_epstein_island_enemy_tethered:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
	}
end

function modifier_epstein_island_enemy_tethered:GetModifierAttackSpeedPercentage()
	return self.enemy_as or 0
end

modifier_epstein_island_zone_thinker = class({})

function modifier_epstein_island_zone_thinker:IsHidden() return true end
function modifier_epstein_island_zone_thinker:IsPurgable() return false end

function modifier_epstein_island_zone_thinker:OnCreated()
    if not IsServer() then return end
    local ability = self:GetAbility()
    self.radius = ability and ability:GetSpecialValueFor("island_effect_radius") or 0
end

function modifier_epstein_island_zone_thinker:IsAura() return true end
function modifier_epstein_island_zone_thinker:GetModifierAura() return "modifier_epstein_island_on_island" end
function modifier_epstein_island_zone_thinker:GetAuraRadius() return self.radius or 0 end
function modifier_epstein_island_zone_thinker:GetAuraDuration() return 0.3 end
function modifier_epstein_island_zone_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_BOTH end
function modifier_epstein_island_zone_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_epstein_island_zone_thinker:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_epstein_island_zone_thinker:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    if parent and not parent:IsNull() and IsValidEntity(parent) then
        UTIL_Remove(parent)
    end
end

modifier_epstein_island_on_island = class({})

function modifier_epstein_island_on_island:IsHidden() return true end
function modifier_epstein_island_on_island:IsPurgable() return false end
function modifier_epstein_island_on_island:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end