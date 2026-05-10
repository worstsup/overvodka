--[[ events.lua ]]
---------------------------------------------------------------------------
-- Event: Game state change handler
---------------------------------------------------------------------------
function OvervodkaGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	local bShowCustomLoadingScreen =
		nNewState == DOTA_GAMERULES_STATE_INIT or
		nNewState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD or
		nNewState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP

	CustomGameEventManager:Send_ServerToAllClients("custom_loading_screen_state", {
		visible = bShowCustomLoadingScreen and 1 or 0
	})

	if nNewState == DOTA_GAMERULES_STATE_INIT then
        CustomGameEventManager:Send_ServerToAllClients("gamesetup", nil)
	elseif nNewState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		if TeamShuffle and TeamShuffle.StartSetupAutoShuffle then
			TeamShuffle:StartSetupAutoShuffle()
		end
	elseif nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		self:AssignTeams()
		CustomGameEventManager:Send_ServerToAllClients("hero_selection", nil)
		if Is5v5() then
			self:ReplaceWinContidion()
		end
	elseif nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		self:AssignTeams()
		OvervodkaGameMode:UpdateMute(_, _, _)
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
		self:ReduceCountdownTimer(self:GetCountdownReductionCount(self.TEAMS_MISSING))
		
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
		if not IsInToolsMode() and GetMapName() ~= "overvodka_5x5" then
			Convars:SetFloat("host_timescale", 0.25)
			Timers:CreateTimer({
				useGameTime = false,
				endTime = 1.5,
				callback = function()
					Convars:SetFloat("host_timescale", 1)
				end
			})
		end
	elseif nNewState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
		-- random for all players that haven't chosen yet
		for nPlayerID = 0, ( DOTA_MAX_TEAM_PLAYERS - 1 ) do
			local hPlayer = PlayerResource:GetPlayer( nPlayerID )
			if hPlayer and not PlayerResource:HasSelectedHero( nPlayerID ) then
				hPlayer:MakeRandomHeroSelection()
			end	
		end

	elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		if ChaosOrb and ChaosOrb.Init then
			ChaosOrb:Init(self)
		end

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

function OvervodkaGameMode:ReplaceWinContidion()
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

function OvervodkaGameMode:OnHeroSelected(event)
	local player = PlayerResource:GetPlayer(event.player_id)
	if not player then
		return
	end

	if event.hero_unit == "npc_dota_hero_morphling" then
		local equippedSkin = Store and Store.playerData and Store.playerData[event.player_id] and Store.playerData[event.player_id].equipped_skin
		local soundName = equippedSkin == "sans_arcana" and "sans_arcana_start" or "sans_start"
		CustomGameEventManager:Send_ServerToPlayer(player, "sans_pick_music_start", {
			sound_name = soundName
		})
	elseif event.hero_unit == "npc_dota_hero_bounty_hunter" then
		local equippedSkin = Store and Store.playerData and Store.playerData[event.player_id] and Store.playerData[event.player_id].equipped_skin
		local soundName = equippedSkin == "skin_14" and "mell_start_arcana" or "mell_start"
		CustomGameEventManager:Send_ServerToPlayer(player, "sans_pick_music_start", {
			sound_name = soundName
		})
	else
		CustomGameEventManager:Send_ServerToPlayer(player, "sans_pick_music_stop", {})
	end
