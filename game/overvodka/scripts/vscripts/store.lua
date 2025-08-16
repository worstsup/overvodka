if Store == nil then
    Store = {}
end

Store.Items = {
    skin_1 = { id = "skin_1", name = "#Store_Item_skin_1_name", type = "skins", price = 75, image = "file://{images}/custom_game/store/skins/skin_1.png", hero = "npc_dota_hero_ursa", modifier = "modifier_overvodka_store_skin_1" },
    skin_2 = { id = "skin_2", name = "#Store_Item_skin_2_name", type = "skins", price = 50, image = "file://{images}/custom_game/store/skins/skin_2.png", hero = "npc_dota_hero_ancient_apparition", modifier = "modifier_overvodka_store_skin_2" },
    skin_3 = { id = "skin_3", name = "#Store_Item_skin_3_name", type = "skins", price = 100, image = "file://{images}/custom_game/store/skins/skin_3.png", hero = "npc_dota_hero_axe", modifier = "modifier_overvodka_store_skin_3" },
    skin_4 = { id = "skin_4", name = "#Store_Item_skin_4_name", type = "skins", price = 200, image = "file://{images}/custom_game/store/skins/skin_4.png", hero = "npc_dota_hero_ogre_magi", modifier = "modifier_overvodka_store_skin_4" },
    effect_1 = { id = "effect_1", name = "#Store_Item_effect_1_name", type = "effects", price = 50, image = "file://{images}/custom_game/store/effects/effect_1.png", modifier = "modifier_overvodka_store_effect_1" },
    effect_2 = { id = "effect_2", name = "#Store_Item_effect_2_name", type = "effects", price = 100, image = "file://{images}/custom_game/store/effects/effect_2.png", modifier = "modifier_overvodka_store_effect_2" },
    effect_3 = { id = "effect_3", name = "#Store_Item_effect_3_name", type = "effects", price = 125, image = "file://{images}/custom_game/store/effects/effect_3.png", modifier = "modifier_overvodka_store_effect_3" },
    pet_1 = { id = "pet_1", name = "#Store_Item_pet_1_name", type = "pets", price = 100, image = "file://{images}/custom_game/store/pets/pet_1.png", modifier = "modifier_overvodka_store_pet_1" },
    pet_2 = { id = "pet_2", name = "#Store_Item_pet_2_name", type = "pets", price = 100, image = "file://{images}/custom_game/store/pets/pet_2.png", modifier = "modifier_overvodka_store_pet_2" },
    pet_3 = { id = "pet_3", name = "#Store_Item_pet_3_name", type = "pets", price = 150, image = "file://{images}/custom_game/store/pets/pet_3.png", modifier = "modifier_overvodka_store_pet_3" },
    pet_4 = { id = "pet_4", name = "#Store_Item_pet_4_name", type = "pets", price = 150, image = "file://{images}/custom_game/store/pets/pet_4.png", modifier = "modifier_overvodka_store_pet_4" },
    pet_5 = { id = "pet_5", name = "#Store_Item_pet_5_name", type = "pets", price = 125, image = "file://{images}/custom_game/store/pets/pet_5.png", modifier = "modifier_overvodka_store_pet_5" },
    pet_6 = { id = "pet_6", name = "#Store_Item_pet_6_name", type = "pets", price = 150, image = "file://{images}/custom_game/store/pets/pet_6.png", modifier = "modifier_overvodka_store_pet_6" },
    pet_7 = { id = "pet_7", name = "#Store_Item_pet_7_name", type = "pets", price = 150, image = "file://{images}/custom_game/store/pets/pet_7.png", modifier = "modifier_overvodka_store_pet_7" },
    pet_8 = { id = "pet_8", name = "#Store_Item_pet_8_name", type = "pets", price = 150, image = "file://{images}/custom_game/store/pets/pet_8.png", modifier = "modifier_overvodka_store_pet_8" },
    prime_day = { id = "prime_day", name = "#Store_Item_prime_day_name", type = "prime", price = 200, duration = "day", image = "file://{images}/custom_game/store/effects/effect_1.png" },
    prime_week = { id = "prime_week", name = "#Store_Item_prime_week_name", type = "prime", price = 700, duration = "week", image = "file://{images}/custom_game/store/effects/effect_1.png" }
}

