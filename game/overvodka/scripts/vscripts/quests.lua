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
        max = 25,
        event = "kills"
    },
    {
        id = "magicDamage",
        name = "#Quest_MagicDamage_Title",
        description = "#Quest_MagicDamage_Desc",
        max = 15000,
        event = "magicDamage"
    },
    {
        id = "physDamage",
        name = "#Quest_PhysDamage_Title",
        description = "#Quest_PhysDamage_Desc",
        max = 15000,
        event = "physDamage"
    },
    {
        id = "goldAmount",
        name = "#Quest_GoldAmount_Title",
        description = "#Quest_GoldAmount_Desc",
        max = 20,
        event = "goldAmount"
    },
    {
        id = "chestAmount",
        name = "#Quest_ChestAmount_Title",
        description = "#Quest_ChestAmount_Desc",
        max = 3,
        event = "chestAmount"
    },
    {
        id = "chipsAmount",
        name = "#Quest_ChipsAmount_Title",
        description = "#Quest_ChipsAmount_Desc",
        max = 3,
        event = "chipsAmount"
    },
    {
        id = "leshAmount",
        name = "#Quest_LeshAmount_Title",
        description = "#Quest_LeshAmount_Desc",
        max = 2,
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
        max = 1,
        event = "cubinAmount"
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

function Quests:ShuffleTable(tbl)
    for i = #tbl, 2, -1 do
        local j = RandomInt(1, i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

function Quests:RecordQuestInit(playerID)

    local steamID = PlayerResource:GetSteamAccountID(playerID)
    if steamID == 0 then
        print("[Quests] Invalid SteamID for player", playerID)
        return
    end

    self:SendRequest(
        SERVER_URL .. "quest_init",
        {
            SteamID = steamID,
            SelectedQuests = pd.selectedQuests,
        },
        function(err, body)
            if err then
                print("[Quests] Quest init error:")
                PrintTable(err)  -- Print the error table
            else
                print("[Quests] Quest init successful for player", playerID)
            end
        end,
        true
    )
end

function Quests:InitializeForPlayer(playerID)
    if self.playerData[playerID] then return end
    local allIds = {}
    for _, q in ipairs(self.QuestTypes) do allIds[#allIds+1] = q.id end
    local shuffled = self:ShuffleTable(allIds)
    local pd = { activeQuests = {}, progress = {}, selectedQuests = {} }
    for i=1,math.min(3,#shuffled) do
        local id = shuffled[i]
        pd.activeQuests[id]   = true
        pd.selectedQuests[i]   = id
        pd.progress[id] = 0  -- Initialize progress to 0
    end
    self.playerData[playerID] = pd
    self:UpdateNetTable(playerID)  -- Initial update with zeros
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
                PrintTable(err)  -- Print the error table
                return
            end
            
            print("[Quests] Received quest data for player", playerID)
            
            local pd = self.playerData[playerID]
            local serverData = body.quests or {}
            
            -- Initialize progress from server
            for _, qid in ipairs(pd.selectedQuests) do
                pd.progress[qid] = serverData[qid] or 0
            end
            
            -- Check if we need to initialize
            local isFresh = true
            for _, qid in ipairs(pd.selectedQuests) do
                if serverData[qid] ~= nil then
                    isFresh = false
                    break
                end
            end
            
            if isFresh then
                print("[Quests] Initializing fresh quests for player", playerID)
                self:RecordQuestInit(playerID)
            end
            
            self:UpdateNetTable(playerID)
        end,
        true  -- debugEnabled
    )
end

function Quests:IncrementQuest(playerID, questId, amount)
    amount = amount or 1
    local pd = self.playerData[playerID]
    if not pd then 
        print("[Quests] No player data for", playerID)
        return 
    end
    
    if not pd.activeQuests[questId] then
        print("[Quests] Quest not active for player", playerID, questId)
        return
    end
    
    local current = pd.progress[questId] or 0
    local maxVal  = self:GetQuestMax(questId)
    if not maxVal then 
        print("[Quests] Max value not found for", questId)
        return 
    end
    
    if current >= maxVal then
        return
    end
    
    local newVal = math.min(current + amount, maxVal)
    pd.progress[questId] = newVal
    
    self:UpdateNetTable(playerID)
    
    local steamID = PlayerResource:GetSteamAccountID(playerID)
    if steamID == 0 then
        print("[Quests] Invalid SteamID for player", playerID)
        return
    end
    
    self:SendRequest(
        SERVER_URL .. "quest_progress",
        {
            SteamID  = steamID,
            QuestID  = questId,
            Progress = newVal
        },
        function(err, body)
            if err then
                print("[Quests] Progress save error:")
                PrintTable(err)
            end
        end,
        true
    )
end

function Quests:OnEntityKilled(event)
    local attackerIndex = event.entindex_attacker
    if not attackerIndex then return end
    local killer = EntIndexToHScript(attackerIndex)
    if not killer or not killer:IsHero() then return end

    local playerID = killer:GetPlayerOwnerID()
    self:IncrementQuest(playerID, "kills")
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
end

function Quests:OnEntityHurt(event)
    local attackerIndex = event.entindex_attacker
    local victimIndex = event.entindex_killed
    local inflictorIndex = event.entindex_inflictor
    local damage = math.floor(event.damage or 0)
    if not attackerIndex or not victimIndex or damage <= 0 then return end

    local attacker = EntIndexToHScript(attackerIndex)
    local victim = EntIndexToHScript(victimIndex)
    if not attacker or not attacker:IsHero() then return end
    if not victim or not victim:IsHero() then return end
    if attacker:GetTeamNumber() == victim:GetTeamNumber() then return end

    local playerID = attacker:GetPlayerOwnerID()
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