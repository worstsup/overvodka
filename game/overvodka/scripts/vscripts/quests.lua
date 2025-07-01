if Quests == nil then
    Quests = {}
end

Quests.SERVER_ONE_TRY_WAIT_TIME = 5000
Quests.SERVER_MAX_ATTEMPTS = 3
Quests.SERVER_ATTEMPT_INTERVAL = 2

Quests.QuestTypes = {
    {
        id = "kills",
        name = "#Quest_Kills_Title",
        description = "#Quest_Kills_Desc",
        max = 50,
        event = "kills"
    },
    {
        id = "creepKills",
        name = "#Quest_CreepKills_Title",
        description = "#Quest_CreepKills_Desc",
        max = 30,
        event = "creepKills"
    },
    {
        id = "magicDamage",
        name = "#Quest_MagicDamage_Title",
        description = "#Quest_MagicDamage_Desc",
        max = 25000,
        event = "magicDamage"
    },
    {
        id = "physDamage",
        name = "#Quest_PhysDamage_Title",
        description = "#Quest_PhysDamage_Desc",
        max = 25000,
        event = "physDamage"
    },
    {
        id = "goldAmount",
        name = "#Quest_GoldAmount_Title",
        description = "#Quest_GoldAmount_Desc",
        max = 50,
        event = "goldAmount"
    },
    {
        id = "chestAmount",
        name = "#Quest_ChestAmount_Title",
        description = "#Quest_ChestAmount_Desc",
        max = 5,
        event = "chestAmount"
    },
    {
        id = "chipsAmount",
        name = "#Quest_ChipsAmount_Title",
        description = "#Quest_ChipsAmount_Desc",
        max = 5,
        event = "chipsAmount"
    },
    {
        id = "leshAmount",
        name = "#Quest_LeshAmount_Title",
        description = "#Quest_LeshAmount_Desc",
        max = 3,
        event = "leshAmount"
    },
    {
        id = "chapmanAmount",
        name = "#Quest_ChapmanAmount_Title",
        description = "#Quest_ChapmanAmount_Desc",
        max = 5,
        event = "chapmanAmount"
    },
    {
        id = "cubinAmount",
        name = "#Quest_CubinAmount_Title",
        description = "#Quest_CubinAmount_Desc",
        max = 2,
        event = "cubinAmount"
    },
    {
        id = "byebyeAmount",
        name = "#Quest_ByeByeAmount_Title",
        description = "#Quest_ByeByeAmount_Desc",
        max = 3,
        event = "byebyeAmount"
    },
    {
        id = "hamsterGold",
        name = "#Quest_HamsterGold_Title",
        description = "#Quest_HamsterGold_Desc",
        max = 5000,
        event = "hamsterGold"
    },
    {
        id = "midTime",
        name = "#Quest_MidTime_Title",
        description = "#Quest_MidTime_Desc",
        max = 1200,
        event = "midTime"
    },
    {
        id = "kaskaAmount",
        name = "#Quest_KaskaAmount_Title",
        description = "#Quest_KaskaAmount_Desc",
        max = 50,
        event = "kaskaAmount"
    },
    {
        id = "armatureAmount",
        name = "#Quest_ArmatureAmount_Title",
        description = "#Quest_ArmatureAmount_Desc",
        max = 10,
        event = "armatureAmount"
    },
    {
        id = "bablokradAmount",
        name = "#Quest_BablokradAmount_Title",
        description = "#Quest_BablokradAmount_Desc",
        max = 1500,
        event = "bablokradAmount"
    },
    {
        id = "goldenrainTime",
        name = "#Quest_GoldenRainTime_Title",
        description = "#Quest_GoldenRainTime_Desc",
        max = 30,
        event = "goldenrainTime"
    },
    {
        id = "cookieHeal",
        name = "#Quest_CookieHeal_Title",
        description = "#Quest_CookieHeal_Desc",
        max = 3000,
        event = "cookieHeal"
    }
}