function Store:Init()
    if self.isInitialized then return end
    self.isInitialized = true
    
    self.playerData = {}
    self.playerPets = {}
    CustomNetTables:SetTableValue("store", "items", self.Items)
    ListenToGameEvent("player_connect_full", Dynamic_Wrap(self, "OnPlayerConnectFull"), self)
    ListenToGameEvent("npc_spawned", Dynamic_Wrap(self, "OnNPCSpawned"), self)
    ListenToGameEvent("player_disconnect", Dynamic_Wrap(self, "OnPlayerDisconnect"), self)
    CustomGameEventManager:RegisterListener("store_buy_item", function(_, event) self:OnBuyItem(event) end)
    CustomGameEventManager:RegisterListener("store_equip_item", function(_, event) self:OnEquipItem(event) end)
    CustomGameEventManager:RegisterListener("store_unequip_item", function(_, event) self:OnUnequipItem(event) end)
    print("[Store] Initialized successfully.")
end

function Store:OnNPCSpawned(event)
    if not event.entindex then return end
    local npc = EntIndexToHScript(event.entindex)
    if npc:IsHero() and not DebugPanel:IsDummy(npc) then
        local playerID = npc:GetPlayerOwnerID()
        if playerID >= 0 then
            Timers:CreateTimer(0.1, function()
                if npc and not npc:IsNull() then
                    self:ApplyEquippedEffect(playerID, npc)
                    self:ApplyEquippedSkin(playerID, npc)
                    if not npc:IsIllusion() then
                        self:ApplyEquippedPet(playerID, npc)
                    end
                end
            end)
        end
    end
end

function Store:OnPlayerConnectFull(event)
    local playerID = event.PlayerID
    if playerID >= 0 then
        self:FetchPlayerData(playerID)
    end
end

function Store:FetchPlayerData(playerID)
    local steamID = tostring(PlayerResource:GetSteamAccountID(playerID))
    if steamID == "0" then return end

    self:SendRequest(
        SERVER_URL .. "get_store_info",
        { SteamID = steamID },
        function(err, body)
            if err or not body.success then return end
            
            self.playerData[playerID] = {
                coins = body.coins or 0,
                inventory = self:ArrayToSet(body.inventory or {}),
                equipped_effect = body.equipped_effect,
                equipped_skin = body.equipped_skin,
                equipped_pet = body.equipped_pet
            }

            CustomNetTables:SetTableValue("player_data", steamID, self.playerData[playerID])
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            if hero then
                self:ApplyEquippedEffect(playerID, hero)
                self:ApplyEquippedSkin(playerID, hero)
                self:ApplyEquippedPet(playerID, hero)
            end
        end
    )
end

function Store:OnEquipItem(event)
    local playerID = event.PlayerID
    local itemID = event.item_id
    local item = self.Items[itemID]
    local steamID = tostring(PlayerResource:GetSteamAccountID(playerID))
    if not item or steamID == "0" then return end
    
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    if item.type == "skins" and hero and hero:GetUnitName() ~= item.hero then
        SendErrorToPlayer(playerID, "#Store_NotYourHero", "UUI_SOUNDS.NoGold")
        return
    end
    
    self:SendRequest(
        SERVER_URL .. "equip_item",
        { SteamID = steamID, item_id = itemID, item_type = item.type },
        function(err, body)
            if err or not body.success then return end
            
            if item.type == "effects" then
                self.playerData[playerID].equipped_effect = itemID
                self:ApplyEquippedEffect(playerID)
            elseif item.type == "skins" then
                self.playerData[playerID].equipped_skin = itemID
                self:ApplyEquippedSkin(playerID)
            elseif item.type == "pets" then
                self.playerData[playerID].equipped_pet = itemID
                self:ApplyEquippedPet(playerID)
            end
            
            CustomNetTables:SetTableValue("player_data", steamID, self.playerData[playerID])
        end
    )
end

function Store:OnUnequipItem(event)
    local playerID = event.PlayerID
    local itemType = event.item_type
    local steamID = tostring(PlayerResource:GetSteamAccountID(playerID))

    if not itemType or steamID == "0" then return end

    self:SendRequest(
        SERVER_URL .. "unequip_item",
        { SteamID = steamID, item_type = itemType },
        function(err, body)
            if err or not body.success then return end

            if body.unequipped_type == "effects" then
                self.playerData[playerID].equipped_effect = nil
                self:ApplyEquippedEffect(playerID)
            elseif body.unequipped_type == "skins" then
                self.playerData[playerID].equipped_skin = nil
                self:ApplyEquippedSkin(playerID)
            elseif body.unequipped_type == "pets" then
                self.playerData[playerID].equipped_pet = nil
                self:ApplyEquippedPet(playerID)
            end
            
            CustomNetTables:SetTableValue("player_data", steamID, self.playerData[playerID])
        end
    )
end

