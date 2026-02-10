LinkLuaModifier("modifier_epstein_r_house",          "heroes/epstein/epstein_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_r_pull",           "heroes/epstein/epstein_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_r_grab_warning",   "heroes/epstein/epstein_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_r_hand_pull",      "heroes/epstein/epstein_r", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_epstein_r_imprisoned",     "heroes/epstein/epstein_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_r_grab_cd",        "heroes/epstein/epstein_r", LUA_MODIFIER_MOTION_NONE)

epstein_r = class({})

function epstein_r:Precache(ctx)
    PrecacheResource("particle", "particles/epstein_r_warn.vpcf", ctx)
    PrecacheResource("particle", "particles/azazin_q.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/epstein_sounds.vsndevts", ctx)
    PrecacheUnitByNameSync("npc_epstein_house", ctx)
end

function epstein_r:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    local house_duration = self:GetSpecialValueFor("house_duration")

    local house = CreateUnitByName("npc_epstein_house", point, true, caster, caster, caster:GetTeamNumber())
    if not house or house:IsNull() then return end

    house:SetOwner(caster)
    house:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
    FindClearSpaceForUnit(house, point, true)

    house:AddNewModifier(house, nil, "modifier_kill", { duration = house_duration })
    house:AddNewModifier(house, self, "modifier_epstein_r_house", { duration = house_duration })
end

modifier_epstein_r_house = class({})

function modifier_epstein_r_house:IsHidden() return true end
function modifier_epstein_r_house:IsPurgable() return false end

function modifier_epstein_r_house:OnCreated(kv)
    self.pull_radius = self:GetAbility():GetSpecialValueFor("pull_radius")
    self.grab_radius = self:GetAbility():GetSpecialValueFor("grab_radius")
    self.warning_interval = self:GetAbility():GetSpecialValueFor("warning_interval")

    if not IsServer() then return end

    self:StartIntervalThink(self.warning_interval)
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
    self.min_pull_distance = self:GetAbility():GetSpecialValueFor("min_pull_distance")
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

    if dist <= self.min_pull_distance then
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
    self.grab_projectile_speed = self:GetAbility():GetSpecialValueFor("grab_projectile_speed")
    self.escape_cd = self:GetAbility():GetSpecialValueFor("escape_cd")
    self.grab_windup = self:GetAbility():GetSpecialValueFor("grab_windup")
    self.time = 0

    self.house = nil
    if kv and kv.house_entindex then
        self.house = EntIndexToHScript(tonumber(kv.house_entindex))
    end

    local p = ParticleManager:CreateParticle("particles/epstein_r_warn.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    self:AddParticle(p, false, false, -1, false, false)

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
        parent:AddNewModifier(house, self:GetAbility(), "modifier_epstein_r_grab_cd", { duration = self.escape_cd })
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
        EffectName = "particles/azazin_q.vpcf",
        iMoveSpeed = self.grab_projectile_speed,
        bDodgeable = true,
        bVisibleToEnemies = true,
        bProvidesVision = true,
        iVisionRadius = 200,
        iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
        ExtraData = {
            house_entindex = house:entindex()
        }
    }
    ProjectileManager:CreateTrackingProjectile(info)
end

function modifier_epstein_r_grab_warning:OnDestroy()
    if not IsServer() then return end
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

    target:AddNewModifier(house, self, "modifier_epstein_r_hand_pull", {
        duration = self:GetSpecialValueFor("hand_pull_max_duration"),
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

    self.hand_pull_speed = self:GetAbility():GetSpecialValueFor("hand_pull_speed")
    self.hand_pull_stop_distance = self:GetAbility():GetSpecialValueFor("hand_pull_stop_distance")

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

    self.release_distance = self:GetAbility():GetSpecialValueFor("release_distance")

    self.house = nil
    if kv and kv.house_entindex then
        self.house = EntIndexToHScript(tonumber(kv.house_entindex))
    end

    local parent = self:GetParent()

    parent:AddNoDraw()

    if self.house and not self.house:IsNull() and IsValidEntity(self.house) then
        parent:SetAbsOrigin(self.house:GetAbsOrigin())
    end

    self:StartIntervalThink(self.damage_interval)
end

function modifier_epstein_r_imprisoned:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() or not IsValidEntity(parent) then
        self:Destroy()
        return
    end
    if not parent:IsAlive() then
        self:Destroy()
        return
    end

    local house = self.house
    if not house or house:IsNull() or not IsValidEntity(house) then
        self:Destroy()
        return
    end

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
    local state = {
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
    return state
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
            local release_pos = center + RandomVector(self.release_distance)
            FindClearSpaceForUnit(parent, release_pos, true)
        else
            FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
        end
    end
end