function Quests:Init()
    self.qStarted = true
    self.playerData = {}
    
    local configArray = {}
    for _, quest in ipairs(self.QuestTypes) do
        table.insert(configArray, quest)
    end
    
    CustomNetTables:SetTableValue("quests", "config", {
        questTypes = configArray
    })
    
    print("[Quests] Initialized quest config net table as array")
    
    ListenToGameEvent("player_connect_full", Dynamic_Wrap(Quests, "OnPlayerConnectFull"), self)
    ListenToGameEvent("entity_killed", Dynamic_Wrap(Quests, "OnEntityKilled"), self)
    ListenToGameEvent("dota_player_used_ability", Dynamic_Wrap(Quests, "OnAbilityUsed"), self)
    ListenToGameEvent("entity_hurt", Dynamic_Wrap(Quests, "OnEntityHurt"), self)
    ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap( Quests, "OnItemPickUp"), self )
    ListenToGameEvent("player_disconnect", Dynamic_Wrap(Quests, "OnPlayerDisconnect"), self)
    self.modifierTimers = {}
    self.thinkerTimer = Timers:CreateTimer(1, function()
        self:TrackModifierTimes()
        return 1
    end)
end

function Quests:TrackModifierTimes()
    for playerID, pd in pairs(self.playerData) do
        if pd.activeQuests["midTime"] then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            if hero and hero:IsAlive() then
                if hero:HasModifier("modifier_get_xp") then
                    if not self.modifierTimers[playerID] then
                        self.modifierTimers[playerID] = {
                            totalTime = pd.progress["midTime"] or 0,
                            unsavedTime = 0
                        }
                    end
                    self.modifierTimers[playerID].totalTime = self.modifierTimers[playerID].totalTime + 1
                    self.modifierTimers[playerID].unsavedTime = self.modifierTimers[playerID].unsavedTime + 1
                    pd.progress["midTime"] = self.modifierTimers[playerID].totalTime
                    if self.modifierTimers[playerID].unsavedTime >= 5 or 
                       self.modifierTimers[playerID].totalTime >= self:GetQuestMax("midTime") then
                        self:UpdateNetTable(playerID)
                        self.modifierTimers[playerID].unsavedTime = 0
                        pd.dirty = true
                    end
                end
            end
        end
    end
end

function Quests:OnPlayerDisconnect(event)
    local playerID = event.PlayerID
    if playerID and self.playerData[playerID] then
        if self.modifierTimers[playerID] then
            self.playerData[playerID].progress["midTime"] = self.modifierTimers[playerID].totalTime
            self.playerData[playerID].dirty = true
        end
        self:SavePlayerProgress(playerID)
    end
end

function Quests:GetQuestMax(questId)
    for _, q in ipairs(self.QuestTypes) do
        if q.id == questId then
            return q.max
        end
    end
    return nil
end

function Quests:OnPlayerConnectFull(event)
    local playerID = event.PlayerID
    if playerID and playerID >= 0 then
        self:InitializeForPlayer(playerID)
    end
end

function Quests:InitializeForPlayer(playerID)
    if self.playerData[playerID] then return end
    local pd = {
        activeQuests = {},
        progress = {},
        questDate = nil,
        dirty = false
    }
    self.playerData[playerID] = pd
    self:FetchPlayerProgress(playerID)
end

function Quests:UpdateNetTable(playerID)
    CustomNetTables:SetTableValue("quests", "player_" .. playerID, {
        activeQuests = self.playerData[playerID].activeQuests,
        progress = self.playerData[playerID].progress
    })
end

function Quests:FetchPlayerProgress(playerID)
    local steamID = PlayerResource:GetSteamAccountID(playerID)
    if steamID == 0 then
        print("[Quests] Invalid SteamID for player", playerID)
        return
    end

    self:SendRequest(
        SERVER_URL .. "get_player_quests",
        { SteamID = steamID },
        function(err, body)
            if err then
                print("[Quests] Fetch progress error:")
                PrintTable(err)
                return
            end
            
            local pd = self.playerData[playerID]
            pd.questDate = body.quest_date
            pd.progress = body.quests or {}
            pd.activeQuests = {}
            
            for questId, _ in pairs(pd.progress) do
                pd.activeQuests[questId] = true
            end
            
            self:UpdateNetTable(playerID)
        end,
        true
    )
