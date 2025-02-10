if MusicZoneTrigger == nil then
    MusicZoneTrigger = class({})
end

local MUSIC_ZONE_CENTER = Vector(2240, -3136, 137)
local MUSIC_ZONE_RADIUS = 400
local MUSIC_SOUND = "babulka"

function MusicZoneTrigger:Init()
    if GameRules:GetGameModeEntity() == nil then
        return
    end
    PrecacheResource( "soundfile", "soundevents/babulka.vsndevts", context ) 
    ListenToGameEvent("npc_spawned", Dynamic_Wrap(MusicZoneTrigger, "OnNPCSpawned"), self)
    self:StartThinker()
end

function MusicZoneTrigger:OnNPCSpawned(event)
    local spawnedUnit = EntIndexToHScript(event.entindex)
    if spawnedUnit and spawnedUnit:IsRealHero() and spawnedUnit:IsControllableByAnyPlayer() then
        spawnedUnit.musicZoneActive = false
    end
end

function MusicZoneTrigger:StartThinker()
    local gameMode = GameRules:GetGameModeEntity()
    if gameMode then
        gameMode:SetThink("Think", self, 0.1)
    end
end

function MusicZoneTrigger:Think()
    local heroes = HeroList:GetAllHeroes()
    for _, hero in pairs(heroes) do
        if hero:IsAlive() then
            local distance = (hero:GetAbsOrigin() - MUSIC_ZONE_CENTER):Length2D()
            if distance <= MUSIC_ZONE_RADIUS then
                if not hero.musicZoneActive then
                    hero.musicZoneActive = true
                    EmitSoundOnLocationForAllies(hero:GetAbsOrigin(), MUSIC_SOUND, hero)
                end
            else
                if hero.musicZoneActive then
                    hero.musicZoneActive = false
                    hero:StopSound(MUSIC_SOUND)
                end
            end
        end
    end
    return 0.1
end
