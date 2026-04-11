modifier_misolo_boss = class({})
modifier_misolo_boss_phase2 = class({})

function modifier_misolo_boss:IsHidden() return true end
function modifier_misolo_boss:IsPurgable() return false end
function modifier_misolo_boss:IsPurgeException() return false end
function modifier_misolo_boss:IsPermanent() return true end
function modifier_misolo_boss:RemoveOnDeath() return false end

function modifier_misolo_boss:OnCreated(kv)
    if not IsServer() then return end

    self.parent = self:GetParent()
    self.state = "RUN_IN"
    self.intro_target = Vector(tonumber(kv.intro_x) or 0, tonumber(kv.intro_y) or 0, tonumber(kv.intro_z) or 0)
    self.next_ability_time = GameRules:GetGameTime() + 1.0
    self.cast_lock_until = 0
    self.last_ability_name = nil
    self.split_used = false

    self:LevelBossAbilities()
    self.parent:AddNewModifier(self.parent, nil, "modifier_hero_boss_running", {})
    self:StartIntervalThink(0.2)
end

function modifier_misolo_boss:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_misolo_boss:OnDeath(params)
    if not IsServer() then
        return
    end

    if params.unit ~= self.parent then
        return
    end

    _G.global_sounds_muted = false
    StopGlobalSound("misolo_start")

    EmitGlobalSound("zhenya_boss_death")
    EmitGlobalSound("Item.PickUpGemWorld")

    if OvervodkaEvents and OvervodkaEvents.ClearActiveHeroBoss then
        OvervodkaEvents:ClearActiveHeroBoss(self.parent)
    elseif HeroBossEvent then
        HeroBossEvent:ClearBossUI({ entindex = self.parent:entindex() })
    end

    local origin = self.parent:GetAbsOrigin()
    local count = 20
    local spiral_arms = 4
    local angle_step = math.rad(18)
    local radius_start = 150
    local radius_step = 90
    local spawn_interval = 0.08

    for i = 0, count - 1 do
        local idx = i

        Timers:CreateTimer(idx * spawn_interval, function()
            local item = CreateItem("item_zhenya_present", nil, nil)
            if not item then
                return
            end

            local arm = idx % spiral_arms
            local t = math.floor(idx / spiral_arms)
            local base_angle = t * angle_step
            local arm_offset = (2 * math.pi / spiral_arms) * arm
            local angle = base_angle + arm_offset
            local radius = radius_start + radius_step * t + RandomFloat(-15, 15)
            local direction = Vector(math.cos(angle), math.sin(angle), 0)
            local target_position = origin + direction * radius

            CreateItemOnPositionForLaunch(origin, item)
            item:LaunchLootInitialHeight(false, 0, 500, 0.75, target_position)
        end)
    end
end

function modifier_misolo_boss:OnDestroy()
    if not IsServer() then
        return
    end

    _G.global_sounds_muted = false
    StopGlobalSound("misolo_start")

    if OvervodkaEvents and OvervodkaEvents.ClearActiveHeroBoss then
        OvervodkaEvents:ClearActiveHeroBoss(self.parent)
    elseif HeroBossEvent then
        HeroBossEvent:ClearBossUI({ entindex = self.parent:entindex() })
    end

    if not IsValid(self.parent) or not self.parent:IsAlive() then
        return
    end

    local split = self.parent:FindAbilityByName("misolo_r")
    if IsValid(split) and split._split_active then
        split._split_active = false
        split._split_finished = true
        split:RemoveWarriors()

        if self.parent:HasModifier("modifier_misolo_r_hidden") then
            self.parent:RemoveModifierByName("modifier_misolo_r_hidden")
        else
            self.parent:RemoveNoDraw()
        end

        local return_position = split._hidden_position or self.parent:GetAbsOrigin()
        FindClearSpaceForUnit(self.parent, return_position, true)
        ResolveNPCPositions(return_position, 128)
    end

    self.parent:Stop()
    self.parent:AddNewModifier(self.parent, nil, "modifier_hero_boss_running", {})

    local origin = self.parent:GetAbsOrigin()
    local direction = origin - Vector(0, 0, 0)
    direction.z = 0

    if direction:Length2D() < 0.1 then
        direction = RandomVector(1)
    end

    local run_distance = GetMapName() == "overvodka_5x5" and 9000 or 6500
    local run_position = GetGroundPosition(origin + direction:Normalized() * run_distance, nil)
    self.parent:MoveToPosition(run_position)

    Timers:CreateTimer(12.0, function()
        if not IsValid(self.parent) then
            return
        end

        self.parent:AddNoDraw()
        UTIL_Remove(self.parent)
    end)
end

function modifier_misolo_boss:OnIntervalThink()
    if not IsServer() then
        return
    end

    if not IsValid(self.parent) then
        self:Destroy()
        return
    end

    if not self.parent:IsAlive() then
        return
    end

    self:RevealCurrentBossPosition()

    if self.state == "RUN_IN" then
        self:ThinkRunIn()
        return
    end

    local split = self.parent:FindAbilityByName("misolo_r")
    if IsValid(split) and split._split_active then
        self:ThinkSplitWarriors(split)
        return
    end

    if not self.split_used and self.parent:GetHealth() <= self.parent:GetMaxHealth() * 0.5 then
        if self:TryUseSplit(split) then
            return
        end
    end

    self:ThinkAbilities()
    self:BasicAttackAI()
end