end
--------------------------------------------------------------------------------
-- Event: OnNPCSpawned
--------------------------------------------------------------------------------
golovach_spawned = 0
function OvervodkaGameMode:OnNPCSpawned( event )
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if spawnedUnit:IsRealHero() then
		if ChaosOrb and ChaosOrb.OnHeroSpawned then
			ChaosOrb:OnHeroSpawned(spawnedUnit)
		end

		if spawnedUnit.bFirstSpawned == nil then
			spawnedUnit.bFirstSpawned = true
			--if not spawnedUnit:IsIllusion() then
				--ParticleManager:CreateParticleForPlayer("particles/rain_fx/econ_snow.vpcf", PATTACH_EYES_FOLLOW, spawnedUnit, PlayerResource:GetPlayer(spawnedUnit:GetPlayerID()))
			--end
			if spawnedUnit:GetUnitName() == "npc_dota_hero_hoodwink" and not spawnedUnit:IsIllusion() and not spawnedUnit:HasModifier("modifier_mazellov_r") then
				EmitGlobalSound("Leon.Game.Start")
			end
			if spawnedUnit:GetUnitName() == "npc_dota_hero_slardar" then
				spawnedUnit.weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/pistoletov/mechalexpistol.vmdl"})
				spawnedUnit.weapon:FollowEntity(spawnedUnit, true)
				spawnedUnit.weapon:SetParent(spawnedUnit, "attach_sword")
				spawnedUnit.weapon:SetLocalOrigin(Vector(0, 0, 0))
				spawnedUnit.weapon:SetLocalAngles(0, 0, 0)
				spawnedUnit.weapon:SetModelScale(0.5)
			end
			if spawnedUnit:GetUnitName() == "npc_dota_hero_beastmaster" then
				spawnedUnit.weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/epstein/folder.vmdl"})
				spawnedUnit.weapon:FollowEntity(spawnedUnit, true)
				spawnedUnit.weapon:SetParent(spawnedUnit, "attach_weapon")
				spawnedUnit.weapon:SetLocalOrigin(Vector(0, 0, 0))
				spawnedUnit.weapon:SetLocalAngles(0, 0, 0)
				spawnedUnit.weapon:SetModelScale(0.5)
			end
			if spawnedUnit:GetUnitName() == "npc_dota_hero_abaddon" then
				spawnedUnit.voice_level = 0
			end
			if spawnedUnit:GetUnitName() == "npc_dota_hero_phoenix" and spawnedUnit:HasAbility("silvername_q_facet_2") then
				Timers:CreateTimer(0.2, function()
					if spawnedUnit then
						chair = spawnedUnit:AddItemByName("item_silvername_chair")
						chair:SetSellable(false)
					end
				end)
			end
			local sahur = spawnedUnit:FindAbilityByName("sahur_hit")
			if sahur then
				sahur:SetLevel(1)
			end
			local visitor_d = spawnedUnit:FindAbilityByName("visitor_d")
			if visitor_d then
				visitor_d:SetLevel(1)
			end
			local mazellov_f = spawnedUnit:FindAbilityByName("mazellov_f")
			if mazellov_f then
				mazellov_f:SetLevel(1)
			end
			local amor_f = spawnedUnit:FindAbilityByName("amor_f")
			if amor_f then
				amor_f:SetLevel(1)
			end
			local ash = spawnedUnit:FindAbilityByName("ashab_innate_new")
			if ash then
				ash:SetLevel(1)
			end
			local pap = spawnedUnit:FindAbilityByName("papich_facet_regen")
			if pap then
				pap:SetLevel(1)
			end
			local chara = spawnedUnit:FindAbilityByName("chara_f")
			if chara then
				chara:SetLevel(1)
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
				if spawnedUnit:GetUnitName() == "npc_dota_hero_riki" then
					spawnedUnit:SwapAbilities("stray_r","stray_r_dota", false, true)
				end
				if spawnedUnit:GetUnitName() == "npc_dota_hero_ursa" then
					spawnedUnit:SwapAbilities("litvin_zhishi","litvin_zhishi_dota", false, true)
				end
			end
	  	end
		if spawnedUnit:GetUnitName() == "npc_dota_hero_puck" then
			spawnedUnit.a = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/lion/lion_ti9_immortal_head/lion_ti9_immortal_head.vmdl"})
			spawnedUnit.a:FollowEntity(spawnedUnit, true)
			spawnedUnit.b = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/lion/hell_weapon/hell_weapon.vmdl"})
			spawnedUnit.b:FollowEntity(spawnedUnit, true)
			spawnedUnit.c = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/lion/hellclaw_of_maelrawn/hellclaw_of_maelrawn.vmdl"})
			spawnedUnit.c:FollowEntity(spawnedUnit, true)
		end
		if spawnedUnit:GetUnitName() == "npc_dota_hero_phoenix" then
			local weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/ogre_magi/ogre_magi_weapon.vmdl"})
			weapon:FollowEntity(spawnedUnit, true)
			weapon:SetParent(spawnedUnit, "attach_sword")
			weapon:SetLocalOrigin(Vector(0, 0, 0))
			weapon:SetLocalAngles(0, 0, 0)
			weapon:SetModelScale(0.5)
		end
		if spawnedUnit:GetUnitName() == "npc_dota_hero_abaddon" then
			spawnedUnit.weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/abaddon/weta_fractured_sword_of_eternity_weapon/weta_fractured_sword_of_eternity_weapon.vmdl"})
			spawnedUnit.weapon:FollowEntity(spawnedUnit, true)
			spawnedUnit.weapon:SetParent(spawnedUnit, "attach_sword")
			spawnedUnit.weapon:SetLocalOrigin(Vector(0, 0, 0))
			spawnedUnit.weapon:SetLocalAngles(0, 0, 0)
			spawnedUnit.weapon:SetModelScale(1)
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
		if spawnedUnit:GetUnitName() == "npc_dota_hero_templar_assassin" then
			local sword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/props_items/magicstick.vmdl"})
			sword:FollowEntity(spawnedUnit, true)
			sword:SetParent(spawnedUnit, "attach_sword")
			sword:SetLocalOrigin(Vector(0, 0, 0))
			sword:SetLocalAngles(0, 0, 0)
			sword:SetModelScale(0.5)
		end
		if spawnedUnit:GetUnitName() == "npc_dota_hero_spectre" then
			local sword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/chara/knife.vmdl"})
			sword:FollowEntity(spawnedUnit, true)
			sword:SetParent(spawnedUnit, "attach_sword")
			sword:SetLocalOrigin(Vector(0, 0, 0))
			sword:SetLocalAngles(0, 0, 0)
			sword:SetModelScale(1.0)
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
	else
		if spawnedUnit:GetUnitName() == "npc_dota_hero_slardar" then
			spawnedUnit.weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/pistoletov/mechalexpistol.vmdl"})
			spawnedUnit.weapon:FollowEntity(spawnedUnit, true)
			spawnedUnit.weapon:SetParent(spawnedUnit, "attach_sword")
			spawnedUnit.weapon:SetLocalOrigin(Vector(0, 0, 0))
			spawnedUnit.weapon:SetLocalAngles(0, 0, 0)
			spawnedUnit.weapon:SetModelScale(0.5)
		end
		if spawnedUnit:GetUnitName() == "npc_dota_hero_abaddon" then
			spawnedUnit.weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/abaddon/weta_fractured_sword_of_eternity_weapon/weta_fractured_sword_of_eternity_weapon.vmdl"})
			spawnedUnit.weapon:FollowEntity(spawnedUnit, true)
			spawnedUnit.weapon:SetParent(spawnedUnit, "attach_sword")
			spawnedUnit.weapon:SetLocalOrigin(Vector(0, 0, 0))
			spawnedUnit.weapon:SetLocalAngles(0, 0, 0)
			spawnedUnit.weapon:SetModelScale(1)
		end
		if spawnedUnit:GetUnitName() == "npc_dota_hero_templar_assassin" then
			local sword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/props_items/magicstick.vmdl"})
			sword:FollowEntity(spawnedUnit, true)
			sword:SetParent(spawnedUnit, "attach_sword")
			sword:SetLocalOrigin(Vector(0, 0, 0))
			sword:SetLocalAngles(0, 0, 0)
			sword:SetModelScale(0.5)
		end
		if spawnedUnit:GetUnitName() == "npc_dota_silvername_clone" then
			local weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/ogre_magi/ogre_magi_weapon.vmdl"})
			weapon:FollowEntity(spawnedUnit, true)
			weapon:SetParent(spawnedUnit, "attach_sword")
			weapon:SetLocalOrigin(Vector(0, 0, 0))
			weapon:SetLocalAngles(0, 0, 0)
			weapon:SetModelScale(0.5)
		end
		if spawnedUnit:GetUnitName() == "npc_dota_hero_spectre" then
			local sword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/chara/knife.vmdl"})
			sword:FollowEntity(spawnedUnit, true)
			sword:SetParent(spawnedUnit, "attach_sword")
			sword:SetLocalOrigin(Vector(0, 0, 0))
			sword:SetLocalAngles(0, 0, 0)
			sword:SetModelScale(1.0)
		end
	end
