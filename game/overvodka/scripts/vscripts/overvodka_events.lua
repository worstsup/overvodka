if not OvervodkaEvents then
    OvervodkaEvents = class({})
end

local GOLDEN_RAIN_WINDOWS = {
    default = {
        { 4, 7 },
        { 14.5, 17 },
    },
    overvodka_5x5 = {
        { 8, 12 },
        { 20, 24 },
    },
}

local HAMSTER_WINDOWS = {
    default = {
        { 11, 12.5 },
        { 20.5, 22 },
    },
    overvodka_5x5 = {
        { 18, 20 },
    },
}

local BOMBARDIRO_FIRST_MINUTE = 1.5
local BOMBARDIRO_LAST_MINUTE = 60
local BOMBARDIRO_BLOCK_DURATION = 60.0

local GOLDEN_RAIN_ABILITY_NAME = "golden_rain"

function OvervodkaEvents:UpdateNetTableForEvent(eventKey, timesTable)
    if not timesTable then
        CustomNetTables:SetTableValue("overvodka_events", eventKey, { t1 = -1, t2 = -1 })
        return
    end

    CustomNetTables:SetTableValue("overvodka_events", eventKey, {
        t1 = timesTable[1] or -1,
        t2 = timesTable[2] or -1,
    })
end

function OvervodkaEvents:AddBombardiroBlock(startTime, endTime)
    if not self.blockedBombardiro then
        self.blockedBombardiro = {}
    end

    table.insert(self.blockedBombardiro, {
        start = startTime,
        finish = endTime,
    })
end

function OvervodkaEvents:IsGameTimeBlockedForBombardiro(gameTime)
    if not self.blockedBombardiro then return false end

    for _, interval in ipairs(self.blockedBombardiro) do
        if gameTime >= interval.start and gameTime <= interval.finish then
            return true
        end
    end

    return false
end

function OvervodkaEvents:Init()
    if not IsServer() then return end
    if self.initialized then return end
    if IsInToolsMode() then return end
    if not overvodka_events then return end

    local state = GameRules:State_Get()
    if state ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        Timers:CreateTimer(0.1, function()
            OvervodkaEvents:Init()
        end)
        return
    end

    self.initialized = true

    self.mapName = GetMapName()
    self.is5x5 = (self.mapName == "overvodka_5x5")

    self.initGameTime = GameRules:GetGameTime()

    self.blockedBombardiro = {}

    self.goldenRainTimes = {}
    self.hamsterTimes    = {}

    self.zhenyaBossActive = false
    self.zhenyaBoss       = nil
    self.zhenyaHamster    = nil
    self.zhenyaEndTime    = nil
    self.heroBossActive   = false
    self.heroBoss         = nil
    self.heroBossEndTime  = nil

    CustomNetTables:SetTableValue("overvodka_events", "golden_rain", { t1 = -1, t2 = -1 })
    CustomNetTables:SetTableValue("overvodka_events", "hamster",     { t1 = -1, t2 = -1 })

    self:ScheduleGoldenRainEvents()
    self:ScheduleHamsterEvents()
    self:ScheduleBombardiroEvents()
end


function OvervodkaEvents:SetBoss( boss )
    if not IsServer() then return end
    if boss and not boss:IsNull() then
        self.hBoss = boss
    end
end

function OvervodkaEvents:GetBoss()
    self.hBoss = Entities:FindByName(nil, "@overboss")

    if self.hBoss and not self.hBoss:IsNull() then
        return self.hBoss
    end

    return nil
end

function OvervodkaEvents:IsMisoloBossEnabled()
    return _G.misolo_boss_enabled == true
end

function OvervodkaEvents:SetActiveHeroBoss(boss, data)
    if not IsServer() or not IsValid(boss) then
        return
    end

    self.heroBossActive = true
    self.heroBoss = boss
    self.heroBossEndTime = data.end_time or (GameRules:GetGameTime() + (data.duration or 70.0))

    local payload = {
        entindex = boss:entindex(),
        end_time = self.heroBossEndTime,
        boss_modifier = data.boss_modifier,
        phase2_modifier = data.phase2_modifier,
        name = data.name,
        avatar = data.avatar,
        avatar_phase2 = data.avatar_phase2,
        theme = data.theme,
    }

    if HeroBossEvent then
        HeroBossEvent:ShowBossUI(payload)
    end

    CustomGameEventManager:Send_ServerToAllClients("zhenya_boss_spawned", payload)
end

