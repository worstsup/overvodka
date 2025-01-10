--[[ events.lua ]]
---------------------------------------------------------------------------
-- Event: Game state change handler
---------------------------------------------------------------------------
function COverthrowGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	--print( "OnGameRulesStateChange: " .. nNewState )

	if nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		self:AssignTeams()

	elseif nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		local numberOfPlayers = PlayerResource:GetPlayerCount()
		if numberOfPlayers > 7 then
			--self.TEAM_KILLS_TO_WIN = 25
			nCOUNTDOWNTIMER = 1501
		elseif numberOfPlayers > 4 and numberOfPlayers <= 7 then
			--self.TEAM_KILLS_TO_WIN = 20
			nCOUNTDOWNTIMER = 1501
		else
			--self.TEAM_KILLS_TO_WIN = 15
			nCOUNTDOWNTIMER = 1501
		end
		
		if GetMapName() == "forest_solo" then
			self.TEAM_KILLS_TO_WIN = self.KILLS_TO_WIN_SINGLES
		elseif GetMapName() == "desert_duo" then
			self.TEAM_KILLS_TO_WIN = self.KILLS_TO_WIN_DUOS
		elseif GetMapName() == "temple_quartet" then
			self.TEAM_KILLS_TO_WIN = self.KILLS_TO_WIN_QUADS
		elseif GetMapName() == "desert_quintet" then
			self.TEAM_KILLS_TO_WIN = self.KILLS_TO_WIN_QUINTS
		else
			self.TEAM_KILLS_TO_WIN = self.KILLS_TO_WIN_TRIOS
		end
		--print( "Kills to win = " .. tostring(self.TEAM_KILLS_TO_WIN) )

		CustomNetTables:SetTableValue( "game_state", "victory_condition", { kills_to_win = self.TEAM_KILLS_TO_WIN } );

		self._fPreGameStartTime = GameRules:GetGameTime()

	elseif nNewState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
		-- random for all players that haven't chosen yet
		for nPlayerID = 0, ( DOTA_MAX_TEAM_PLAYERS - 1 ) do
			local hPlayer = PlayerResource:GetPlayer( nPlayerID )
			if hPlayer and not PlayerResource:HasSelectedHero( nPlayerID ) then
				hPlayer:MakeRandomHeroSelection()
			end	
		end

	elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "OnGameRulesStateChange: Game In Progress" )
		self.countdownEnabled = true
		CustomGameEventManager:Send_ServerToAllClients( "show_timer", {} )
		DoEntFire( "center_experience_ring_particles", "Start", "0", 0, self, self  )

		GameRules:GetGameModeEntity():SetAnnouncerDisabled( true ) -- Disable the normal announcer at game start
	end
end