end
---------------------------------------------------------
-- dota_on_hero_finish_spawn
-- * heroindex
-- * hero  		(string)
---------------------------------------------------------

function OvervodkaGameMode:OnHeroFinishSpawn( event )
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
function OvervodkaGameMode:BountyRunePickupFilter( filterTable )
      filterTable["xp_bounty"] = 2*filterTable["xp_bounty"]
      filterTable["gold_bounty"] = 2*filterTable["gold_bounty"]
      return true
end

---------------------------------------------------------------------------
-- Event: OnTeamKillCredit, see if anyone won
---------------------------------------------------------------------------
function OvervodkaGameMode:OnTeamKillCredit( event )
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

	if IsComebackSystemActive() then
		local SortedTeams = self:GetSortedValidActiveTeams()

		CustomNetTables:SetTableValue("globals", "teams_top", SortedTeams)
	end

	CustomGameEventManager:Send_ServerToAllClients( "kill_event", broadcast_kill_event )
end

connectedPlayers = {}

function OvervodkaGameMode:OnGameInProgress()
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
        OvervodkaGameMode:EndGame( lastTeamStanding )
    end
end

function OvervodkaGameMode:OnPlayerDisconnect( event )
    local playerID = event.PlayerID
    if PlayerResource:IsValidPlayer(playerID) then
        connectedPlayers[playerID] = false
    end
