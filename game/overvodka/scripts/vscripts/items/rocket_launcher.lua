LinkLuaModifier("modifier_bombardiro_fly_rocket_launcher", "items/rocket_launcher", LUA_MODIFIER_MOTION_HORIZONTAL)

item_rocket_launcher = class({})

function item_rocket_launcher:OnVectorCastStart(vStartLocation, vDirection)
    if not IsServer() then return end

    local caster = self:GetCaster()
    local point = vStartLocation
    EmitSoundOnLocationWithCaster(point, "rocket_launcher", caster)
    self.effect = ParticleManager:CreateParticle("particles/rocket_launcher.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.effect, 0, point)
    ParticleManager:SetParticleControl(self.effect, 2, point)

    local fly_distance = 3000
    local spawnPos = vStartLocation - vDirection * fly_distance
    spawnPos.z = GetGroundHeight(spawnPos, caster)
    local bombardiro = CreateUnitByName("npc_bombardiro", spawnPos, true, caster, caster, caster:GetTeamNumber())
    if not bombardiro then return end
    local fly_ability = bombardiro:FindAbilityByName("bombardiro_fly")
    if fly_ability then fly_ability:SetLevel(0) end
    local bombs_ability = bombardiro:FindAbilityByName("bombardiro_bombs")
    if bombs_ability then bombs_ability:SetLevel(1) end

    bombardiro:AddNewModifier(caster, self, "modifier_bombardiro_fly_rocket_launcher", {
        point_x = vStartLocation.x,
        point_y = vStartLocation.y,
        dir_x = vDirection.x,
        dir_y = vDirection.y,
        fly_distance = fly_distance
    })
end

modifier_bombardiro_fly_rocket_launcher = class({})

function modifier_bombardiro_fly_rocket_launcher:IsHidden()      return true end
function modifier_bombardiro_fly_rocket_launcher:IsPurgable()    return false end
function modifier_bombardiro_fly_rocket_launcher:RemoveOnDeath() return false end

function modifier_bombardiro_fly_rocket_launcher:OnCreated(kv)
    if not IsServer() then return end
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(self:GetAbility().effect, false)
        ParticleManager:ReleaseParticleIndex(self:GetAbility().effect)
        if self:GetAbility().SpendCharge then
            self:GetAbility():SpendCharge(1)
        end
    end)
    local parent = self:GetParent()
    local caster = self:GetCaster()
    local target_x = kv.point_x
    local target_y = kv.point_y
    self.fly_distance = kv.fly_distance or 2000
    local dir_x = kv.dir_x or 0
    local dir_y = kv.dir_y or 0
    self.direction = Vector(dir_x, dir_y, 0):Normalized()
    local center = Vector(target_x, target_y, 0)
    center.z = GetGroundHeight(center, parent)
    self.center = center
    local endPoint = center + self.direction * self.fly_distance
    endPoint.z = GetGroundHeight(endPoint, parent)
    self.endPoint = endPoint
    Timers:CreateTimer(0.03, function()
        if parent and not parent:IsNull() and parent:IsAlive() then
            ExecuteOrderFromTable({
                UnitIndex = parent:entindex(),
                OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                Position = endPoint
            })
        end
    end)
    EmitSoundOn("bombardiro", parent)
    EmitSoundOn("bombardiro_plane_sound", parent)
    self.ALL_TEAMS = {
        DOTA_TEAM_CUSTOM_1,
        DOTA_TEAM_CUSTOM_2,
        DOTA_TEAM_CUSTOM_3,
        DOTA_TEAM_CUSTOM_4,
        DOTA_TEAM_CUSTOM_5,
        DOTA_TEAM_CUSTOM_6,
        DOTA_TEAM_CUSTOM_7,
        DOTA_TEAM_CUSTOM_8,
        DOTA_TEAM_GOODGUYS,
        DOTA_TEAM_BADGUYS
    }
    local speed = self:GetAbsoluteMoveSpeed(parent)
    local max_time = (self.fly_distance * 2) / speed + 2.0
    Timers:CreateTimer(max_time, function()
        if parent and not parent:IsNull() and parent:IsAlive() then
            parent:ForceKill(false)
            UTIL_Remove(parent)
        end
    end)
    self:StartIntervalThink(0.05)
end

function modifier_bombardiro_fly_rocket_launcher:GetAbsoluteMoveSpeed(parent)
    if GetMapName() == "overvodka_5x5" then
        return 1200
    end
    return 900
end

function modifier_bombardiro_fly_rocket_launcher:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    }
end

function modifier_bombardiro_fly_rocket_launcher:GetModifierMoveSpeed_Absolute(params)
    return self:GetAbsoluteMoveSpeed(self:GetParent())
end

function modifier_bombardiro_fly_rocket_launcher:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_FLYING]            = true,
        [MODIFIER_STATE_INVULNERABLE]      = true,
        [MODIFIER_STATE_UNSELECTABLE]      = true,
        [MODIFIER_STATE_NO_HEALTH_BAR]     = true,
    }
end

function modifier_bombardiro_fly_rocket_launcher:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()
    if not parent or parent:IsNull() or not parent:IsAlive() then
        self:Destroy()
        return
    end

    local pos = parent:GetAbsOrigin()
    for _, team in ipairs(self.ALL_TEAMS) do
        AddFOWViewer(team, pos, 400, 0.1, false)
    end
    local bombardiro_bombs = parent:FindAbilityByName("bombardiro_bombs")
    if bombardiro_bombs and bombardiro_bombs:IsCooldownReady() then
        local enemies = FindUnitsInRadius(
            parent:GetTeamNumber(),
            pos, nil,
            700,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )
        if #enemies > 0 then
            for _, enemy in ipairs(enemies) do
                if enemy and enemy:IsAlive() then
                    parent:CastAbilityOnPosition(enemy:GetAbsOrigin(), bombardiro_bombs, -1)
                end
            end
        end
    end
    local dist2 = (pos - self.endPoint):Length2D()
    if dist2 < 50 then
        parent:ForceKill(false)
        UTIL_Remove(parent)
        self:Destroy()
    end
end

function modifier_bombardiro_fly_rocket_launcher:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    if parent and not parent:IsNull() then
        parent:ForceKill(false)
        UTIL_Remove(parent)
    end
end