--------------------------------------------------------------------------------
-- Event: OnNPCSpawned
--------------------------------------------------------------------------------
function COverthrowGameMode:OnNPCSpawned( event )
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if spawnedUnit:IsRealHero() then
		if spawnedUnit:GetUnitName() == "npc_dota_hero_meepo" then
			if spawnedUnit:HasModifier("modifier_item_aghanims_shard") then
				spawnedUnit:AddItemByName("item_lesh")
			end
		end
		if spawnedUnit:GetUnitName() == "npc_dota_hero_antimage" then
			spawnedUnit.weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/god.vmdl"})
			spawnedUnit.weapon:FollowEntity(spawnedUnit, true)
		end
		-- Destroys the last hit effects
		local deathEffects = spawnedUnit:Attribute_GetIntValue( "effectsID", -1 )
		if deathEffects ~= -1 then
			ParticleManager:DestroyParticle( deathEffects, true )
			spawnedUnit:DeleteAttribute( "effectsID" )
		end
		if self.allSpawned == false then
			if GetMapName() == "mines_trio" then
				--print("mines_trio is the map")
				--print("self.allSpawned is " .. tostring(self.allSpawned) )
				local unitTeam = spawnedUnit:GetTeam()
				local particleSpawn = ParticleManager:CreateParticleForTeam( "particles/addons_gameplay/player_deferred_light.vpcf", PATTACH_ABSORIGIN, spawnedUnit, unitTeam )
				ParticleManager:SetParticleControlEnt( particleSpawn, PATTACH_ABSORIGIN, spawnedUnit, PATTACH_ABSORIGIN, "attach_origin", spawnedUnit:GetAbsOrigin(), true )
			end
		end
	end
	if spawnedUnit.bFirstSpawned == nil then ---если юнит герой и это первый его спавн находишь у него скилл и апаешь скиллу 1 уровень
      	spawnedUnit.bFirstSpawned = true
      	if spawnedUnit:IsRealHero() then
      		ParticleManager:CreateParticleForPlayer("particles/rain_fx/econ_snow.vpcf", PATTACH_EYES_FOLLOW, spawnedUnit, spawnedUnit:GetPlayerOwner())
      	end
            local ab = spawnedUnit:FindAbilityByName("sidet")
		if ab then
            	ab:SetLevel(1)
		end
		local ash = spawnedUnit:FindAbilityByName("imba_batrider_sticky_napalm_new")
		if ash then
			ash:SetLevel(1)
		end
		local pap = spawnedUnit:FindAbilityByName("amplify_regen_ability")
		if pap then
			pap:SetLevel(1)
		end
		local papich = spawnedUnit:FindAbilityByName("papich_e")
		if papich then
			papich:SetLevel(1)
		end
		local dave = spawnedUnit:FindAbilityByName("dave_ambient")
		if dave then
			dave:SetLevel(1)
		end
      end
	
end
---------------------------------------------------------
-- dota_on_hero_finish_spawn
-- * heroindex
-- * hero  		(string)
---------------------------------------------------------

function COverthrowGameMode:OnHeroFinishSpawn( event )
	local hPlayerHero = EntIndexToHScript( event.heroindex )
	if hPlayerHero ~= nil and hPlayerHero:IsRealHero() then
		local hTP = hPlayerHero:FindItemInInventory( "item_tpscroll" )
		if hTP ~= nil then
			UTIL_Remove( hTP )
		end
	end
end

--------------------------------------------------------------------------------
-- Event: BountyRunePickupFilter
--------------------------------------------------------------------------------
function COverthrowGameMode:BountyRunePickupFilter( filterTable )
      filterTable["xp_bounty"] = 2*filterTable["xp_bounty"]
      filterTable["gold_bounty"] = 2*filterTable["gold_bounty"]
      return true
end

---------------------------------------------------------------------------
-- Event: OnTeamKillCredit, see if anyone won
---------------------------------------------------------------------------
function COverthrowGameMode:OnTeamKillCredit( event )
--	print( "OnKillCredit" )
--	DeepPrint( event )

	local nKillerID = event.killer_userid
	local nTeamID = event.teamnumber
	local nTeamKills = event.herokills
	local nKillsRemaining = self.TEAM_KILLS_TO_WIN - nTeamKills
	
	local broadcast_kill_event =
	{
		killer_id = event.killer_userid,
		team_id = event.teamnumber,
		team_kills = nTeamKills,
		kills_remaining = nKillsRemaining,
		victory = 0,
		close_to_victory = 0,
		very_close_to_victory = 0,
	}

	if nKillsRemaining <= 0 then
		GameRules:SetCustomVictoryMessage( self.m_VictoryMessages[nTeamID] )
		
		self:EndGame( nTeamID )
		
		broadcast_kill_event.victory = 1
	elseif nKillsRemaining == 1 then
		EmitGlobalSound( "ui.npe_objective_complete" )
		broadcast_kill_event.very_close_to_victory = 1
	elseif nKillsRemaining <= self.CLOSE_TO_VICTORY_THRESHOLD then
		EmitGlobalSound( "ui.npe_objective_given" )
		broadcast_kill_event.close_to_victory = 1
	end

	CustomGameEventManager:Send_ServerToAllClients( "kill_event", broadcast_kill_event )
end

connectedPlayers = {}

function COverthrowGameMode:OnGameInProgress()
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:IsValidPlayer(playerID) then
            connectedPlayers[playerID] = true
        end
    end

    Timers:CreateTimer(1.0, function()
        CheckPlayerConnections()
        return 1.0 -- Repeat every second
    end)