end

function OvervodkaGameMode:OnPlayerReconnect( event )
    local playerID = event.PlayerID
    if PlayerResource:IsValidPlayer(playerID) then
        connectedPlayers[playerID] = true
    end
end
---------------------------------------------------------------------------
-- Event: OnEntityKilled
---------------------------------------------------------------------------
function OvervodkaGameMode:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	local killedTeam = killedUnit:GetTeam()
	if killedUnit:IsTempestDouble() then return end
	local hero = EntIndexToHScript( event.entindex_attacker )
	local heroTeam = hero:GetTeam()
	local extraTime = 0

	if killedUnit:IsRealHero() then
		self.allSpawned = true

		if ChaosOrb and ChaosOrb.OnHeroKilled then
			ChaosOrb:OnHeroKilled(killedUnit, hero)
		end

		if hero and hero:IsRealHero() and hero:GetUnitName() == "npc_dota_hero_undying" then
			if event.entindex_inflictor ~= nil then
				local ability = EntIndexToHScript(event.entindex_inflictor)
				if ability and ability:GetAbilityName() == "visitor_q" and hero:HasShard() then
					local bonus_pct = ability:GetSpecialValueFor("bonus_respawn_time") or 0
					if bonus_pct > 0 then
						killedUnit._visitorBonusRespawnPct = bonus_pct
					end
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
				OvervodkaGameMode:SetRespawnTime( killedTeam, killedUnit, extraTime )
			end
		else
			OvervodkaGameMode:SetRespawnTime( killedTeam, killedUnit, extraTime )
		end
	end
end

function OvervodkaGameMode:SetRespawnTime( killedTeam, killedUnit, extraTime )
	extraTime = extraTime or 0

	local baseTime = 0

	if GetMapName() == "overvodka_5x5" then
		baseTime = 10 + killedUnit:GetLevel() * 2

		if killedUnit:FindItemInInventory("item_aegis") then
			extraTime = extraTime - 5
		end
		if killedUnit:GetUnitName() == "npc_dota_hero_juggernaut" then
			if killedUnit:IsReincarnating() then
				extraTime = extraTime - 6
			end
		end
	else
		if killedTeam == self.leadingTeam and self.isGameTied == false then
			baseTime = 20
			if killedUnit:FindItemInInventory("item_aegis") then
				extraTime = extraTime - 15
			end
			if killedUnit:GetUnitName() == "npc_dota_hero_juggernaut" then
				if killedUnit:IsReincarnating() then
					extraTime = extraTime - 16
				end
			end
		else
			baseTime = 10
			if killedUnit:FindItemInInventory("item_aegis") then
				extraTime = extraTime - 5
			end
			if killedUnit:GetUnitName() == "npc_dota_hero_juggernaut" then
				if killedUnit:IsReincarnating() then
					extraTime = extraTime - 6
				end
			end
		end
	end

	local respawnTime = baseTime + extraTime

	local bonus_pct = killedUnit._visitorBonusRespawnPct or 0
	if bonus_pct > 0 then
		respawnTime = respawnTime * (1 + bonus_pct * 0.01)
		killedUnit._visitorBonusRespawnPct = nil
	end

	if ChaosOrb and ChaosOrb.IsEffectActive and ChaosOrb:IsEffectActive("turbo_mode") then
		respawnTime = math.max(math.floor(respawnTime * 0.25 + 0.5), 1)
	end

	killedUnit:SetTimeUntilRespawn( respawnTime )
