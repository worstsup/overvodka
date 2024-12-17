require("server/server_settings")

if Server == nil then
	Server = class({})
end

function Server:Init()
    cprint('[Server] Module is active!')
    self.bStarted = true

    self.bGameEnded = false

    self.Players = {}

    ListenToGameEvent('player_connect_full', Dynamic_Wrap(Server, 'OnPlayerConnected'), self)
    ListenToGameEvent('npc_spawned', Dynamic_Wrap(Server, 'OnNPCSpawned'), self)

    CustomGameEventManager:RegisterListener("player_want_tip", function(source, event) self:OnPlayerWantTip(event) end)
    CustomGameEventManager:RegisterListener("server_get_leaderboard_info", function(source, event) self:OnAttemptGetLeaderboardInfo(event) end)

    self.ThinkerEnt = SpawnEntityFromTableSynchronous("info_target", {targetname="server_thinker"})
end

function Server:OnGameEnded(Teams)

    if IsInToolsMode() or GameRules:IsCheatMode() then return end

    if Teams == nil or #Teams <= 1 then return end

    if self.bGameEnded == true then return end

    self.bGameEnded = true

    local CurrentCategory = GetCurrentCategory()

    if CurrentCategory == GAME_CATEGORY_DEFINITIONS.NONE then return end

    local MatchID = tostring(GameRules:Script_GetMatchID())

    print("[Server] Saving data to server!")

    for PlayerID, PlayerInfo in pairs(self.Players) do
        local Hero = PlayerResource:GetSelectedHeroEntity(PlayerID)
        if Hero then
            local HeroName = Hero:GetUnitName()
            local Kills = PlayerResource:GetKills(PlayerID)
            local Deaths = PlayerResource:GetDeaths(PlayerID)
            local Assists = PlayerResource:GetAssists(PlayerID)
            local Rating = self:CalculateRating(PlayerID, Teams)
            local bWin = Rating >= 45
            local PlayerData = {
                rating = Rating,
                heroname = HeroName,
                kills = Kills,
                deaths = Deaths,
                assists = Assists,
                win = bWin,
                leaved = PlayerResource:GetConnectionState(PlayerID) == "DOTA_CONNECTION_STATE_ABANDONED"
            }

            local SteamID = PlayerResource:GetSteamAccountID(PlayerID)

            self:SendRequest(SERVER_URL.."game_ended", {SteamID=SteamID, MatchID = MatchID, Category = CurrentCategory, PlayerData=PlayerData}, nil, true)
        end
    end
end

function Server:CalculateRating(PlayerID, Teams)
    local PlayerTeam = PlayerResource:GetTeam(PlayerID)
    local TeamTop = 0
    local bKillsDone = false
    local TeamsCount = #Teams

    local PlayerRank = self:GetPlayerRank(PlayerID)

    if PlayerRank == SERVER_RANKS_DEFINITION.NONE then return 0 end

    for top, Team in ipairs(Teams) do
        if Team.teamID == PlayerTeam then
            TeamTop = top
            if Team.teamScore == 50 then
                bKillsDone = true
            end
            break
        end
    end

    if TeamTop == 0 then return 0 end

    local CurrentCategory = GetCurrentCategory()

    if CurrentCategory == GAME_CATEGORY_DEFINITIONS.NONE then return 0 end

    local RatingTable = SERVER_RATING[CurrentCategory][TeamTop]

    if RatingTable == nil then return 0 end

    local Rating = 0

    if IsSolo() then
        local bFullTeams = TeamsCount > 6
        if bFullTeams then
            if TeamTop == 1 then
                if bKillsDone then
                    Rating = RandomInt(RatingTable.min_full_kills, RatingTable.max_full_kills)
                else
                    Rating = RandomInt(RatingTable.min_full, RatingTable.max_full)
                end
            elseif TeamTop < 4 then
                Rating = RandomInt(RatingTable.min_full, RatingTable.max_full)
            elseif TeamTop < 6 then
                if PlayerRank >= SERVER_RANKS_DEFINITION.GOLD then
                    Rating = RandomInt(RatingTable.min_full_after_gold, RatingTable.max_full_after_gold)
                else
                    Rating = RandomInt(RatingTable.min_full, RatingTable.max_full)
                end
            elseif TeamTop < 8 then
                if PlayerRank >= SERVER_RANKS_DEFINITION.DIAMOND then
                    Rating = RandomInt(RatingTable.min_full_after_diamond, RatingTable.max_full_after_diamond)
                elseif PlayerRank >= SERVER_RANKS_DEFINITION.GOLD then
                    Rating = RandomInt(RatingTable.min_full_after_gold, RatingTable.max_full_after_gold)
                else
                    Rating = RandomInt(RatingTable.min_full, RatingTable.max_full)
                end
            else
                if PlayerRank >= SERVER_RANKS_DEFINITION.DIAMOND then
                    Rating = RandomInt(RatingTable.min_full_after_diamond, RatingTable.max_full_after_diamond)
                else
                    Rating = RandomInt(RatingTable.min_full, RatingTable.max_full)
                end
            end
        else
            if TeamTop == 1 then
                if bKillsDone then
                    Rating = RandomInt(RatingTable.min_less6_kills, RatingTable.max_less6_kills)
                else
                    Rating = RandomInt(RatingTable.min_less6, RatingTable.max_less6)
                end
            else
                Rating = RandomInt(RatingTable.min_less6, RatingTable.max_less6)
            end
        end
    elseif IsDuo() then
        local bFullTeams = TeamsCount > 3
        if bFullTeams then
            if TeamTop == 1 then
                if bKillsDone then
                    Rating = RandomInt(RatingTable.min_full_kills, RatingTable.max_full_kills)
                else
                    Rating = RandomInt(RatingTable.min_full, RatingTable.max_full)
                end
            elseif TeamTop == 2 then
                Rating = RandomInt(RatingTable.min_full, RatingTable.max_full)
            else
                if PlayerRank >= SERVER_RANKS_DEFINITION.DIAMOND then
                    Rating = RandomInt(RatingTable.min_full_after_diamond, RatingTable.max_full_after_diamond)
                else
                    Rating = RandomInt(RatingTable.min_full_before_diamond, RatingTable.min_full_before_diamond)
                end
            end
        else
            if TeamTop == 1 then
                if bKillsDone then
                    Rating = RandomInt(RatingTable.min_less3_kills, RatingTable.max_less3_kills)
                else
                    Rating = RandomInt(RatingTable.min_less3, RatingTable.max_less3)
                end
            else
                Rating = RandomInt(RatingTable.min_less3, RatingTable.max_less3)
            end
        end
    end

    return Rating
