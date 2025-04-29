--[[ events.lua ]]
---------------------------------------------------------------------------
-- Event: Game state change handler
---------------------------------------------------------------------------
function COverthrowGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()

	if nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		self:AssignTeams()

		if Is5v5() then
			self:ReplaceWinContidion()
		end

	elseif nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		local numberOfPlayers = PlayerResource:GetPlayerCount()
		if numberOfPlayers > 7 then
			nCOUNTDOWNTIMER = 1501
		elseif numberOfPlayers > 4 and numberOfPlayers <= 7 then
			nCOUNTDOWNTIMER = 1501
		elseif Is5v5() then
			nCOUNTDOWNTIMER = 15000
		else
			nCOUNTDOWNTIMER = 1501
		end
		
		self.TEAMS_MISSING = self:GetCountMissingTeams()
		self:ReduceCountdownTimer(self.TEAMS_MISSING)
		
		if GetMapName() == "overvodka_solo" then
			self.TEAM_KILLS_TO_WIN = self.KILLS_TO_WIN_SINGLES
		elseif GetMapName() == "overvodka_duo" then
			self.TEAM_KILLS_TO_WIN = self.KILLS_TO_WIN_DUOS
		elseif GetMapName() == "temple_quartet" then
			self.TEAM_KILLS_TO_WIN = self.KILLS_TO_WIN_QUADS
		elseif GetMapName() == "desert_quintet" then
			self.TEAM_KILLS_TO_WIN = self.KILLS_TO_WIN_QUINTS
		else
			self.TEAM_KILLS_TO_WIN = self.KILLS_TO_WIN_TRIOS
		end

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
		if not Is5v5() then
			self.countdownEnabled = true
			CustomGameEventManager:Send_ServerToAllClients( "show_timer", {} )
			DoEntFire( "center_experience_ring_particles", "Start", "0", 0, self, self  )

			GameRules:GetGameModeEntity():SetAnnouncerDisabled( true )
		else
			self.countdownEnabled = false
			local towers = Entities:FindAllByClassname( "npc_dota_tower" )
			for _, tower in pairs( towers ) do
				if not tower or tower:IsNull() then
				elseif tower:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
					tower:SetModel( "models/slots/tower_slot.vmdl" )
					tower:SetOriginalModel( "models/slots/tower_slot.vmdl" )
				elseif tower:GetTeamNumber() == DOTA_TEAM_BADGUYS then
					tower:SetModel( "models/hydrant/hydrant.vmdl" )
					tower:SetOriginalModel( "models/hydrant/hydrant.vmdl" )
				end
			end
			local roshan = Entities:FindAllByClassname( "npc_dota_roshan" )
			for _, rosh in pairs( roshan ) do
				if rosh and not rosh:IsNull() then
					AddFOWViewer( DOTA_TEAM_GOODGUYS, rosh:GetAbsOrigin(), 200, 2, false )
					AddFOWViewer( DOTA_TEAM_BADGUYS, rosh:GetAbsOrigin(), 200, 2, false )
					Timers:CreateTimer(0.1, function()
						rosh:SetModel( "models/shrek/shrek.vmdl" )
						rosh:SetOriginalModel( "models/shrek/shrek.vmdl" )
						rosh:SetModelScale( 4 )
					end)
				end
			end
		end
	end
end

function COverthrowGameMode:ReplaceWinContidion()
    local Structures = FindUnitsInRadius(
        DOTA_TEAM_GOODGUYS,
        Vector(0,0,0),
        nil,
        999999,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_BUILDING,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_ANY_ORDER,
        false
    )
    for _, Structure in ipairs(Structures) do
        if Structure:IsBuilding() then
            if Structure:IsFort() then
                Structure:AddNewModifier(Structure, nil, "modifier_win_condition", {})
            end
        end
    end
end

