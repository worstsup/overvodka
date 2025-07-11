if Vote == nil then
    Vote = {}
end

function Vote:Init()
    if self.isInitialized then return end
    self.isInitialized = true

    CustomGameEventManager:RegisterListener("vote_get_info", function(_, e) self:OnGetVoteInfo(e) end)
    CustomGameEventManager:RegisterListener("vote_submit", function(_, e) self:OnSubmitVote(e) end)

    print("[Vote] Initialized successfully.")
end

function Vote:OnGetVoteInfo(event)
    local playerID = event.PlayerID
    local steamID = tostring(PlayerResource:GetSteamAccountID(playerID))
    if steamID == "0" then return end

    if Server and Server.SendRequest then
        Server:SendRequest(SERVER_URL .. "get_vote_info", {SteamID = steamID}, function(body)
            local player = PlayerResource:GetPlayer(playerID)
            if player and body and body.success then
                CustomGameEventManager:Send_ServerToPlayer(player, "vote_info_response", body)
            end
        end, true)
    end
end

function Vote:OnSubmitVote(event)
    local playerID = event.PlayerID
    local heroName = event.hero_name
    local steamID = tostring(PlayerResource:GetSteamAccountID(playerID))
    if steamID == "0" or not heroName then return end

    if Server and Server.SendRequest then
        Server:SendRequest(SERVER_URL .. "submit_vote", {SteamID = steamID, hero_name = heroName}, function(body)
            if not (body and body.success) then
                return
            end
            self:OnGetVoteInfo({ PlayerID = playerID })
        end, true)
    end
end

Vote:Init()
