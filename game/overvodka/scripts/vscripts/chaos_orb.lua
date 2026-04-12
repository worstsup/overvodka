if not ChaosOrb then
    ChaosOrb = class({})
end

local CHAOS_ORB_SELECTION_DURATION = 10
local CHAOS_ORB_FORCE_GRACE = 12
local CHAOS_ORB_THIRD_ORB_CHANCE = 50
local CHAOS_ORB_SELECTION_SOUNDS = {
    "Hero_Terrorblade.Metamorphosis.Scepter",
    "Hero_Terrorblade.Sunder.Target",
    "ui.set_applied",
}
local CHAOS_ORB_WINDOWS = {
    { 5 * 60, 10 * 60 },
    { 10 * 60, 15 * 60 },
    { 15 * 60, 20 * 60 },
}

local CHAOS_METEOR_DURATION = 10
local CHAOS_METEOR_SPAWN_INTERVAL = 0.4
local CHAOS_METEOR_LAND_TIME = 1.3
local CHAOS_METEOR_RADIUS = 275
local CHAOS_METEOR_TRAVEL_DISTANCE = 700
local CHAOS_METEOR_TRAVEL_SPEED = 650
local CHAOS_METEOR_VISION = 200
local CHAOS_METEOR_END_VISION_DURATION = 3
local CHAOS_METEOR_DAMAGE_INTERVAL = 0.5
local CHAOS_METEOR_BURN_DURATION = 3.0
local CHAOS_METEOR_IMPACT_DAMAGE_PCT = 20
local CHAOS_METEOR_BURN_DAMAGE_PCT = 8
local CHAOS_SWAP_SEQUENCE_COUNT = 10
local CHAOS_SWAP_SEQUENCE_INTERVAL = 0.4

local CHAOS_DEATH_EXPLOSION_RADIUS = 400
local CHAOS_DEATH_EXPLOSION_DAMAGE = 350
local CHAOS_COIN_HEAL = 300

local ALL_PRIMARY_ATTRIBUTES = {
    DOTA_ATTRIBUTE_STRENGTH,
    DOTA_ATTRIBUTE_AGILITY,
    DOTA_ATTRIBUTE_INTELLECT,
    DOTA_ATTRIBUTE_ALL,
}

local CHAOS_EFFECT_ORDER = {
    "reflect", --1
    "cooldown", --2
    "mana_amp", --3
    "gold_steal", --4
    "gold_heal", --5
    "attack_range", --6
    "eternal_night", --7
    "turbo_mode", --8
    "backpack_items", --9
    "death_lesh", --10
    "attribute_chips", --11
    "double_chest", --12
    "bombardiro_execute", --13
    "global_doom", --14
    "death_explosion", --15
    "hero_swap",--16
    "meteor_rain", --17
    "random_primary", --18
}