--------------------------------------------------------------------------------
-- Event: OnNPCSpawned
--------------------------------------------------------------------------------
golovach_spawned = 0
function COverthrowGameMode:OnNPCSpawned( event )
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if spawnedUnit:IsRealHero() then
		if spawnedUnit.bFirstSpawned == nil then
			spawnedUnit.bFirstSpawned = true
			local sahur = spawnedUnit:FindAbilityByName("sahur_hit")
			if sahur then
				sahur:SetLevel(1)
			end
			local ash = spawnedUnit:FindAbilityByName("imba_batrider_sticky_napalm_new")
			if ash then
				ash:SetLevel(1)
			end
			local pap = spawnedUnit:FindAbilityByName("papich_facet_regen")
			if pap then
				pap:SetLevel(1)
			end
			local dave = spawnedUnit:FindAbilityByName("dave_ambient")
			if dave then
				dave:SetLevel(1)
			end
			if GetMapName() == "overvodka_5x5" then
				if spawnedUnit:GetUnitName() == "npc_dota_hero_pudge" then
					spawnedUnit:SwapAbilities("kachok_abstention","kachok_abstention_dota", false, true)
				end
				if spawnedUnit:GetUnitName() == "npc_dota_hero_slark" then
					spawnedUnit:SwapAbilities("bratishkin_r","bratishkin_r_dota", false, true)
				end
				if spawnedUnit:GetUnitName() == "npc_dota_hero_necrolyte" then
					spawnedUnit:SwapAbilities("peterka_w","peterka_w_dota", false, true)
				end
				if spawnedUnit:GetUnitName() == "npc_dota_hero_rubick" then
					spawnedUnit:SwapAbilities("worstsup_q","worstsup_q_dota", false, true)
				end
				if spawnedUnit:GetUnitName() == "npc_dota_hero_weaver" then
					spawnedUnit:SwapAbilities("azazin_e","azazin_e_dota", false, true)
				end
				if spawnedUnit:GetUnitName() == "npc_dota_hero_riki" then
					spawnedUnit:SwapAbilities("stray_r","stray_r_dota", false, true)
				end
			end
	  	end
		if spawnedUnit:GetUnitName() == "npc_dota_hero_antimage" then
			spawnedUnit.weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/god.vmdl"})
			spawnedUnit.weapon:FollowEntity(spawnedUnit, true)
		end
		if spawnedUnit:GetUnitName() == "npc_dota_hero_invoker" then
			local cigarette = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/dvoreckov/cigarette.vmdl"})
				cigarette:FollowEntity(spawnedUnit, true)
				cigarette:SetParent(spawnedUnit, "attach_mouth")
				cigarette:SetLocalOrigin(Vector(1, -1, 0))
				cigarette:SetLocalAngles(0, 0, 0)
		end
		if spawnedUnit:GetUnitName() == "npc_dota_hero_juggernaut" and golovach_spawned == 0 then
			spawnedUnit:FindAbilityByName("golovach_innate"):StartCooldown(spawnedUnit:FindAbilityByName("golovach_innate"):GetCooldown(1))
			golovach_spawned = golovach_spawned + 1
		end
		-- Destroys the last hit effects
		local deathEffects = spawnedUnit:Attribute_GetIntValue( "effectsID", -1 )
		if deathEffects ~= -1 then
			ParticleManager:DestroyParticle( deathEffects, true )
			spawnedUnit:DeleteAttribute( "effectsID" )
		end
		if self.allSpawned == false then
			if GetMapName() == "mines_trio" then
				local unitTeam = spawnedUnit:GetTeam()
				local particleSpawn = ParticleManager:CreateParticleForTeam( "particles/addons_gameplay/player_deferred_light.vpcf", PATTACH_ABSORIGIN, spawnedUnit, unitTeam )
				ParticleManager:SetParticleControlEnt( particleSpawn, PATTACH_ABSORIGIN, spawnedUnit, PATTACH_ABSORIGIN, "attach_origin", spawnedUnit:GetAbsOrigin(), true )
			end
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
		if GetMapName() ~= "overvodka_5x5" then
			for i = 0, 8 do
				local item = hPlayerHero:GetItemInSlot(i)
				if item and item:GetAbilityName() == "item_tpscroll" then
					hPlayerHero:RemoveItem(item)
					break
				end
			end
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

	local Kills = IsComebackTeam(nTeamID) and 2 or 1
	self:IncrementTeamHeroKills(nTeamID, Kills)

	local nTeamKills = self:GetTeamHeroKills(nTeamID)
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
		kills_count=Kills,
	}

	self.bFirstBlooded = true

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

	if nCOUNTDOWNTIMER <= self.MIN_COUNTDOWN_TIME then
		local SortedTeams = self:GetSortedValidActiveTeams()

		CustomNetTables:SetTableValue("globals", "teams_top", SortedTeams)
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

	if killedUnit:IsRealHero() then
		self.allSpawned = true
		if hero:IsRealHero() == true then
			if event.entindex_inflictor ~= nil then
				local inflictor_index = event.entindex_inflictor
				if inflictor_index ~= nil then
					local ability = EntIndexToHScript( event.entindex_inflictor )
				end
			end
		end
		if hero:IsRealHero() and heroTeam ~= killedTeam then
			--print("Granting killer xp")
			if killedUnit:GetTeam() == self.leadingTeam and self.isGameTied == false and GetMapName() ~= "overvodka_5x5" then
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
	if killedTeam == self.leadingTeam and self.isGameTied == false and GetMapName() ~= "overvodka_5x5" then
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
	if GetMapName() == "overvodka_5x5" then
		extraTime = killedUnit:GetLevel() * 2
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
	local function RemoveItemByName(unit, itemName)
		for i = 0, 8 do
			local item = unit:GetItemInSlot(i)
			if item and item:GetAbilityName() == itemName then
				unit:RemoveItem(item)
				break
			end
		end
	end
	if event.itemname == "item_bag_of_gold" then
		if owner:GetUnitName() == "npc_dota_hero_necrolyte" then
			ApplyDamage( { victim = owner, attacker = owner, damage = owner:GetHealth() * 0.2, damage_type = DAMAGE_TYPE_PURE } )
		end
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
			r = 300
			if GetMapName() == "overvodka_5x5" then
				r = 50
			end
			if heroes[i]:GetUnitName() == "npc_dota_hero_bounty_hunter" and not heroes[i]:IsIllusion() then
				r = 600
				if GetMapName() == "overvodka_5x5" then
					r = 100
				end
			end
			if heroes[i]:GetUnitName() == "npc_dota_hero_skeleton_king" and heroes[i]:IsTempestDouble() then
				r = 0
			end
			local Team = PlayerResource:GetTeam(playerID)
			local newR = ChangeValueByTeamPlace(r, Team)
			PlayerResource:ModifyGold( playerID, newR, false, 0 )
			SendOverheadEventMessage( heroes[i], OVERHEAD_ALERT_GOLD, heroes[i], newR, nil )
		end
		UTIL_Remove( item )
	elseif event.itemname == "item_bag_of_gold_2" then
		if owner:GetUnitName() ~= "npc_dota_hero_necrolyte" then
			ApplyDamage( { victim = owner, attacker = owner, damage = owner:GetHealth() * 0.3, damage_type = DAMAGE_TYPE_PURE } )
			EmitSoundOn("peterka_shard", owner)
		else
			ApplyDamage( { victim = owner, attacker = owner, damage = owner:GetHealth() * 0.2, damage_type = DAMAGE_TYPE_PURE } )
			SendOverheadEventMessage( owner, OVERHEAD_ALERT_GOLD, owner, 300, nil )
		end
		UTIL_Remove( item )
	elseif event.itemname == "item_bag_of_gold_bablokrad" then
		if owner:GetUnitName() == "npc_dota_hero_necrolyte" then
			ApplyDamage( { victim = owner, attacker = owner, damage = owner:GetHealth() * 0.2, damage_type = DAMAGE_TYPE_PURE } )
		end
		local rewerd = 100
		if owner:GetUnitName() == "npc_dota_hero_bounty_hunter" then
			rewerd = 200
		end
		local playerID = owner:GetPlayerID()
		PlayerResource:ModifyGold( playerID, rewerd, false, 0 )
		SendOverheadEventMessage( owner, OVERHEAD_ALERT_GOLD, owner, rewerd, nil )
		UTIL_Remove( item )
	elseif event.itemname == "item_treasure_chest" then
		local treasureItemName = event.itemname
		local hContainer = item:GetContainer()
		for k, v in pairs(self.itemSpawnLocationsInUse) do
			if v.hDrop == hContainer then
				if v.hItemDestinationRevealer then
					v.hItemDestinationRevealer:RemoveSelf()
					ParticleManager:DestroyParticle(v.nItemDestinationParticles, false)
					DoEntFire(v.world_effects_name, "Stop", "0", 0, self, self)
				end
				table.insert(self.itemSpawnLocations, v)
				table.remove(self.itemSpawnLocationsInUse, k)
				break
			end
		end
		COverthrowGameMode:SpecialItemAdd(event)
		Timers:CreateTimer(0.03, function()
			RemoveItemByName(owner, treasureItemName)
			UTIL_Remove(item)
			local bonusItem = CreateItem("item_madstone_bundle", owner, owner)
			owner:AddItem(bonusItem)
		end)
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