end


--------------------------------------------------------------------------------
-- Event: OnItemPickUp
--------------------------------------------------------------------------------
function OvervodkaGameMode:OnItemPickUp( event )
	VectorTarget:OnItemPickup(event)
	local item = EntIndexToHScript( event.ItemEntityIndex )
	local picker
	if event.HeroEntityIndex then
		picker = EntIndexToHScript(event.HeroEntityIndex)
	elseif event.UnitEntityIndex then
		picker = EntIndexToHScript(event.UnitEntityIndex)
	end
	if not picker or picker:IsNull() then return end
	local owner = picker
	while owner and not owner:IsNull() and not owner:IsRealHero() do
		local next_owner = owner.GetOwner and owner:GetOwner() or nil
		if (not next_owner or next_owner:IsNull()) and owner.GetPlayerOwnerID then
			local playerID = owner:GetPlayerOwnerID()
			if playerID ~= nil and playerID ~= -1 then
				next_owner = PlayerResource:GetSelectedHeroEntity(playerID)
			end
		end
		if not next_owner or next_owner:IsNull() or next_owner == owner then
			break
		end
		owner = next_owner
	end
	if not owner or owner:IsNull() then
		owner = picker
	end
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
		local heroes = HeroList:GetAllHeroes()
		for i = 1, #heroes do
			local hero = heroes[i]
			if hero:IsRealHero() and hero:GetTeamNumber() == owner:GetTeamNumber() and hero:IsAlive() then
				local playerID = hero:GetPlayerID()
				if playerID ~= nil and playerID ~= -1 then
					r = 300
					if GetMapName() == "overvodka_5x5" then
						r = 50
					end
					if hero:GetUnitName() == "npc_dota_hero_skeleton_king" and hero:IsTempestDouble() then
						r = 0
					end
					local Team = PlayerResource:GetTeam(playerID)
					local newR = ChangeValueByTeamPlace(r, Team)
					hero:ModifyGoldFiltered(newR, false, 0)
					SendOverheadEventMessage(hero, OVERHEAD_ALERT_GOLD, hero, newR, nil)
				end
			end
		end
		if ChaosOrb and ChaosOrb.OnGoldPickup then
			ChaosOrb:OnGoldPickup(owner)
		end
		UTIL_Remove( item )
	elseif event.itemname == "item_chaos_orb" then
		if not IsRealHero(picker) then
			local playerID = picker and picker.GetPlayerOwnerID and picker:GetPlayerOwnerID() or -1
			local respawnOrigin = Vector(0, 0, 0)
			local hasRespawnOrigin = false
			if item and not item:IsNull() then
				local container = item:GetContainer()
				if container and not container:IsNull() then
					respawnOrigin = container:GetAbsOrigin()
					hasRespawnOrigin = true
				end
			end
			if not hasRespawnOrigin and picker and not picker:IsNull() then
				respawnOrigin = picker:GetAbsOrigin()
			end

			if playerID and playerID ~= -1 then
				SendErrorToPlayer(playerID, "#CHAOS_ORB_ONLY_REAL_HERO")
			end

			Timers:CreateTimer(FrameTime(), function()
				if item and not item:IsNull() then
					if OvervodkaGameMode and OvervodkaGameMode.CleanupChaosOrbParticles then
						OvervodkaGameMode:CleanupChaosOrbParticles(item)
						local container = item:GetContainer()
						if container and not container:IsNull() then
							OvervodkaGameMode:CleanupChaosOrbParticles(container)
						end
					end
					if picker and not picker:IsNull() then
						picker:RemoveItem(item)
					end
					UTIL_Remove(item)
				end

				self:SpawnChaosOrbEntity(respawnOrigin, false)
			end)
			return
		end

		if OvervodkaGameMode and OvervodkaGameMode.CleanupChaosOrbParticles then
			OvervodkaGameMode:CleanupChaosOrbParticles(item)
			local container = item:GetContainer()
			if container and not container:IsNull() then
				OvervodkaGameMode:CleanupChaosOrbParticles(container)
			end
		end
		UTIL_Remove(item)

		if ChaosOrb and not ChaosOrb:BeginSelection(owner) then
			self:SpawnChaosOrbEntity(owner:GetAbsOrigin(), false)
		end
	elseif event.itemname == "item_zhenya_present" then
        UTIL_Remove(item)
        self:GiveZhenyaPresentReward(owner)
	elseif event.itemname == "item_bag_of_gold_2" then
		if owner:GetUnitName() ~= "npc_dota_hero_necrolyte" then
			ApplyDamage( { victim = owner, attacker = owner, damage = owner:GetHealth() * 0.3, damage_type = DAMAGE_TYPE_PURE } )
			EmitSoundOn("peterka_shard", owner)
		else
			ApplyDamage( { victim = owner, attacker = owner, damage = owner:GetHealth() * 0.2, damage_type = DAMAGE_TYPE_PURE } )
			SendOverheadEventMessage( owner, OVERHEAD_ALERT_GOLD, owner, 300, nil )
		end
		if ChaosOrb and ChaosOrb.OnGoldPickup then
			ChaosOrb:OnGoldPickup(owner)
		end
		UTIL_Remove( item )
	elseif event.itemname == "item_bag_of_gold_bablokrad" then
		if owner:GetUnitName() == "npc_dota_hero_necrolyte" then
			ApplyDamage( { victim = owner, attacker = owner, damage = owner:GetHealth() * 0.2, damage_type = DAMAGE_TYPE_PURE } )
		end
		local rewerd = 100
		owner:ModifyGoldFiltered( rewerd, false, 0 )
		SendOverheadEventMessage( owner, OVERHEAD_ALERT_GOLD, owner, rewerd, nil )
		if ChaosOrb and ChaosOrb.OnGoldPickup then
			ChaosOrb:OnGoldPickup(owner)
		end
		UTIL_Remove( item )
	elseif event.itemname == "item_treasure_chest" then
		local chestMultiplier = ChaosOrb and ChaosOrb.IsEffectActive and ChaosOrb:IsEffectActive("double_chest") and 2 or 1
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
		for _ = 1, chestMultiplier do
			OvervodkaGameMode:SpecialItemAdd(event)
		end
		Timers:CreateTimer(0.03, function()
			RemoveItemByName(owner, treasureItemName)
			UTIL_Remove(item)
			for _ = 1, chestMultiplier do
				local bonusItem = CreateItem("item_madstone_bundle", owner, owner)
				owner:AddItem(bonusItem)
				if GetMapName ~= "overvodka_5x5" then
					Timers:CreateTimer(0.03, function()
						local bonusItem2 = CreateItem("item_madstone_bundle", owner, owner)
						owner:AddItem(bonusItem2)
					end)
				end
			end
			if owner:GetUnitName() == "npc_dota_hero_phoenix" and owner:HasTalent("special_bonus_unique_silvername_3") and owner:HasAbility("silvername_q_facet_1") then
				for _ = 1, chestMultiplier do
					OvervodkaGameMode:SpecialItemAdd(event)
				end
			end
		end)
	end