local CHAOS_EFFECTS = {
    reflect = {
        title_key = "#CHAOS_EFFECT_REFLECT_TITLE",
        desc_key = "#CHAOS_EFFECT_REFLECT_DESC",
        summary_key = "#CHAOS_EFFECT_REFLECT_SUMMARY",
        modifier = "modifier_chaos_reflect",
        persistent = true,
    },
    cooldown = {
        title_key = "#CHAOS_EFFECT_COOLDOWN_TITLE",
        desc_key = "#CHAOS_EFFECT_COOLDOWN_DESC",
        summary_key = "#CHAOS_EFFECT_COOLDOWN_SUMMARY",
        modifier = "modifier_chaos_cooldown",
        persistent = true,
    },
    mana_amp = {
        title_key = "#CHAOS_EFFECT_MANA_AMP_TITLE",
        desc_key = "#CHAOS_EFFECT_MANA_AMP_DESC",
        summary_key = "#CHAOS_EFFECT_MANA_AMP_SUMMARY",
        modifier = "modifier_chaos_spell_surge",
        persistent = true,
    },
    gold_steal = {
        title_key = "#CHAOS_EFFECT_GOLD_STEAL_TITLE",
        desc_key = "#CHAOS_EFFECT_GOLD_STEAL_DESC",
        summary_key = "#CHAOS_EFFECT_GOLD_STEAL_SUMMARY",
        modifier = "modifier_chaos_gold_steal",
        persistent = true,
    },
    gold_heal = {
        title_key = "#CHAOS_EFFECT_GOLD_HEAL_TITLE",
        desc_key = "#CHAOS_EFFECT_GOLD_HEAL_DESC",
        summary_key = "#CHAOS_EFFECT_GOLD_HEAL_SUMMARY",
        persistent = true,
    },
    attack_range = {
        title_key = "#CHAOS_EFFECT_ATTACK_RANGE_TITLE",
        desc_key = "#CHAOS_EFFECT_ATTACK_RANGE_DESC",
        summary_key = "#CHAOS_EFFECT_ATTACK_RANGE_SUMMARY",
        modifier = "modifier_chaos_attack_range",
        persistent = true,
    },
    eternal_night = {
        title_key = "#CHAOS_EFFECT_ETERNAL_NIGHT_TITLE",
        desc_key = "#CHAOS_EFFECT_ETERNAL_NIGHT_DESC",
        summary_key = "#CHAOS_EFFECT_ETERNAL_NIGHT_SUMMARY",
        persistent = true,
    },
    turbo_mode = {
        title_key = "#CHAOS_EFFECT_TURBO_MODE_TITLE",
        desc_key = "#CHAOS_EFFECT_TURBO_MODE_DESC",
        summary_key = "#CHAOS_EFFECT_TURBO_MODE_SUMMARY",
        persistent = true,
    },
    backpack_items = {
        title_key = "#CHAOS_EFFECT_BACKPACK_TITLE",
        desc_key = "#CHAOS_EFFECT_BACKPACK_DESC",
        summary_key = "#CHAOS_EFFECT_BACKPACK_SUMMARY",
        modifier = "modifier_chaos_backpack",
        persistent = true,
    },
    death_lesh = {
        title_key = "#CHAOS_EFFECT_DEATH_LESH_TITLE",
        desc_key = "#CHAOS_EFFECT_DEATH_LESH_DESC",
        summary_key = "#CHAOS_EFFECT_DEATH_LESH_SUMMARY",
        persistent = true,
    },
    attribute_chips = {
        title_key = "#CHAOS_EFFECT_ATTRIBUTE_CHIPS_TITLE",
        desc_key = "#CHAOS_EFFECT_ATTRIBUTE_CHIPS_DESC",
        summary_key = "#CHAOS_EFFECT_ATTRIBUTE_CHIPS_SUMMARY",
    },
    double_chest = {
        title_key = "#CHAOS_EFFECT_DOUBLE_CHEST_TITLE",
        desc_key = "#CHAOS_EFFECT_DOUBLE_CHEST_DESC",
        summary_key = "#CHAOS_EFFECT_DOUBLE_CHEST_SUMMARY",
        persistent = true,
    },
    bombardiro_execute = {
        title_key = "#CHAOS_EFFECT_BOMBARDIRO_TITLE",
        desc_key = "#CHAOS_EFFECT_BOMBARDIRO_DESC",
        summary_key = "#CHAOS_EFFECT_BOMBARDIRO_SUMMARY",
        persistent = true,
    },
    global_doom = {
        title_key = "#CHAOS_EFFECT_GLOBAL_DOOM_TITLE",
        desc_key = "#CHAOS_EFFECT_GLOBAL_DOOM_DESC",
        summary_key = "#CHAOS_EFFECT_GLOBAL_DOOM_SUMMARY",
    },
    death_explosion = {
        title_key = "#CHAOS_EFFECT_DEATH_EXPLOSION_TITLE",
        desc_key = "#CHAOS_EFFECT_DEATH_EXPLOSION_DESC",
        summary_key = "#CHAOS_EFFECT_DEATH_EXPLOSION_SUMMARY",
        persistent = true,
    },
    hero_swap = {
        title_key = "#CHAOS_EFFECT_SWAP_TITLE",
        desc_key = "#CHAOS_EFFECT_SWAP_DESC",
        summary_key = "#CHAOS_EFFECT_SWAP_SUMMARY",
    },
    meteor_rain = {
        title_key = "#CHAOS_EFFECT_METEOR_TITLE",
        desc_key = "#CHAOS_EFFECT_METEOR_DESC",
        summary_key = "#CHAOS_EFFECT_METEOR_SUMMARY",
    },
    random_primary = {
        title_key = "#CHAOS_EFFECT_PRIMARY_TITLE",
        desc_key = "#CHAOS_EFFECT_PRIMARY_DESC",
        summary_key = "#CHAOS_EFFECT_PRIMARY_SUMMARY",
        persistent = true,
    },
}