end

function Quests:IncrementQuest(playerID, questId, amount)
    amount = amount or 1
    local pd = self.playerData[playerID]
    if not pd then return end
    if not pd.activeQuests[questId] then
        return
    end
    local current = pd.progress[questId] or 0
    local maxVal  = self:GetQuestMax(questId)
    if not maxVal then return end
    if current >= maxVal then
        return
    end
    local newVal = math.min(current + amount, maxVal)
    if newVal > current then
        pd.progress[questId] = newVal
        pd.dirty = true
        self:UpdateNetTable(playerID)
    end
end

function Quests:OnEntityKilled(event)
    local attackerIndex = event.entindex_attacker
    if not attackerIndex then return end
    local killer = EntIndexToHScript(attackerIndex)
    if not killer or not killer.IsHero or not killer:IsHero() then return end
    local killedIndex = event.entindex_killed
    if not killedIndex then return end
    local killed = EntIndexToHScript(killedIndex)
    if not killed then return end
    local playerID = killer:GetPlayerOwnerID()
    if not playerID or not self.playerData[playerID] then return end
    if killed:IsCreep() then
        self:IncrementQuest(playerID, "creepKills")
    end
    if killed:IsRealHero() then
        self:IncrementQuest(playerID, "kills")
    end
end

function Quests:SaveAllProgress()
    print("[Quests] Saving all progress at end of game")
    
    for playerID, pd in pairs(self.playerData) do
        if pd.dirty and PlayerResource:IsValidPlayerID(playerID) then
            self:SavePlayerProgress(playerID)
        end
    end
end

function Quests:SavePlayerProgress(playerID)
    local pd = self.playerData[playerID]
    if not pd or not pd.questDate then 
        return 
    end
    
    if self.modifierTimers[playerID] then
        pd.progress["midTime"] = self.modifierTimers[playerID].totalTime
        pd.dirty = true
    end
    
    if not pd.dirty then return end
    
    local steamID = PlayerResource:GetSteamAccountID(playerID)
    if steamID == 0 then return end
    
    self:SendRequest(
        SERVER_URL .. "quest_progress_batch",
        {
            SteamID = steamID,
            Progress = pd.progress,
            QuestDate = pd.questDate
        },
        function(err, body)
            if err then
                print("[Quests] Save error for player", playerID)
                PrintTable(err)
            else
                print("[Quests] Progress saved for player", playerID)
                pd.dirty = false
            end
        end,
        true
    )
end

function Quests:OnAbilityUsed(event)
    local playerID    = event.PlayerID
    local abilityName = event.abilityname
    if not playerID or playerID < 0 or not abilityName then return end
    
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    if not hero then return end
    
    if abilityName == "item_burger_sobolev" or abilityName == "item_burger_oblomoff" or abilityName == "item_burger_larin" then
        self:IncrementQuest(playerID, "chipsAmount")
    end
    if abilityName == "item_lesh" then
        self:IncrementQuest(playerID, "leshAmount")
    end
    if abilityName == "item_chapman_red" or abilityName == "item_chapman_blue" or abilityName == "item_chapman_green" or abilityName == "item_chapman_yellow"  or abilityName == "item_chapman_violet" or abilityName == "item_chapman_pink" or abilityName == "item_chapman_indigo" then
        self:IncrementQuest(playerID, "chapmanAmount")
    end
    if abilityName == "item_cubin" then
        self:IncrementQuest(playerID, "cubinAmount")
    end
    if abilityName == "item_byebye" then
        self:IncrementQuest(playerID, "byebyeAmount")
    end
end