end


--------------------------------------------------------------------------------
-- Event: OnNpcGoalReached
--------------------------------------------------------------------------------
function OvervodkaGameMode:OnNpcGoalReached( event )
	local npc = EntIndexToHScript( event.npc_entindex )
	if npc:GetUnitName() == "npc_dota_treasure_courier" then
		OvervodkaGameMode:TreasureDrop( npc )
	end
end


function OvervodkaGameMode:GiveZhenyaPresentReward(hero)
    if not IsServer() then return end
    if not hero or hero:IsNull() then return end

    local playerID = hero:GetPlayerID()
    if playerID == nil or playerID == -1 then return end
    local roll = RandomInt(1, 100)
	if IsInToolsMode() or GameRules:IsCheatMode() then roll = 1 end
    if roll <= 66 then
        self:GiveZhenyaGold(hero, 500)
    elseif roll <= 88 then
        local coins = RandomInt(5, 8)
        self:GiveZhenyaHamsterCoins(playerID, coins)
    else
        local hours = self:RollZhenyaPrimeHours()
        self:GiveZhenyaPrime(playerID, hours)
    end
end

function OvervodkaGameMode:GiveZhenyaGold(hero, amount)
    if not IsServer() then return end
    if not hero or hero:IsNull() then return end

    amount = amount or 500

    hero:ModifyGoldFiltered(amount, false, 0)
    SendOverheadEventMessage(hero, OVERHEAD_ALERT_GOLD, hero, amount, nil)
