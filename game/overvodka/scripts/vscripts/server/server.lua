require("server/server_settings")

if Server == nil then
	Server = class({})
end

function Server:Init()
    cprint('[Server] Module is active!')
    self.bStarted = true

    self.Players = {}

    ListenToGameEvent('player_connect_full', Dynamic_Wrap(Server, 'OnPlayerConnected'), self)
    ListenToGameEvent('npc_spawned', Dynamic_Wrap(Server, 'OnNPCSpawned'), self)

    CustomGameEventManager:RegisterListener("player_want_tip", function(source, event) self:OnPlayerWantTip(event) end)

    self.ThinkerEnt = SpawnEntityFromTableSynchronous("info_target", {targetname="server_thinker"})
end

function Server:OnPlayerWantTip(event)
    if not self.Players[event.tips_player] then return end

    local CurrentTime = GameRules:GetGameTime()
    if CurrentTime >= self.Players[event.tips_player].TipCooldown then
        self.Players[event.tips_player].TipCooldown = CurrentTime + SERVER_TIP_COOLDOWN

        CustomGameEventManager:Send_ServerToAllClients("player_tipped", {tips_player=event.tips_player, tipped_player=event.tipped_player})
    else
        SendErrorToPlayer(event.tips_player, "#PLAYER_HUD_Error_Tip_Cooldown")
    end
end

function Server:OnNPCSpawned(event)
    if not event.entindex then return end

    local unit = EntIndexToHScript(event.entindex)
    if not unit or unit:IsNull() then return end

    local bIsRespawn = event.is_respawn == 1

    if IsRealHero(unit) then
		local PlayerID = unit:GetPlayerID()

		if not bIsRespawn and self:IsPlayerSubscribed(PlayerID) then
			unit:AddAbility("plus_high_five"):SetLevel(1)

            unit:AddNewModifier(unit, nil, "modifier_subscriber_effect", {})
		end
    end
end

function Server:OnPlayerConnected(event)
    if self.Players[event.PlayerID] == nil and PlayerResource:IsValidPlayerID(event.PlayerID) then
        local SteamID = PlayerResource:GetSteamAccountID(event.PlayerID)
        self.Players[event.PlayerID] = {
            TipCooldown = 0,
            ServerData = {
                SteamID = SteamID
            }
        }

        if SteamID ~= 0 then

            if table.contains(SERVER_PLAYERS_WITH_PERMANENT_PRIVILEGES, SteamID) then
                self.Players[event.PlayerID].ServerData.active = true
                self.Players[event.PlayerID].ServerData.permanent = true
            end

            cprint('[Server] Trying to get profile of '..event.PlayerID..' PlayerID and '..SteamID..' SteamID')

            self:SendRequest(SERVER_URL.."get_player_profile", {SteamID=SteamID}, function(ResultData)
                self:CreatePlayerProfile(ResultData, event.PlayerID, SteamID)
            end, true)
        end
    end
end

function Server:CreatePlayerProfile(data, PlayerID, SteamID)
    if not self.Players[PlayerID] then return end

    cprint('[Server] Creating profile for PlayerID '..PlayerID..' and SteamID '..SteamID)

    self.Players[PlayerID].ServerData = data
    self.Players[PlayerID].ServerData.SteamID = SteamID

    if table.contains(SERVER_PLAYERS_WITH_PERMANENT_PRIVILEGES, SteamID) then
        self.Players[PlayerID].ServerData.active = true
        self.Players[PlayerID].ServerData.permanent = true
    end

    self:UpdatePlayerNetTable(PlayerID)
end

function Server:UpdatePlayerNetTable(PlayerID)
    if not self.Players[PlayerID] then return end

    CustomNetTables:SetTableValue("players", "player_"..PlayerID, self.Players[PlayerID].ServerData)
end

function Server:SendRequest(url, data, callback, debugEnabled, attempt)
    if IsInToolsMode() or GameRules:IsCheatMode() then return end

    local current_attempt = attempt and attempt or 1

    ifprint('Trying to create request to URL='..url..' attempt='..current_attempt, debugEnabled)
    local DataToSend = data or {}
    DataToSend['GameKey'] = SERVER_KEY

    local EncodedData = json.encode(DataToSend)
    local Request = CreateHTTPRequestScriptVM('POST', url)
    Request:SetHTTPRequestAbsoluteTimeoutMS(SERVER_ONE_TRY_WAIT_TIME)
    Request:SetHTTPRequestGetOrPostParameter('data', EncodedData)
    Request:Send(function(Result)
        if Result.StatusCode ~= 200 then
            ifprint("Request error! Status code " .. tostring(Result.StatusCode) .. ". Trying next attempt", debugEnabled)
            local ResultData = {json.decode(Result.Body)}
            if ResultData and ResultData[1] and ResultData[1].dontTry == 1 then
                return
            end
            current_attempt = current_attempt + 1
            if current_attempt <= SERVER_MAX_ATTEMPTS then
                self.ThinkerEnt:SetThink(function()
                    self:SendRequest(
                        url,
                        data,
                        callback,
                        debugEnabled,
                        current_attempt
                    )
                    return -1
                end, self, DoUniqueString("Attempt"), SERVER_ATTEMPT_INTERVAL)
            end
            return
        end
        local ResultData = {json.decode(Result.Body)}
        if not ResultData or not ResultData[1] then
            ifprint("Request error! Result data is nil! Trying next attempt", debugEnabled)
            current_attempt = current_attempt + 1
            if current_attempt <= SERVER_MAX_ATTEMPTS then
                self.ThinkerEnt:SetThink(function()
                    self:SendRequest(
                        url,
                        data,
                        callback,
                        debugEnabled,
                        current_attempt
                    )
                    return -1
                end, self, DoUniqueString("Attempt"), SERVER_ATTEMPT_INTERVAL)
            end
            return
        end
        ifprint("Request was returned completely!", debugEnabled)
        if callback then
            ifprint("Trying to call callback", debugEnabled)
            callback(ResultData[1])
        end
    end)
end

function Server:IsPlayerSubscribed(PlayerID)
    if not self.Players[PlayerID] then return false end

    return self.Players[PlayerID].ServerData.active == true
end

function ifprint(sText, bEnabled)
    if bEnabled then
        cprint("[Server] "..sText)
    end
end

if not Server.bStarted then Server:Init() end