function Store:ApplyEquippedEffect(playerID, unit)
    local hero = unit or PlayerResource:GetSelectedHeroEntity(playerID)
    if not hero or hero:IsNull() then return end
    if not hero:IsHero() then return end
    for id, itemData in pairs(self.Items) do
        if itemData.type == "effects" then
            local modifierName = itemData.modifier
            if hero:HasModifier(modifierName) then
                hero:RemoveModifierByName(modifierName)
            end
        end
    end
    
    local equippedID = self.playerData[playerID] and self.playerData[playerID].equipped_effect
    if equippedID and self.Items[equippedID] and self.Items[equippedID].modifier then
        local modifierName = self.Items[equippedID].modifier
        hero:AddNewModifier(hero, nil, modifierName, {})
    end
end

function Store:ApplyEquippedSkin(playerID, unit)
    local hero = unit or PlayerResource:GetSelectedHeroEntity(playerID)
    if not hero or hero:IsNull() then return end
    if not hero:IsHero() then return end
    for id, itemData in pairs(self.Items) do
        if itemData.type == "skins" then
            local modifierName = itemData.modifier
            if hero:HasModifier(modifierName) then
                hero:RemoveModifierByName(modifierName)
            end
        end
    end
    
    local equippedID = self.playerData[playerID] and self.playerData[playerID].equipped_skin
    if equippedID and self.Items[equippedID] and self.Items[equippedID].modifier then
        local skinItem = self.Items[equippedID]
        if hero:GetUnitName() == skinItem.hero then
            local modifierName = skinItem.modifier
            hero:AddNewModifier(hero, nil, modifierName, {})
        end
    end
end

function Store:ApplyEquippedPet(playerID, unit)
    local hero = unit or PlayerResource:GetSelectedHeroEntity(playerID)
    if not hero or hero:IsNull() then return end
    if not hero:IsHero() then return end
    if self.playerPets[playerID] and IsValidEntity(self.playerPets[playerID]) then
        self.playerPets[playerID]:RemoveSelf()
        self.playerPets[playerID] = nil
    end
    local equippedID = self.playerData[playerID] and self.playerData[playerID].equipped_pet
    if equippedID and self.Items[equippedID] and self.Items[equippedID].modifier then
        local modifierName = self.Items[equippedID].modifier
        local pet = CreateUnitByName("npc_overvodka_pet", hero:GetAbsOrigin() + RandomVector(RandomFloat(0,100)), true, hero, nil, hero:GetTeamNumber())
        pet:SetOwner(hero)
        pet:AddNewModifier(pet, nil, "modifier_overvodka_pet", {})
        pet:AddNewModifier(pet, nil, modifierName, {})
        self.playerPets[playerID] = pet
    end
end

function Store:OnBuyItem(event)
    local playerID = event.PlayerID
    local itemID = event.item_id
    local item = self.Items[itemID]
    local steamID = tostring(PlayerResource:GetSteamAccountID(playerID))

    if not item or steamID == "0" then return end

    if self.playerData[playerID] and self.playerData[playerID].coins < item.price then
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "store_buy_response", { success = false, error = "Not enough coins" })
        return
    end

    local endpoint
    local payload
    
    if item.type == "prime" then
        endpoint = SERVER_URL .. "buy_prime"
        payload = { SteamID = steamID, price = item.price, duration = item.duration }
    else
        endpoint = SERVER_URL .. "buy_item"
        payload = { SteamID = steamID, item_id = itemID }
    end

    self:SendRequest(endpoint, payload, function(err, body)
        local player = PlayerResource:GetPlayer(playerID)
        if not player then return end

        if err or not (body and body.success) then
            local errorMsg = (body and body.error) or (err and err.error) or "Server error"
            CustomGameEventManager:Send_ServerToPlayer(player, "store_buy_response", { success = false, error = errorMsg })
            return
        end
        if Server and Server.RefreshPlayerProfile then
            Server:RefreshPlayerProfile(playerID)
        end
        self:FetchPlayerData(playerID)
        CustomGameEventManager:Send_ServerToPlayer(player, "store_buy_response", { success = true, new_balance = body.new_balance })
    end)
end

function Store:ArrayToSet(arr)
    local set = {}
    for _, v in ipairs(arr) do
        set[v] = true
    end
    return set
end

function Store:SendRequest(url, data, callback, debugEnabled, attempt)
    attempt = attempt or 1
    debugEnabled = debugEnabled or false
    
    local function ifprint(msg)
        if debugEnabled then
            print("[Store] " .. msg)
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

function Store:OnPlayerDisconnect(event)
    local playerID = event.PlayerID
    if self.playerPets[playerID] and IsValidEntity(self.playerPets[playerID]) then
        self.playerPets[playerID]:RemoveSelf()
        self.playerPets[playerID] = nil
    end
end

Store:Init()