function OvervodkaEvents:ClearActiveHeroBoss(boss)
    if not IsServer() then
        return
    end

    if IsValid(boss) and IsValid(self.heroBoss) and self.heroBoss ~= boss then
        return
    end

    self.heroBossActive = false
    self.heroBoss = nil
    self.heroBossEndTime = nil

    if HeroBossEvent then
        HeroBossEvent:ClearBossUI({
            entindex = IsValid(boss) and boss:entindex() or -1,
        })
    end
end

function OvervodkaEvents:LevelMisoloBossAbilities(boss)
    if not IsValid(boss) then
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
        local ability = boss:FindAbilityByName(ability_name)
        if IsValid(ability) and ability:GetLevel() < level then
            ability:SetLevel(level)
        end
    end
end

function OvervodkaEvents:GetMisoloBossPreludePoints(web_radius, count)
    local center = Vector(0, 0, 0)
    local radius_from_center = GetMapName() == "overvodka_5x5" and 2600 or 1800
    local points = {}
    local heroes = {}

    for player_id = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        local hero = PlayerResource:GetSelectedHeroEntity(player_id)
        if IsValid(hero) and hero:IsAlive() and hero:IsRealHero() and not hero:IsIllusion() then
            if (hero:GetAbsOrigin() - center):Length2D() <= radius_from_center + 400 then
                heroes[#heroes + 1] = hero
            end
        end
    end

    if #heroes <= 0 then
        for player_id = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
            local hero = PlayerResource:GetSelectedHeroEntity(player_id)
            if IsValid(hero) and hero:IsAlive() and hero:IsRealHero() and not hero:IsIllusion() then
                heroes[#heroes + 1] = hero
            end
        end
    end

    local min_distance = math.max(web_radius * 0.8, 450)
    local attempts = 0

    while #points < count and attempts < 80 do
        attempts = attempts + 1

        local point = center + RandomVector(RandomFloat(250, radius_from_center))
        local anchor = #heroes > 0 and heroes[RandomInt(1, #heroes)] or nil
        if IsValid(anchor) then
            point = anchor:GetAbsOrigin() + RandomVector(RandomFloat(web_radius * 0.2, web_radius * 0.7))

            local offset = point - center
            offset.z = 0
            if offset:Length2D() > radius_from_center then
                point = center + offset:Normalized() * radius_from_center
            end
        end

        point = GetGroundPosition(point, nil)

        if GridNav:IsTraversable(point) and not GridNav:IsBlocked(point) then
            local can_use = true
            for _, existing in ipairs(points) do
                if (existing - point):Length2D() < min_distance then
                    can_use = false
                    break
                end
            end

            if can_use then
                points[#points + 1] = point
            end
        end
    end

    while #points < count do
        points[#points + 1] = GetGroundPosition(center + RandomVector(RandomFloat(250, radius_from_center)), nil)
    end

    return points
end

function OvervodkaEvents:StartMisoloBossEvent()
    if not IsServer() or self.heroBossActive then
        return
    end

    local center = Vector(0, 0, 0)
    local spawn_distance = GetMapName() == "overvodka_5x5" and 7000 or 5000
    local spawn_direction = RandomVector(spawn_distance)
    local spawn_position = GetGroundPosition(center + spawn_direction, nil)
    local duration = 70.0

    _G.global_sounds_muted = true
    Timers:CreateTimer(duration, function()
        _G.global_sounds_muted = false
    end)

    local boss = CreateUnitByName(
        "npc_misolo_boss",
        spawn_position,
        true,
        nil,
        nil,
        DOTA_TEAM_NEUTRALS
    )

    if not IsValid(boss) then
        print("[OvervodkaEvents] Failed to spawn npc_misolo_boss")
        _G.global_sounds_muted = false
        self:ClearActiveHeroBoss()
        return
    end

    self:LevelMisoloBossAbilities(boss)
    boss:AddNewModifier(boss, nil, "modifier_misolo_boss", {
        duration = duration,
        intro_x = center.x,
        intro_y = center.y,
        intro_z = center.z,
    })

    self:SetActiveHeroBoss(boss, {
        duration = duration,
        boss_modifier = "modifier_misolo_boss",
        phase2_modifier = "modifier_misolo_boss_phase2",
        name = "#npc_misolo_boss",
        avatar = "file://{images}/custom_game/misolo_boss_avatar.png",
        avatar_phase2 = "file://{images}/custom_game/misolo_boss_avatar_angry.png",
        theme = "bloody",
    })

    local web_ability = boss:FindAbilityByName("misolo_w")
    if IsValid(web_ability) and web_ability.CreateWebAtPoint then
        local points = self:GetMisoloBossPreludePoints(web_ability:GetSpecialValueFor("web_radius"), 5)
        for i, point in ipairs(points) do
            Timers:CreateTimer((i - 1) * 0.18, function()
                if self.heroBoss ~= boss or not IsValid(boss, web_ability) or not boss:IsAlive() then
                    return
                end

                web_ability:CreateWebAtPoint(point)
            end)
        end
    end
end

--------------------------------------------------------------------
-- Golden Rain
--------------------------------------------------------------------

function OvervodkaEvents:ScheduleGoldenRainEvents()
    local windows = self.is5x5 and GOLDEN_RAIN_WINDOWS.overvodka_5x5 or GOLDEN_RAIN_WINDOWS.default

    for i, window in ipairs(windows) do
        local tMin = window[1] * 60.0
        local tMax = window[2] * 60.0

        local announceOffset = RandomFloat(tMin, tMax)

        local startOffset = announceOffset + 15.0
        local absoluteStart = self.initGameTime + startOffset

        local level = i

        self:AddBombardiroBlock(absoluteStart - 15.0, absoluteStart + 45.0)

        self.goldenRainTimes[i] = absoluteStart
        self:UpdateNetTableForEvent("golden_rain", self.goldenRainTimes)

        Timers:CreateTimer(announceOffset, function()
            self:TriggerGoldenRain(level)
        end)
    end
end

function OvervodkaEvents:TriggerGoldenRain( level )
    if not IsServer() then return end
    if not overvodka_events then return end
    local boss = self:GetBoss()
    if not boss then
        print("[OvervodkaEvents] Golden Rain: boss not found")
        return
    end

    CustomGameEventManager:Send_ServerToAllClients( "golden_rain_announce", {} )
    EmitGlobalSound( "golden_rain_announce" )

    Timers:CreateTimer(15.0, function()
        if not boss or boss:IsNull() then return end

        CustomGameEventManager:Send_ServerToAllClients( "golden_rain_start", {} )

        local ability = boss:FindAbilityByName( GOLDEN_RAIN_ABILITY_NAME )
        if not ability then
            boss:AddAbility( GOLDEN_RAIN_ABILITY_NAME )
            ability = boss:FindAbilityByName( GOLDEN_RAIN_ABILITY_NAME )
        end

        if ability then
            ability:SetLevel( level )
            boss:CastAbilityNoTarget( ability, -1 )
        else
            print("[OvervodkaEvents] Golden Rain: ability not found: " .. GOLDEN_RAIN_ABILITY_NAME)
        end
    end)
end

--------------------------------------------------------------------
-- Hamster
--------------------------------------------------------------------

function OvervodkaEvents:ScheduleHamsterEvents()
    local windows = self.is5x5 and HAMSTER_WINDOWS.overvodka_5x5 or HAMSTER_WINDOWS.default

    for i, window in ipairs(windows) do
        local tMin = window[1] * 60.0
        local tMax = window[2] * 60.0

        local announceOffset = RandomFloat(tMin, tMax)

        local startOffset = announceOffset + 15.0
        local absoluteStart = self.initGameTime + startOffset

        self:AddBombardiroBlock(absoluteStart - 15.0, absoluteStart + 30.0)

        self.hamsterTimes[i] = absoluteStart
        self:UpdateNetTableForEvent("hamster", self.hamsterTimes)

        Timers:CreateTimer(announceOffset, function()
            self:TriggerHamster()
        end)
    end
end

function OvervodkaEvents:TriggerHamster()
    if not IsServer() then return end
    if not overvodka_events then return end
    CustomGameEventManager:Send_ServerToAllClients("item_has_spawned", {})
    if self:IsMisoloBossEnabled() or not winter_mode then
        EmitGlobalSound("hamster_announce")
    else
        EmitGlobalSound("zhenya_announce")
    end

    Timers:CreateTimer(15.0, function()
        if self:IsMisoloBossEnabled() then
            StopGlobalSound("misolo_start")
            EmitGlobalSound("misolo_start")
            self:StartMisoloBossEvent()
            return
        end

        if SpawnHamster then
            local hamster = SpawnHamster()

            if hamster and not hamster:IsNull() then
                if OvervodkaEvents and OvervodkaEvents.StartZhenyaBoss and winter_mode then
                    OvervodkaEvents:StartZhenyaBoss(hamster)
                end
            else
                print("[OvervodkaEvents] SpawnHamster() returned nil")
            end
        else
            print("[OvervodkaEvents] SpawnHamster() is nil")
        end
    end)
end

function OvervodkaEvents:StartZhenyaBoss(hamster)
    if not IsServer() then return end
    if not hamster or hamster:IsNull() then
        print("[OvervodkaEvents] StartZhenyaBoss: hamster is nil")
        return
    end

    if self.zhenyaBossActive then
        return
    end

    self.zhenyaHamster    = hamster
    self.zhenyaBossActive = true

    self.zhenyaEndTime = GameRules:GetGameTime() + 70.0

    _G.global_sounds_muted = true
    self:SpawnZhenyaBoss()
    Timers:CreateTimer(70.0, function()
        _G.global_sounds_muted = false
    end)
end

function OvervodkaEvents:SpawnZhenyaBoss()
    if not IsServer() then return end

    if not self.zhenyaHamster or self.zhenyaHamster:IsNull() then
        print("[OvervodkaEvents] SpawnZhenyaBoss: hamster is nil, abort")
        self.zhenyaBossActive = false
        return
    end

    if self.zhenyaBoss and not self.zhenyaBoss:IsNull() and self.zhenyaBoss:IsAlive() then
        return
    end

    local basePos = self.zhenyaHamster:GetAbsOrigin()
    local distance = 5000
    local angle = RandomFloat(0, 2*math.pi)
    local spawnPos = basePos + Vector(math.cos(angle), math.sin(angle), 0) * distance
    spawnPos = GetGroundPosition(spawnPos, nil)

    local boss = CreateUnitByName(
        "npc_zhenya_boss",
        spawnPos,
        true,
        nil,
        nil,
        DOTA_TEAM_NEUTRALS
    )

    if not boss or boss:IsNull() then
        print("[OvervodkaEvents] Failed to spawn npc_zhenya_boss")
        self.zhenyaBossActive = false
        return
    end

    self.zhenyaBoss = boss

    boss:AddNewModifier(boss, nil, "modifier_zhenya_boss", {duration = 70})

    boss.zhenyaHamster = self.zhenyaHamster

    _G.ZhenyaBoss = boss

    CustomGameEventManager:Send_ServerToAllClients("zhenya_boss_spawned", {
        entindex = boss:entindex(),
        end_time = self.zhenyaEndTime or 0,
    })

    if HeroBossEvent then
        HeroBossEvent:ShowBossUI({
            entindex = boss:entindex(),
            end_time = self.zhenyaEndTime or 0,
            boss_modifier = "modifier_zhenya_boss",
            phase2_modifier = "modifier_zhenya_boss_phase2",
            name = "#npc_zhenya_boss",
            avatar = "file://{images}/custom_game/zhenya_boss_avatar.png",
            avatar_phase2 = "file://{images}/custom_game/zhenya_boss_avatar_angry.png",
        })
    end
end



--------------------------------------------------------------------
-- Bombardiro
--------------------------------------------------------------------

function OvervodkaEvents:ScheduleBombardiroEvents()
    local maxAttempts = 10

    for minute = BOMBARDIRO_FIRST_MINUTE, BOMBARDIRO_LAST_MINUTE, 2 do
        local offsetMin = minute * 60.0
        local offsetMax = (minute + 1) * 60.0

        local chosenOffset = nil

        for _ = 1, maxAttempts do
            local candidateOffset = RandomFloat(offsetMin, offsetMax)
            local candidateGameTime = self.initGameTime + candidateOffset

            if not self:IsGameTimeBlockedForBombardiro(candidateGameTime) then
                chosenOffset = candidateOffset
                break
            end
        end

        if chosenOffset then
            Timers:CreateTimer(chosenOffset, function()
                self:TriggerBombardiro()
            end)
        else
            print("[OvervodkaEvents] Bombardiro window fully blocked at minutes " .. tostring(minute) .. "-" .. tostring(minute + 1))
        end
    end
end

function OvervodkaEvents:TriggerBombardiro()
    if not IsServer() then return end
    if not overvodka_events then return end
    local now = GameRules:GetGameTime()

    local minAllowedTime = (self.initGameTime or 0) + BOMBARDIRO_FIRST_MINUTE * 60.0
    if now < minAllowedTime then
        return
    end

    if self:IsGameTimeBlockedForBombardiro(now) then
        return
    end

    if SpawnBombardiro then
        SpawnBombardiro()
    else
        print("[OvervodkaEvents] SpawnBombardiro() is nil")
    end
end

if not OvervodkaEvents.initialized then OvervodkaEvents:Init() end