end

function OvervodkaGameMode:GiveZhenyaHamsterCoins(playerID, amount)
    if not IsServer() then return end
    if not amount or amount <= 0 then return end

    local steamID = PlayerResource:GetSteamAccountID(playerID)
    if not steamID or steamID == 0 then return end

    local data = {
        SteamID = steamID,
        amount  = amount,
    }

    if Server and Server.SendRequest then
        Server:SendRequest(
            SERVER_URL .. "/update_balance",
            data,
             function(response)
                if response and response.success then
                    if Server and Server.RefreshPlayerProfile then
                        Server:RefreshPlayerProfile(playerID)
                    end
                    if Store and Store.FetchPlayerData then
                        Store:FetchPlayerData(playerID)
                    end
					self:PushZhenyaNotification(playerID, {
                        kind   = "coins",
                        amount = amount,
                    })
                else
                    print("[ZhenyaPresent] update_balance failed:", response and response.error)
                end
            end,
            false
        )
    end
end

function OvervodkaGameMode:RollZhenyaPrimeHours()
    local totalWeight = 0
    local weights = {}

    for h = 1, 23 do
        local d = (24 - h)
        local w = d * d * d
        weights[h] = w
        totalWeight = totalWeight + w
    end

    local roll = RandomInt(1, totalWeight)
    local accum = 0
    for h = 1, 23 do
        accum = accum + weights[h]
        if roll <= accum then
            return h
        end
    end
	
    return 1
end

function OvervodkaGameMode:GiveZhenyaPrime(playerID, hours)
    if not IsServer() then return end
    if not hours or hours <= 0 then return end

    local steamID = PlayerResource:GetSteamAccountID(playerID)
    if not steamID or steamID == 0 then return end

    local durationKey = "gift_" .. tostring(hours) .. "h"

    local data = {
        SteamID = steamID,
        duration = durationKey,
    }

    if Server and Server.SendRequest then
        Server:SendRequest(
            SERVER_URL .. "buy_prime",
            data,
            function(response)
                if response and response.success then
                    if Server and Server.RefreshPlayerProfile then
                        Server:RefreshPlayerProfile(playerID)
                    end
                    if Store and Store.FetchPlayerData then
                        Store:FetchPlayerData(playerID)
                    end
					self:PushZhenyaNotification(playerID, {
                        kind  = "prime",
                        hours = hours,
                    })
                else
                    print("[ZhenyaPresent] buy_prime failed:", response and response.error)
                end
            end,
            false
        )
    end
end

function OvervodkaGameMode:PushZhenyaNotification(playerID, payload)
    if not IsServer() then return end
    if not payload then return end

    self.zhenyaNotifSeq[playerID] = (self.zhenyaNotifSeq[playerID] or 0) + 1
    payload.seq = self.zhenyaNotifSeq[playerID]
    payload.time = GameRules:GetGameTime()

    CustomNetTables:SetTableValue(
        "overvodka_notifications",
        tostring(playerID),
        payload
    )
end