function Quests:OnEntityHurt(event)
    local attackerIndex = event.entindex_attacker
    local victimIndex = event.entindex_killed
    local inflictorIndex = event.entindex_inflictor
    local damage = math.floor(event.damage or 0)
    if not attackerIndex or not victimIndex then return end

    local attacker = EntIndexToHScript(attackerIndex)
    local victim = EntIndexToHScript(victimIndex)
    if not attacker or not attacker:IsHero() then return end
    local playerID = attacker:GetPlayerOwnerID()
    if victim and victim:GetUnitName() == "npc_hamster" then
        self:IncrementQuest(playerID, "hamsterGold", 200)
    end
    if damage <= 0 or not victim or not victim:IsHero() then return end
    if attacker:GetTeamNumber() == victim:GetTeamNumber() then return end
    if not self.playerData[playerID] then return end

    local isMagic    = false
    local isPhysical = false

    if inflictorIndex then
        local ability = EntIndexToHScript(inflictorIndex)
        if ability and ability.GetAbilityDamageType then
            local dt = ability:GetAbilityDamageType()
            if dt == DAMAGE_TYPE_MAGICAL then
                isMagic = true
            elseif dt == DAMAGE_TYPE_PHYSICAL then
                isPhysical = true
            end
        end
    else
        isPhysical = true
    end

    if isMagic then
        self:IncrementQuest(playerID, "magicDamage", damage)
    end

    if isPhysical then
        self:IncrementQuest(playerID, "physDamage", damage)
    end
end

function Quests:OnItemPickUp( event )
    local item = EntIndexToHScript( event.ItemEntityIndex )
    local owner
	if event.HeroEntityIndex then
		owner = EntIndexToHScript(event.HeroEntityIndex)
	elseif event.UnitEntityIndex then
		owner = EntIndexToHScript(event.UnitEntityIndex)
	end
	if not owner:IsRealHero() then owner = owner:GetOwner() end
    if event.itemname == "item_bag_of_gold" then
        local playerID = owner:GetPlayerOwnerID()
        if playerID and playerID >= 0 then
            self:IncrementQuest(playerID, "goldAmount")
        end
    end
    if event.itemname == "item_treasure_chest" then
        local playerID = owner:GetPlayerOwnerID()
        if playerID and playerID >= 0 then
            self:IncrementQuest(playerID, "chestAmount")
        end
    end
end

function Quests:SendRequest(url, data, callback, debugEnabled, attempt)
    --if IsInToolsMode() or GameRules:IsCheatMode() then return end
    attempt = attempt or 1
    debugEnabled = debugEnabled or false
    
    local function ifprint(msg)
        if debugEnabled then
            print("[Quests] " .. msg)
        end
    end

    ifprint('Sending request to: '..url..' (attempt '..attempt..')')
    local DataToSend = data or {}
    DataToSend['GameKey'] = SERVER_KEY

    local EncodedData = json.encode(DataToSend)
    local Request = CreateHTTPRequestScriptVM('POST', url)
    Request:SetHTTPRequestAbsoluteTimeoutMS(SERVER_ONE_TRY_WAIT_TIME)
    Request:SetHTTPRequestGetOrPostParameter('data', EncodedData)
    
    Request:Send(function(Result)
        if Result.StatusCode ~= 200 then
            ifprint("HTTP error: "..tostring(Result.StatusCode))
            local nextAttempt = attempt + 1
            if nextAttempt <= SERVER_MAX_ATTEMPTS then
                Timers:CreateTimer(SERVER_ATTEMPT_INTERVAL, function()
                    self:SendRequest(url, data, callback, debugEnabled, nextAttempt)
                end)
            elseif callback then
                callback({status = Result.StatusCode, body = Result.Body}, nil)
            end
            return
        end
        
        local success, ResultData = pcall(json.decode, Result.Body)
        if not success or not ResultData then
            ifprint("JSON decode error")
            local nextAttempt = attempt + 1
            if nextAttempt <= SERVER_MAX_ATTEMPTS then
                Timers:CreateTimer(SERVER_ATTEMPT_INTERVAL, function()
                    self:SendRequest(url, data, callback, debugEnabled, nextAttempt)
                end)
            elseif callback then
                callback({error = "JSON decode failed", body = Result.Body}, nil)
            end
            return
        end
        
        ifprint("Request successful")
        if callback then
            callback(nil, ResultData)
        end
    end)
end

if not Quests.qStarted then Quests:Init() end