function ChaosOrb:Init(gameMode)
    if not IsServer() then return end

    self.gameMode = gameMode or self.gameMode
    if self.initialized then return end

    self.initialized = true
    self.history = {}
    self.activeEffects = {}
    self.selection = nil
    self.selectionSeq = 0
    self.primaryAttributesByPlayerID = {}
    self.availableEffects = {}

    for _, effectID in ipairs(CHAOS_EFFECT_ORDER) do
        table.insert(self.availableEffects, effectID)
    end

    self.totalScheduledOrbs = 2
    if RandomInt(1, 100) <= CHAOS_ORB_THIRD_ORB_CHANCE then
        self.totalScheduledOrbs = 3
    end
    self.reservedOrbDrops = 0
    self.orbSpawnTimes = self:BuildOrbSpawnSchedule(self.totalScheduledOrbs)

    CustomNetTables:SetTableValue("chaos", "history", { count = 0, seq = 0 })

    CustomGameEventManager:RegisterListener("chaos_pick_card", function(_, event)
        self:OnPickCard(event)
    end)
end

function ChaosOrb:BuildOrbSpawnSchedule(totalCount)
    local times = {}

    for i = 1, totalCount do
        if IsInToolsMode() and i == 1 then
            times[i] = 10
        else
        local window = CHAOS_ORB_WINDOWS[i]
            times[i] = RandomFloat(window[1], window[2])
        end
    end

    table.sort(times, function(a, b)
        return a < b
    end)

    return times
end

function ChaosOrb:GetGameTime()
    return math.max(GameRules:GetDOTATime(false, false), 0)
end

function ChaosOrb:GetNextOrbTime()
    return self.orbSpawnTimes and self.orbSpawnTimes[self.reservedOrbDrops + 1] or nil
end

function ChaosOrb:ShouldReplaceNextMidDrop()
    if not self.initialized then return false end
    if self.selection then return false end

    local nextTime = self:GetNextOrbTime()
    if not nextTime then return false end

    return self:GetGameTime() >= nextTime
end

function ChaosOrb:ShouldForceMidDrop()
    if not self.initialized then return false end
    if self.selection then return false end

    local nextTime = self:GetNextOrbTime()
    if not nextTime then return false end

    local grace = IsInToolsMode() and 0 or CHAOS_ORB_FORCE_GRACE
    return self:GetGameTime() >= (nextTime + grace)
end

function ChaosOrb:ReserveNextMidDrop()
    local nextTime = self:GetNextOrbTime()
    if not nextTime then
        return false
    end

    self.reservedOrbDrops = self.reservedOrbDrops + 1
    return true
end

function ChaosOrb:IsEffectActive(effectID)
    return self.activeEffects and self.activeEffects[effectID] == true
end

function ChaosOrb:GetEffectIDByDebugIndex(index)
    if index == nil then return nil end
    return CHAOS_EFFECT_ORDER[index]
end

function ChaosOrb:ForceSpawnOrb(spawnPoint)
    if not self.gameMode or not self.gameMode.SpawnChaosOrbEntity then return false end

    self.gameMode:SpawnChaosOrbEntity(spawnPoint or Vector(0, 0, 0), false)
    return true
end