end

function Server:GetPlayerRank(PlayerID)
    if not self.Players[PlayerID] then return end

    local Rating = self.Players[PlayerID].loaded == true and self.Players[PlayerID].ServerData.rating or 0

    local Definitions = {
        {
            min = 0,
            max = 1000,
            type = SERVER_RANKS_DEFINITION.BRONZE
        },
        {
            min = 1000,
            max = 2000,
            type = SERVER_RANKS_DEFINITION.SILVER
        },
        {
            min = 2000,
            max = 3000,
            type = SERVER_RANKS_DEFINITION.GOLD
        },
        {
            min = 3000,
            max = 4000,
            type = SERVER_RANKS_DEFINITION.PLATINUM
        },
        {
            min = 4000,
            max = 5000,
            type = SERVER_RANKS_DEFINITION.DIAMOND
        },
        {
            min = 5000,
            max = -1,
            type = SERVER_RANKS_DEFINITION.EPIC
        },
    }

    for _, RatingInfo in ipairs(Definitions) do
        if Rating >= RatingInfo.min then
            if RatingInfo.max == -1 then
                return RatingInfo.type
            elseif Rating < RatingInfo.max then
                return RatingInfo.type
            end
        end
    end

    return SERVER_RANKS_DEFINITION.NONE
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

    local RealHero = GetRealHero(unit)
    if RealHero and RealHero:IsRealHero() and unit:IsHero() and not DebugPanel:IsDummy(unit) then
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
            is_admin = DebugPanel:IsDeveloper(event.PlayerID),
            title_status = false,
            loaded = false,
            ServerData = {
                SteamID = SteamID
            }
        }

        if SteamID ~= 0 then

            if table.contains(SERVER_PLAYERS_WITH_PERMANENT_PRIVILEGES, SteamID) then
                self.Players[event.PlayerID].ServerData.active = true
                self.Players[event.PlayerID].ServerData.permanent = true
            end

            self:UpdatePlayerNetTable(event.PlayerID)
            
            local CurrentCategory = GetCurrentCategory()

            cprint('[Server] Trying to get profile of '..event.PlayerID..' PlayerID and '..SteamID..' SteamID')

            self:SendRequest(SERVER_URL.."get_player_profile_rating", {SteamID=SteamID, Category=CurrentCategory}, function(ResultData)
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

    self.Players[PlayerID].loaded = true

    self:UpdatePlayerNetTable(PlayerID)
end

function Server:UpdatePlayerNetTable(PlayerID)
    if not self.Players[PlayerID] then return end

    CustomNetTables:SetTableValue("players", "player_"..PlayerID, self.Players[PlayerID].ServerData)
    CustomNetTables:SetTableValue("players", "player_"..PlayerID.."_special_info", {is_admin = self.Players[PlayerID].is_admin})
    if self.Players[PlayerID].is_admin == true then
        self.Players[PlayerID].title_status = true
        CustomNetTables:SetTableValue("players", "player_"..PlayerID.."_title_status", {status = self.Players[PlayerID].title_status})
    end

    CustomNetTables:SetTableValue("players", "player_"..PlayerID.."_steamid", {steamid=PlayerResource:GetSteamAccountID(PlayerID)})
end

function Server:SwitchTitleStatus(PlayerID)
    if not self.Players[PlayerID] then return end

    self.Players[PlayerID].title_status = not self.Players[PlayerID].title_status

    CustomNetTables:SetTableValue("players", "player_"..PlayerID.."_title_status", {status = self.Players[PlayerID].title_status})
end

function Server:OnAttemptGetLeaderboardInfo(event)
    local SteamIDs = {}
    for PlayerID, Data in pairs(self.Players) do
        local SteamID = PlayerResource:GetSteamAccountID(PlayerID)
        table.insert(SteamIDs, SteamID)
    end
    self:SendRequest(SERVER_URL.."get_leaderboard_info", {category = event.category, players = SteamIDs}, function(ResultData)
        CustomNetTables:SetTableValue('globals', "leaderboard_category_"..event.category, ResultData)

        CustomGameEventManager:Send_ServerToAllClients("server_leaderboard_update", {category = event.category})
    end, true)
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