end

function CheckPlayerConnections()
    local teamAliveCount = {}
    for team = DOTA_TEAM_FIRST, DOTA_TEAM_CUSTOM_MAX do
        teamAliveCount[team] = 0
    end

    for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:IsValidPlayer(playerID) then
            local isConnected = PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED
            connectedPlayers[playerID] = isConnected
            if isConnected and PlayerResource:IsAlive(playerID) then
                local team = PlayerResource:GetTeam(playerID)
                if teamAliveCount[team] ~= nil then
                    teamAliveCount[team] = teamAliveCount[team] + 1
                end
            end
        end
    end
    local teamsWithPlayers = 0
    local lastTeamStanding = nil

    for team, count in pairs(teamAliveCount) do
        if count > 0 then
            teamsWithPlayers = teamsWithPlayers + 1
            lastTeamStanding = team
        end
    end
    if teamsWithPlayers == 1 and lastTeamStanding ~= nil then
        COverthrowGameMode:EndGame( lastTeamStanding )
    end
end

function COverthrowGameMode:OnPlayerDisconnect( event )
    local playerID = event.PlayerID
    if PlayerResource:IsValidPlayer(playerID) then
        connectedPlayers[playerID] = false
    end
end

function COverthrowGameMode:OnPlayerReconnect( event )
    local playerID = event.PlayerID
    if PlayerResource:IsValidPlayer(playerID) then
        connectedPlayers[playerID] = true
    end
end
---------------------------------------------------------------------------
-- Event: OnEntityKilled
---------------------------------------------------------------------------
function COverthrowGameMode:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	local killedTeam = killedUnit:GetTeam()
	if killedUnit:IsTempestDouble() then return end
	local hero = EntIndexToHScript( event.entindex_attacker )
	local heroTeam = hero:GetTeam()
	local extraTime = 0
	if killedUnit:GetUnitName() == "npc_dota_roshan" then
		if hero:IsRealHero() == true then
			hero:AddItemByName("item_aegis")
		end
	end

	if killedUnit:IsRealHero() then
		self.allSpawned = true
		--print("Hero has been killed")
		--Add extra time if killed by Necro Ult
		if hero:IsRealHero() == true then
			if event.entindex_inflictor ~= nil then
				local inflictor_index = event.entindex_inflictor
				if inflictor_index ~= nil then
					local ability = EntIndexToHScript( event.entindex_inflictor )
					if ability ~= nil then
						if ability:GetAbilityName() ~= nil then
							if ability:GetAbilityName() == "necrolyte_reapers_scythe" then
								print("Killed by Necro Ult")
								extraTime = 20
							end
						end
					end
				end
			end
		end
		if hero:IsRealHero() and heroTeam ~= killedTeam then
			--print("Granting killer xp")
			if killedUnit:GetTeam() == self.leadingTeam and self.isGameTied == false then
				local memberID = hero:GetPlayerID()
				PlayerResource:ModifyGold( memberID, 500, false, 0 )
				hero:AddExperience( 100, 0, false, false )
				local name = hero:GetClassname()
				local victim = killedUnit:GetClassname()
				local kill_alert =
					{
						hero_id = hero:GetClassname()
					}
				CustomGameEventManager:Send_ServerToAllClients( "kill_alert", kill_alert )
			else
				hero:AddExperience( 50, 0, false, false )
			end
		end
		--Granting XP to all heroes who assisted
		local allHeroes = HeroList:GetAllHeroes()
		for _,attacker in pairs( allHeroes ) do
			--print(killedUnit:GetNumAttackers())
			for i = 0, killedUnit:GetNumAttackers() - 1 do
				if attacker == killedUnit:GetAttacker( i ) then
					--print("Granting assist xp")
					attacker:AddExperience( 25, 0, false, false )
				end
			end
		end
		if killedUnit:GetRespawnTime() > 10 then
			if killedUnit:IsReincarnating() == true then
				return nil
			else
				COverthrowGameMode:SetRespawnTime( killedTeam, killedUnit, extraTime )
			end
		else
			COverthrowGameMode:SetRespawnTime( killedTeam, killedUnit, extraTime )
		end
	end