function ChaosOrb:DebugApplyEffectByIndex(index, playerID)
    if not self.initialized then
        return false, "Chaos Orb is not initialized"
    end

    if self.selection then
        return false, "Finish the current Chaos selection first"
    end

    local effectID = self:GetEffectIDByDebugIndex(index)
    if not effectID or not CHAOS_EFFECTS[effectID] then
        return false, "Unknown Chaos Orb index: " .. tostring(index)
    end

    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    if not hero or hero:IsNull() or not IsRealHero(hero) then
        return false, "Pick a real hero first"
    end

    self:PlayChosenParticle()
    self:PlaySelectionSound(effectID)
    self:ApplyEffect(effectID, playerID, hero:entindex())

    return true, effectID
end

function ChaosOrb:OnPlayerDisconnected(playerID)
    if not self.selection then return end
    if self.selection.playerID ~= playerID then return end

    self:ResolveSelection(nil)
end

function ChaosOrb:OnHeroSpawned(hero)
    if not self.initialized then return end
    if not IsRealHero(hero) then return end

    self:ApplyPersistentEffectsToHero(hero)
end

function ChaosOrb:ApplyPersistentEffectsToHero(hero)
    if not hero or hero:IsNull() then return end

    for effectID, effectData in pairs(CHAOS_EFFECTS) do
        if effectData.modifier and self:IsEffectActive(effectID) and not hero:HasModifier(effectData.modifier) then
            hero:AddNewModifier(hero, nil, effectData.modifier, {})
        end
    end

    if self:IsEffectActive("random_primary") then
        local playerID = hero:GetPlayerID()
        local newAttribute = self.primaryAttributesByPlayerID[playerID]
        if newAttribute ~= nil then
            hero:SetPrimaryAttribute(newAttribute)
        end
    end
end

function ChaosOrb:BeginSelection(hero)
    if not self.initialized then return false end
    if self.selection then return false end
    if not hero or hero:IsNull() or not IsRealHero(hero) then return false end

    local playerID = hero:GetPlayerID()
    if playerID == nil or playerID == -1 then return false end

    local cards = self:RollSelectionCards()
    if #cards == 0 then return false end

    self.selectionSeq = self.selectionSeq + 1
    self.selection = {
        seq = self.selectionSeq,
        playerID = playerID,
        heroEntIndex = hero:entindex(),
        cards = cards,
        endTime = GameRules:GetGameTime() + CHAOS_ORB_SELECTION_DURATION,
    }

    hero:Interrupt()
    hero:Stop()
    hero:SetForceAttackTarget(nil)
    hero:SetForceAttackTargetAlly(nil)
    hero:AddNewModifier(hero, nil, "modifier_chaos_orb_selection", { duration = CHAOS_ORB_SELECTION_DURATION })

    self:UpdateSelectionNetTable(playerID)
    CustomGameEventManager:Send_ServerToAllClients("chaos_orb_picked_announce", {
        player_id = playerID,
        hero_entindex = hero:entindex(),
    })
    EmitGlobalSound("ORBS.Open")

    local selectionSeq = self.selection.seq
    Timers:CreateTimer(CHAOS_ORB_SELECTION_DURATION, function()
        if self.selection and self.selection.seq == selectionSeq then
            self:ResolveSelection(nil)
        end
    end)

    return true
end

