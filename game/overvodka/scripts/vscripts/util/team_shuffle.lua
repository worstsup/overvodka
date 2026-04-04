if TeamShuffle == nil then
    TeamShuffle = class({})
end

function TeamShuffle:Init()
    if self.initialized then
        return
    end

    self.initialized = true

    CustomGameEventManager:RegisterListener("team_selection_shuffle_request", function(_, event)
        self:OnShuffleRequest(event)
    end)
end

function TeamShuffle:OnShuffleRequest(event)
    local playerID = event and event.PlayerID or -1
    if not PlayerResource:IsValidPlayerID(playerID) then return end
    if IsSolo() then return end
    if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then return end

    local player = PlayerResource:GetPlayer(playerID)
    if not player or not GameRules:PlayerHasCustomGameHostPrivileges(player) then return end

    self:ShuffleTeams()
end

function TeamShuffle:GetValidTeamIDs()
    local team_ids = {}

    if OvervodkaGameMode and OvervodkaGameMode.m_GatheredShuffledTeams then
        for _, team_id in pairs(OvervodkaGameMode.m_GatheredShuffledTeams) do
            if GameRules:GetCustomGameTeamMaxPlayers(team_id) > 0 then
                table.insert(team_ids, team_id)
            end
        end
    end

    if #team_ids > 0 then
        return team_ids
    end

    for team_id = DOTA_TEAM_FIRST, DOTA_TEAM_CUSTOM_MAX do
        if GameRules:GetCustomGameTeamMaxPlayers(team_id) > 0 then
            table.insert(team_ids, team_id)
        end
    end

    return team_ids
end

function TeamShuffle:GetEligiblePlayerIDs()
    local player_ids = {}
    local max_players = DOTA_MAX_TEAM_PLAYERS or 24

    for player_id = 0, max_players - 1 do
        if PlayerResource:IsValidPlayerID(player_id) then
            local player = PlayerResource:GetPlayer(player_id)
            local state = PlayerResource:GetConnectionState(player_id)

            if player and state ~= DOTA_CONNECTION_STATE_UNKNOWN and state ~= DOTA_CONNECTION_STATE_NOT_YET_CONNECTED then
                table.insert(player_ids, player_id)
            end
        end
    end

    return player_ids
end

function TeamShuffle:ApplyPlayerTeam(player_id, team_id)
    if not PlayerResource:IsValidPlayerID(player_id) then return end

    PlayerResource:SetCustomTeamAssignment(player_id, team_id)
    PlayerResource:UpdateTeamSlot(player_id, team_id, -1)

    local player = PlayerResource:GetPlayer(player_id)
    if player and not player:IsNull() then
        player:SetTeam(team_id)
    end
end

function TeamShuffle:SortPartiesBySize(parties)
    local parties_by_size = {}

    for party_id, players in pairs(parties) do
        table.insert(parties_by_size, { party_id = party_id, size = #players })
    end

    table.sort(parties_by_size, function(a, b)
        if a.size == b.size then
            return a.party_id < b.party_id
        end

        return a.size > b.size
    end)

    return parties_by_size
end

function TeamShuffle:DistributeParties(parties, parties_by_size, team_entries)
    for _, party_entry in ipairs(parties_by_size) do
        local party_id = party_entry.party_id
        local party_players = parties[party_id]
        local party_size = party_entry.size

        table.sort(team_entries, function(a, b)
            if a.party_players == b.party_players then
                if #a.players == #b.players then
                    return a.team_id < b.team_id
                end

                return #a.players < #b.players
            end

            return a.party_players < b.party_players
        end)

        for _, team_entry in ipairs(team_entries) do
            if (#team_entry.players + party_size) <= team_entry.capacity then
                for _, player_id in ipairs(party_players) do
                    table.insert(team_entry.players, player_id)
                end

                team_entry.party_players = team_entry.party_players + party_size
                parties[party_id] = nil
                break
            end
        end
    end
end

function TeamShuffle:ShuffleTeams()
    local team_ids = self:GetValidTeamIDs()
    if #team_ids <= 1 then
        return
    end

    local team_entries = {}
    local max_team_capacity = 0
    for _, team_id in ipairs(team_ids) do
        local capacity = GameRules:GetCustomGameTeamMaxPlayers(team_id)
        max_team_capacity = math.max(max_team_capacity, capacity)
        table.insert(team_entries, {
            team_id = team_id,
            capacity = capacity,
            players = {},
            party_players = 0,
        })
    end

    if max_team_capacity <= 1 then
        return
    end

    local parties = {}
    local solo_players = {}

    for _, player_id in ipairs(self:GetEligiblePlayerIDs()) do
        local party_id = tonumber(tostring(PlayerResource:GetPartyID(player_id))) or 0

        if party_id > 0 then
            parties[party_id] = parties[party_id] or {}
            if #parties[party_id] >= max_team_capacity then
                table.insert(solo_players, player_id)
            else
                table.insert(parties[party_id], player_id)
            end
        else
            table.insert(solo_players, player_id)
        end
    end

    local parties_by_size = self:SortPartiesBySize(parties)
    self:DistributeParties(parties, parties_by_size, team_entries)

    for _, remaining_players in pairs(parties) do
        for _, player_id in ipairs(remaining_players) do
            table.insert(solo_players, player_id)
        end
    end

    solo_players = ShuffledList(solo_players)

    for _, team_entry in ipairs(team_entries) do
        while #team_entry.players < team_entry.capacity and #solo_players > 0 do
            table.insert(team_entry.players, table.remove(solo_players, 1))
        end
    end

    local shuffled_team_ids = ShuffledList(team_ids)

    for index, team_entry in ipairs(team_entries) do
        local target_team_id = shuffled_team_ids[index] or team_entry.team_id
        for _, player_id in ipairs(team_entry.players) do
            self:ApplyPlayerTeam(player_id, target_team_id)
        end
    end
end

TeamShuffle:Init()