function modifier_misolo_boss:LevelBossAbilities()
    if not IsValid(self.parent) then
        return
    end

    local levels = {
        misolo_q = 4,
        misolo_w = 4,
        misolo_e = 4,
        misolo_r = 3,
        misolo_innate = 1,
        misolo_shard = 1,
    }

    for ability_name, level in pairs(levels) do
        local ability = self.parent:FindAbilityByName(ability_name)
        if IsValid(ability) and ability:GetLevel() < level then
            ability:SetLevel(level)
        end
    end
end

function modifier_misolo_boss:RevealCurrentBossPosition()
    local split = self.parent:FindAbilityByName("misolo_r")
    if IsValid(split) and split._split_active then
        for _, role in ipairs({ "beast", "visage", "arc" }) do
            local warrior = split._warriors and split._warriors[role] or nil
            if IsValid(warrior) and warrior:IsAlive() then
                HeroBossEvent:RevealToAllTeams(warrior:GetAbsOrigin(), 500, 0.25)
            end
        end
        return
    end

    HeroBossEvent:RevealToAllTeams(self.parent:GetAbsOrigin(), 500, 0.25)
end

function modifier_misolo_boss:ThinkRunIn()
    local distance = (self.intro_target - self.parent:GetAbsOrigin()):Length2D()
    if distance > 275 then
        self.parent:MoveToPosition(self.intro_target)
        return
    end

    self.parent:Stop()
    self.parent:RemoveModifierByName("modifier_hero_boss_running")
    self.state = "FIGHT"
    self.next_ability_time = GameRules:GetGameTime() + 0.75
end

function modifier_misolo_boss:TryUseSplit(split)
    self.parent:Purge(false, true, false, true, true)
    self.parent:AddNewModifier(self.parent, nil, "modifier_invulnerable", { duration = 1.0 })

    if not HeroBossEvent:CanCastAbility(split) then
        return false
    end

    StopGlobalSound("misolo_start")
    self.parent:Stop()
    self.parent:CastAbilityNoTarget(split, -1)
    self.split_used = true
    self.cast_lock_until = GameRules:GetGameTime() + 0.6
    self.next_ability_time = GameRules:GetGameTime() + 1.5

    if not self.parent:HasModifier("modifier_misolo_boss_phase2") then
        self.parent:AddNewModifier(self.parent, nil, "modifier_misolo_boss_phase2", {})
    end

    return true
end

function modifier_misolo_boss:ThinkSplitWarriors(split)
    if not IsValid(split) then
        return
    end

    for _, role in ipairs({ "beast", "visage", "arc" }) do
        local warrior = split._warriors and split._warriors[role] or nil
        if IsValid(warrior) and warrior:IsAlive() and not warrior:HasModifier("modifier_hero_boss_simple_ai") then
            warrior:AddNewModifier(self.parent, nil, "modifier_hero_boss_simple_ai", {
                search_radius = 1200,
                cast_interval = 4.0,
                cast_lock_duration = 0.4,
                heroes_only = 0,
            })
        end
    end
end

function modifier_misolo_boss:BasicAttackAI()
    local now = GameRules:GetGameTime()
    if now < self.cast_lock_until or self.parent:IsChanneling() or self.parent:IsStunned() or self.parent:IsHexed() then
        return
    end

    local target = HeroBossEvent:FindClosestEnemy(self.parent, 1200, false)
    if IsValid(target) then
        self.parent:MoveToTargetToAttack(target)
    end
end

function modifier_misolo_boss:ThinkAbilities()
    local now = GameRules:GetGameTime()
    if now < self.next_ability_time or now < self.cast_lock_until then
        return
    end

    if self.parent:IsStunned() or self.parent:IsHexed() or self.parent:IsChanneling() then
        return
    end

    local target = HeroBossEvent:FindClosestEnemy(self.parent, 1200, true)
    if not IsValid(target) then
        self.next_ability_time = now + 0.5
        return
    end

    local q = self.parent:FindAbilityByName("misolo_q")
    local w = self.parent:FindAbilityByName("misolo_w")
    local order = self.last_ability_name == "misolo_q" and { w, q } or { q, w }

    for _, ability in ipairs(order) do
        if self:TryCastAbility(ability, target) then
            self.last_ability_name = ability:GetAbilityName()
            self.cast_lock_until = now + 0.5
            self.next_ability_time = now + 4.0
            return
        end
    end

    self.next_ability_time = now + 0.75
end

function modifier_misolo_boss:TryCastAbility(ability, target)
    if not HeroBossEvent:CanCastAbility(ability) or not IsValid(target) then
        return false
    end

    local behavior = ability:GetBehaviorInt()
    local cast_range = ability:GetCastRange(self.parent:GetAbsOrigin(), target)
    local distance = (target:GetAbsOrigin() - self.parent:GetAbsOrigin()):Length2D()

    if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) ~= 0 then
        if cast_range <= 0 or distance <= cast_range + 125 then
            self.parent:CastAbilityOnTarget(target, ability, -1)
            return true
        end
    elseif bit.band(behavior, DOTA_ABILITY_BEHAVIOR_POINT) ~= 0 then
        if cast_range <= 0 or distance <= math.max(cast_range, 900) then
            self.parent:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
            return true
        end
    end

    return false
end

modifier_misolo_boss_phase2 = class({})

function modifier_misolo_boss_phase2:IsHidden() return true end
function modifier_misolo_boss_phase2:IsPurgable() return false end
function modifier_misolo_boss_phase2:IsDebuff() return false end
