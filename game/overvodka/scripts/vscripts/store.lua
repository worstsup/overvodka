if Store == nil then
    Store = {}
end

Store.Items = {
    skin_1 = { id = "skin_1", name = "#Store_Item_skin_1_name", type = "skins", price = 500, image = "file://{images}/custom_game/subscribe_button.png" },
    skin_2 = { id = "skin_2", name = "#Store_Item_skin_2_name", type = "skins", price = 750, image = "file://{images}/custom_game/tg_icon.png" },
    effect_1 = { id = "effect_1", name = "#Store_Item_effect_1_name", type = "effects", price = 300, image = "file://{images}/custom_game/subscribe_button.png" },
    pet_1 = { id = "pet_1", name = "#Store_Item_pet_1_name", type = "pets", price = 1000, image = "file://{images}/custom_game/subscribe_button.png" },
}

function Store:Init()
    if self.isInitialized then return end
    self.isInitialized = true
    
    self.playerData = {}
    CustomNetTables:SetTableValue("store", "items", self.Items)

    ListenToGameEvent("player_connect_full", Dynamic_Wrap(self, "OnPlayerConnectFull"), self)
    CustomGameEventManager:RegisterListener("store_buy_item", function(_, event) self:OnBuyItem(event) end)
    
    print("[Store] Initialized successfully.")
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
            if err or not body.success then
                print("[Store] Failed to fetch data for player " .. playerID)
                return
            end
            
            print("[Store] Received data for player " .. playerID)
            
            self.playerData[playerID] = {
                coins = body.coins or 0,
                inventory = self:ArrayToSet(body.inventory or {})
            }

            CustomNetTables:SetTableValue("player_data", steamID, self.playerData[playerID])
        end
    )
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

    self:SendRequest(
        SERVER_URL .. "buy_item",
        { SteamID = steamID, item_id = itemID },
        function(err, body)
            local player = PlayerResource:GetPlayer(playerID)
            if not player then return end

            if err or not (body and body.success) then
                local errorMsg = (body and body.error) or (err and err.error) or "Server error"
                CustomGameEventManager:Send_ServerToPlayer(player, "store_buy_response", { success = false, error = errorMsg })
                return
            end
            
            self.playerData[playerID] = self.playerData[playerID] or {}
            self.playerData[playerID].coins = body.new_balance
            self.playerData[playerID].inventory = self:ArrayToSet(body.inventory or {})
            
            CustomNetTables:SetTableValue("player_data", steamID, self.playerData[playerID])
            CustomGameEventManager:Send_ServerToPlayer(player, "store_buy_response", {success = true,new_balance = body.new_balance})
        end
    )
end

function Store:ArrayToSet(arr)
    local set = {}
    for _, itemId in ipairs(arr) do
        set[itemId] = true
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

Store:Init()