function ChaosOrb:RollSelectionCards()
    if not self.availableEffects or #self.availableEffects == 0 then
        return {}
    end

    local shuffled = ShuffledList(self.availableEffects)
    local cards = {}
    local maxCards = math.min(3, #shuffled)

    for index = 1, maxCards do
        table.insert(cards, shuffled[index])
    end

    return cards
end

function ChaosOrb:OnPickCard(event)
    if not self.selection then return end
    if not event then return end

    local playerID = event.PlayerID
    if playerID ~= self.selection.playerID then return end

    self:ResolveSelection(event.effect_id)
end

function ChaosOrb:ResolveSelection(effectID)
    if not self.selection then return end

    local currentSelection = self.selection
    local chosenEffect = effectID

    if not self:IsCardOffered(chosenEffect) then
        chosenEffect = currentSelection.cards[RandomInt(1, #currentSelection.cards)]
    end

    local hero = EntIndexToHScript(currentSelection.heroEntIndex)
    if hero and not hero:IsNull() then
        hero:RemoveModifierByName("modifier_chaos_orb_selection")
        FindClearSpaceForUnit(hero, hero:GetAbsOrigin(), true)
    end

    self:PlayChosenParticle()

    self.selection = nil
    self:ClearSelectionNetTable(currentSelection.playerID)
    self:PlaySelectionSound(chosenEffect)

    self:ApplyEffect(chosenEffect, currentSelection.playerID, currentSelection.heroEntIndex)
end

function ChaosOrb:PlayChosenParticle()
    local heroes = HeroList:GetAllHeroes()
    for _, hero in ipairs(heroes) do
        if IsRealHero(hero) then
            local p = ParticleManager:CreateParticle("particles/orb_chosen.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:SetParticleControlEnt(p, 0, hero, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
            ParticleManager:SetParticleControlEnt(p, 4, hero, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
            ParticleManager:ReleaseParticleIndex(p)
        end
    end
end

function ChaosOrb:PlaySelectionSound(effectID)
    if effectID == "global_doom" then
        EmitGlobalSound("ORBS.Doom")
        return
    end

    EmitGlobalSound(CHAOS_ORB_SELECTION_SOUNDS[RandomInt(1, #CHAOS_ORB_SELECTION_SOUNDS)])
end

function ChaosOrb:IsCardOffered(effectID)
    if not effectID or not self.selection then return false end

    for _, cardID in ipairs(self.selection.cards) do
        if cardID == effectID then
            return true
        end
    end

    return false
end

function ChaosOrb:ApplyEffect(effectID, playerID, sourceHeroEntIndex)
    local effectData = CHAOS_EFFECTS[effectID]
    if not effectData then return end

    if effectData.persistent then
        self.activeEffects[effectID] = true
    end

    if effectData.modifier then
        self:ApplyModifierToAllHeroes(effectData.modifier)
    end

    if effectID == "global_doom" then
        self:ApplyGlobalDoom(sourceHeroEntIndex)
    elseif effectID == "eternal_night" then
        self:ApplyEternalNight()
    elseif effectID == "hero_swap" then
        self:StartHeroSwapSequence()
    elseif effectID == "meteor_rain" then
        self:StartMeteorRain(sourceHeroEntIndex)
    elseif effectID == "random_primary" then
        self:ApplyRandomPrimaryAttributes()
    elseif effectID == "attribute_chips" then
        self:GrantAttributeChipsToAllHeroes()
    end

    self:RemoveEffectFromPool(effectID)
    self:AppendHistory(effectID, playerID)
end

function ChaosOrb:ApplyModifierToAllHeroes(modifierName)
    for _, hero in pairs(HeroList:GetAllHeroes()) do
        if IsRealHero(hero) and not hero:HasModifier(modifierName) then
            hero:AddNewModifier(hero, nil, modifierName, {})
        end
    end
end

function ChaosOrb:ApplyGlobalDoom(excludedHeroEntIndex)
    local caster = EntIndexToHScript(excludedHeroEntIndex)
    local p = ParticleManager:CreateParticle("particles/flash_r_start_immortal.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(p)
    for _, hero in pairs(HeroList:GetAllHeroes()) do
        if IsRealHero(hero) and hero:IsAlive() and hero:entindex() ~= excludedHeroEntIndex then
            hero:AddNewModifier(hero, nil, "modifier_chaos_global_doom", { duration = 10 })
        end
    end
end

function ChaosOrb:ApplyEternalNight()
    local gameModeEntity = GameRules:GetGameModeEntity()
    if gameModeEntity then
        gameModeEntity:SetDaynightCycleDisabled(true)
        gameModeEntity:SetDaynightCycleAdvanceRate(0.0)
    end

    GameRules:SetTimeOfDay(0)

    if self.eternalNightTimerStarted then
        return
    end

    self.eternalNightTimerStarted = true

    Timers:CreateTimer(function()
        if not self:IsEffectActive("eternal_night") then
            self.eternalNightTimerStarted = false
            return nil
        end

        local entity = GameRules:GetGameModeEntity()
        if entity then
            entity:SetDaynightCycleDisabled(true)
            entity:SetDaynightCycleAdvanceRate(0.0)
        end

        GameRules:SetTimeOfDay(0)
        return 0.5
    end)
end

function ChaosOrb:ApplyRandomPrimaryAttributes()
    for _, hero in pairs(HeroList:GetAllHeroes()) do
        if IsRealHero(hero) then
            local currentAttribute = hero.GetPrimaryAttribute and hero:GetPrimaryAttribute() or DOTA_ATTRIBUTE_INVALID
            local availableAttributes = {}

            for _, attribute in ipairs(ALL_PRIMARY_ATTRIBUTES) do
                if attribute ~= currentAttribute then
                    table.insert(availableAttributes, attribute)
                end
            end

            if #availableAttributes > 0 then
                local newAttribute = availableAttributes[RandomInt(1, #availableAttributes)]
                self.primaryAttributesByPlayerID[hero:GetPlayerID()] = newAttribute
                hero:SetPrimaryAttribute(newAttribute)
            end
        end
    end
end

function ChaosOrb:SwapHeroesInPairs()
    local heroes = {}

    for _, hero in pairs(HeroList:GetAllHeroes()) do
        if IsRealHero(hero) and hero:IsAlive() then
            table.insert(heroes, hero)
        end
    end

    heroes = ShuffledList(heroes)

    for index = 1, (#heroes - 1), 2 do
        local firstHero = heroes[index]
        local secondHero = heroes[index + 1]

        if firstHero and secondHero and not firstHero:IsNull() and not secondHero:IsNull() then
            local firstOrigin = GetGroundPosition(firstHero:GetAbsOrigin(), firstHero)
            local secondOrigin = GetGroundPosition(secondHero:GetAbsOrigin(), secondHero)

            self:PlayHeroSwapEffects(firstHero, secondHero)
            FindClearSpaceForUnit(firstHero, secondOrigin, true)
            FindClearSpaceForUnit(secondHero, firstOrigin, true)

            firstHero:Stop()
            secondHero:Stop()
        end
    end
end

function ChaosOrb:StartHeroSwapSequence()
    for swapIndex = 1, CHAOS_SWAP_SEQUENCE_COUNT do
        Timers:CreateTimer((swapIndex - 1) * CHAOS_SWAP_SEQUENCE_INTERVAL, function()
            self:SwapHeroesInPairs()
        end)
    end
end

function ChaosOrb:PlayHeroSwapEffects(hCaster, hTarget)
    if not hCaster or hCaster:IsNull() or not hTarget or hTarget:IsNull() then
        return
    end

    EmitSoundOn("Hero_VengefulSpirit.NetherSwap", hCaster)

    local nCasterFX = ParticleManager:CreateParticle(
        "particles/econ/items/vengeful/vengeful_arcana/vengeful_arcana_nether_swap.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        hCaster
    )
    ParticleManager:SetParticleControlEnt(nCasterFX, 1, hTarget, PATTACH_ABSORIGIN_FOLLOW, nil, hTarget:GetOrigin(), false)
    ParticleManager:ReleaseParticleIndex(nCasterFX)

    local nTargetFX = ParticleManager:CreateParticle(
        "particles/econ/items/vengeful/vengeful_arcana/vengeful_arcana_nether_swap_target.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        hTarget
    )
    ParticleManager:SetParticleControlEnt(nTargetFX, 1, hCaster, PATTACH_ABSORIGIN_FOLLOW, nil, hCaster:GetOrigin(), false)
    ParticleManager:ReleaseParticleIndex(nTargetFX)
end

function ChaosOrb:GetArenaRadius()
    if self.gameMode and self.gameMode.m_GoldRadiusMax then
        return math.max(self.gameMode.m_GoldRadiusMax * 1.15, 900)
    end

    return 1500
end

function ChaosOrb:GetMeteorCaster(sourceHeroEntIndex)
    local sourceHero = sourceHeroEntIndex and EntIndexToHScript(sourceHeroEntIndex) or nil
    if sourceHero and not sourceHero:IsNull() and IsRealHero(sourceHero) then
        return sourceHero
    end

    return nil
end

function ChaosOrb:StartMeteorRain(sourceHeroEntIndex)
    local caster = self:GetMeteorCaster(sourceHeroEntIndex)
    if not caster then
        return
    end

    local arenaRadius = self:GetArenaRadius()
    local meteorCount = math.floor(CHAOS_METEOR_DURATION / CHAOS_METEOR_SPAWN_INTERVAL)

    for meteorIndex = 0, meteorCount do
        Timers:CreateTimer(meteorIndex * CHAOS_METEOR_SPAWN_INTERVAL, function()
            self:SpawnMeteor(Vector(0, 0, 0) + RandomVector(arenaRadius), caster)
        end)
    end
end

function ChaosOrb:SpawnMeteor(point, caster)
    if not caster or caster:IsNull() then
        return
    end

    local groundPoint = GetGroundPosition(point, nil)
    local direction = RandomVector(1)
    direction.z = 0
    direction = direction:Normalized()
    local startOrigin = groundPoint - direction * 320

    CreateModifierThinker(
        caster,
        nil,
        "modifier_chaos_meteor_thinker",
        {
            dir_x = direction.x,
            dir_y = direction.y,
            dir_z = direction.z,
            start_x = startOrigin.x,
            start_y = startOrigin.y,
            start_z = startOrigin.z,
            land_time = CHAOS_METEOR_LAND_TIME,
            radius = CHAOS_METEOR_RADIUS,
            distance = CHAOS_METEOR_TRAVEL_DISTANCE,
            speed = CHAOS_METEOR_TRAVEL_SPEED,
            vision = CHAOS_METEOR_VISION,
            vision_duration = CHAOS_METEOR_END_VISION_DURATION,
            interval = CHAOS_METEOR_DAMAGE_INTERVAL,
            burn_duration = CHAOS_METEOR_BURN_DURATION,
            impact_damage_pct = CHAOS_METEOR_IMPACT_DAMAGE_PCT,
            burn_damage_pct = CHAOS_METEOR_BURN_DAMAGE_PCT,
        },
        groundPoint,
        caster:GetTeamNumber(),
        false
    )
end

function ChaosOrb:OnGoldPickup(hero)
    if not self:IsEffectActive("gold_heal") then return end
    if not hero or hero:IsNull() or not hero:IsAlive() then return end

    hero:Heal(CHAOS_COIN_HEAL, nil)
    SendOverheadEventMessage(hero, OVERHEAD_ALERT_HEAL, hero, CHAOS_COIN_HEAL, nil)
end

function ChaosOrb:OnHeroKilled(killedHero, attacker)
    if self:IsEffectActive("death_lesh") then
        self:GrantDeathLesh(killedHero)
    end

    if not self:IsEffectActive("death_explosion") then return end
    if not killedHero or killedHero:IsNull() then return end

    local origin = killedHero:GetAbsOrigin()

    local impactFx = ParticleManager:CreateParticle("particles/alchemist_smooth_criminal_unstable_concoction_explosion_fire_dark_new.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(impactFx, 3, origin)
    ParticleManager:ReleaseParticleIndex(impactFx)

    EmitSoundOnLocationWithCaster(origin, "Hero_Techies.StickyBomb.Detonate", killedHero)

    local enemies = FindUnitsInRadius(
        killedHero:GetTeamNumber(),
        origin,
        nil,
        CHAOS_DEATH_EXPLOSION_RADIUS,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in pairs(enemies) do
        if enemy and not enemy:IsNull() and enemy ~= killedHero and not enemy:IsInvulnerable() and not enemy:IsOutOfGame() then
            ApplyDamage({
                victim = enemy,
                attacker = killedHero,
                damage = CHAOS_DEATH_EXPLOSION_DAMAGE,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = nil,
            })
        end
    end
end

function ChaosOrb:GrantDeathLesh(hero)
    if not hero or hero:IsNull() or not IsRealHero(hero) then return end

    local item = hero:AddItemByName("item_lesh")
    if item then
        item:SetPurchaseTime(0)
        return
    end

    local createdItem = CreateItem("item_lesh", hero, hero)
    if not createdItem then
        return
    end

    createdItem:SetPurchaseTime(0)
    CreateItemOnPositionSync(hero:GetAbsOrigin(), createdItem)
end

function ChaosOrb:GrantAttributeChipsToAllHeroes()
    for _, hero in pairs(HeroList:GetAllHeroes()) do
        if IsRealHero(hero) then
            self:GrantAttributeChips(hero)
        end
    end
end

function ChaosOrb:GrantAttributeChips(hero)
    if not hero or hero:IsNull() or not IsRealHero(hero) then return end

    local primaryAttribute = hero.GetPrimaryAttribute and hero:GetPrimaryAttribute() or DOTA_ATTRIBUTE_INVALID

    if primaryAttribute == DOTA_ATTRIBUTE_STRENGTH then
        self:GiveChargedItem(hero, "item_red_chips", 3)
        return
    end

    if primaryAttribute == DOTA_ATTRIBUTE_AGILITY then
        self:GiveChargedItem(hero, "item_green_chips", 3)
        return
    end

    if primaryAttribute == DOTA_ATTRIBUTE_INTELLECT then
        self:GiveChargedItem(hero, "item_blue_chips", 3)
        return
    end

    self:GiveChargedItem(hero, "item_red_chips", 1)
    self:GiveChargedItem(hero, "item_green_chips", 1)
    self:GiveChargedItem(hero, "item_blue_chips", 1)
end

function ChaosOrb:GiveChargedItem(hero, itemName, charges)
    if not hero or hero:IsNull() or charges == nil or charges <= 0 then return end

    local existingItem = hero:FindItemInInventory(itemName)
    if existingItem and not existingItem:IsNull() then
        existingItem:SetCurrentCharges((existingItem:GetCurrentCharges() or 0) + charges)
        existingItem:SetPurchaseTime(0)
        return
    end

    local createdItem = CreateItem(itemName, hero, hero)
    if not createdItem then
        return
    end

    createdItem:SetPurchaseTime(0)
    createdItem:SetCurrentCharges(charges)

    if self:IsInventoryAndBackpackFull(hero) then
        CreateItemOnPositionSync(hero:GetAbsOrigin(), createdItem)
        return
    end

    hero:AddItem(createdItem)
end

function ChaosOrb:IsInventoryAndBackpackFull(hero)
    if not hero or hero:IsNull() then return false end

    for slot = 0, 8 do
        if hero:GetItemInSlot(slot) == nil then
            return false
        end
    end

    return true
end

function ChaosOrb:RemoveEffectFromPool(effectID)
    for index = #self.availableEffects, 1, -1 do
        if self.availableEffects[index] == effectID then
            table.remove(self.availableEffects, index)
            break
        end
    end
end

function ChaosOrb:AppendHistory(effectID, playerID)
    local effectData = CHAOS_EFFECTS[effectID]
    if not effectData then return end

    table.insert(self.history, 1, {
        effect_id = effectID,
        player_id = playerID,
        title_key = effectData.title_key,
        summary_key = effectData.summary_key,
        time = self:GetGameTime(),
    })

    local payload = {
        count = #self.history,
        seq = self.selectionSeq,
    }

    for index, entry in ipairs(self.history) do
        payload["entry_" .. index] = entry
    end

    CustomNetTables:SetTableValue("chaos", "history", payload)
end

function ChaosOrb:UpdateSelectionNetTable(playerID)
    if not self.selection or self.selection.playerID ~= playerID then return end

    local payload = {
        active = 1,
        seq = self.selection.seq,
        end_time = self.selection.endTime,
        count = #self.selection.cards,
    }

    for index, effectID in ipairs(self.selection.cards) do
        local effectData = CHAOS_EFFECTS[effectID]
        payload["card_" .. index] = {
            id = effectID,
            title_key = effectData.title_key,
            desc_key = effectData.desc_key,
        }
    end

    CustomNetTables:SetTableValue("chaos", "selection_" .. playerID, payload)
end

function ChaosOrb:ClearSelectionNetTable(playerID)
    CustomNetTables:SetTableValue("chaos", "selection_" .. playerID, {
        active = 0,
        seq = self.selectionSeq,
    })
end
