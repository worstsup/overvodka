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
        { 0.4, 0.5 }, -- 11 12.5
    },
    overvodka_5x5 = {
        { 16, 18 },
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
    --if IsInToolsMode() then return end

    if _G.overvodka_events ~= nil and not _G.overvodka_events then
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

    CustomGameEventManager:Send_ServerToAllClients("item_has_spawned", {})
    if not winter_mode then
        EmitGlobalSound("hamster_announce")
    else
        EmitGlobalSound("zhenya_announce")
    end

    Timers:CreateTimer(15.0, function()
        if SpawnHamster then
            local hamster = SpawnHamster()

            if hamster and not hamster:IsNull() then
                if OvervodkaEvents and OvervodkaEvents.StartZhenyaBoss then
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