end

function COverthrowGameMode:SetRespawnTime( killedTeam, killedUnit, extraTime )
	--print("Setting time for respawn")
	if killedUnit:GetUnitName() == "npc_dota_lone_druid_bear" then
		extraTime = 1000
	end
	if killedTeam == self.leadingTeam and self.isGameTied == false then
		if killedUnit:FindItemInInventory("item_aegis") then
			extraTime = -15
		end
		if killedUnit:GetUnitName() == "npc_dota_hero_juggernaut" then
			if killedUnit:IsReincarnating() then
				extraTime = -16
			end
		end
		killedUnit:SetTimeUntilRespawn( 20 + extraTime )
	else
		if killedUnit:FindItemInInventory("item_aegis") then
			extraTime = -5
		end
		if killedUnit:GetUnitName() == "npc_dota_hero_juggernaut" then
			if killedUnit:IsReincarnating() then
				extraTime = -6
			end
		end
		killedUnit:SetTimeUntilRespawn( 10 + extraTime )
	end
end


--------------------------------------------------------------------------------
-- Event: OnItemPickUp
--------------------------------------------------------------------------------
function COverthrowGameMode:OnItemPickUp( event )
	local item = EntIndexToHScript( event.ItemEntityIndex )
	local owner = EntIndexToHScript( event.HeroEntityIndex )
	r = 300
	--r = RandomInt(200, 400)
	if event.itemname == "item_bag_of_gold" then
		local heroes = FindUnitsInRadius(owner:GetTeamNumber(),
							owner:GetAbsOrigin(),
							nil,
							10000,
							DOTA_UNIT_TARGET_TEAM_FRIENDLY,
							DOTA_UNIT_TARGET_HERO,
							DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
							FIND_ANY_ORDER,
							false )
		for i = 1, #heroes do
			local playerID = heroes[i]:GetPlayerID()
			if heroes[i]:GetUnitName() == "npc_dota_hero_bounty_hunter" and not heroes[i]:IsIllusion() then
				r = 600
			else
				if heroes[i]:GetUnitName() == "npc_dota_hero_undying" then
					r = 0
				else
					r = 300
				end
			end

			local Team = PlayerResource:GetTeam(playerID)

			local newR = ChangeValueByTeamPlace(r, Team)

			--print("Bag of gold picked up")
			PlayerResource:ModifyGold( playerID, newR, false, 0 )
			SendOverheadEventMessage( heroes[i], OVERHEAD_ALERT_GOLD, heroes[i], newR, nil )
		end
		UTIL_Remove( item ) -- otherwise it pollutes the player inventory
	elseif event.itemname == "item_treasure_chest" then
		print( "Special Item Picked Up" )

		if item.GetAbilityName ~= nil then
			--print( "Item is named: - " .. item:GetAbilityName() )
		end

		local hContainer = item:GetContainer()

		for k,v in pairs ( self.itemSpawnLocationsInUse ) do
			if v.hDrop == hContainer then
				--print( '^^^DROP CONTAINER!' )
				if v.hItemDestinationRevealer then
					v.hItemDestinationRevealer:RemoveSelf()
					ParticleManager:DestroyParticle( v.nItemDestinationParticles, false )
					DoEntFire( v.world_effects_name, "Stop", "0", 0, self, self )
				end
				
				table.insert( self.itemSpawnLocations, v )
				table.remove( self.itemSpawnLocationsInUse, k )
				break
			end
		end
		
		COverthrowGameMode:SpecialItemAdd( event )
		UTIL_Remove( item ) -- otherwise it pollutes the player inventory
	end
end


--------------------------------------------------------------------------------
-- Event: OnNpcGoalReached
--------------------------------------------------------------------------------
function COverthrowGameMode:OnNpcGoalReached( event )
	local npc = EntIndexToHScript( event.npc_entindex )
	if npc:GetUnitName() == "npc_dota_treasure_courier" then
		COverthrowGameMode:TreasureDrop( npc )
	end
end
