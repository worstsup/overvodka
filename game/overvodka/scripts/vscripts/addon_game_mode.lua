--[[
Overvodka Game Mode
]]

_G.nNEUTRAL_TEAM = 4
_G.nCOUNTDOWNTIMER = 1501
local PrecacheUtils = require("util/precache")

---------------------------------------------------------------------------
-- COverthrowGameMode class
---------------------------------------------------------------------------
if COverthrowGameMode == nil then
	_G.COverthrowGameMode = class({}) -- put COverthrowGameMode in the global scope
end

---------------------------------------------------------------------------
-- Required .lua files
---------------------------------------------------------------------------
require( "events" )
require( "items" )
require( "utility_functions" )
require('timers')
require('utils')
require('server/debug_panel')
require('chat_wheel/chat_wheel')
require('server/server')
require('music_zone_trigger')
require('util/vector_targeting')
require('util/functions')
---------------------------------------------------------------------------
-- Precache
---------------------------------------------------------------------------
function Precache( context )
	PrecacheUtils.Precache(context)
end

function Activate()
	COverthrowGameMode:InitGameMode()
	COverthrowGameMode:CustomSpawnCamps()
end

function COverthrowGameMode:CustomSpawnCamps()
	for name,_ in pairs(spawncamps) do
	spawnunits(name)
	end
end


---------------------------------------------------------------------------
-- Initializer
---------------------------------------------------------------------------
function COverthrowGameMode:InitGameMode()
	print( "Overthrow is loaded." )
	XP_PER_LEVEL_TABLE = {
	0, -- 1
	200, -- 2
	600, -- 3
	1080, -- 4
	1680, -- 5
	2300, -- 6
	2940, -- 7
	3600, -- 8
	4280, -- 9
	5080, -- 10
	5900,  --- 11
	6740,  --- 12
	7640,  --- 13
	8865,  --- 14
	10115, --- 15
	11390, --- 16
	12690, --- 17
	14015, --- 18
	15415, --- 19
	16905, --- 20
	18405, --- 21
	20155, --- 22
	22155, --- 23
	24405, --- 24
	26905, --- 25
	29655, --- 26
	32655, --- 27
	35905, --- 28
	39405, --- 29
	43405, --- 30
	47655, --- 31
	51155, --- 32
	55905, --- 33
	57905, --- 34
	61905, --- 35
	}
  
  	require( "scripts/vscripts/filters" )
  	FilterManager:Init()
	if GetMapName() ~= "overvodka_5x5" then
  		MusicZoneTrigger:Init()
	end
	DebugPanel:Init()

	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel( 35 )
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE)
	GameRules:SetEnableAlternateHeroGrids( false )
	self.m_bFillWithBots = GlobalSys:CommandLineCheck( "-addon_bots" )
	self.m_bFastPlay = GlobalSys:CommandLineCheck( "-addon_fastplay" )

	self.m_TeamColors = {}
	if GetMapName() ~= "overvodka_5x5" then
		self.m_TeamColors[DOTA_TEAM_GOODGUYS] = { 61, 210, 150 }	--		Teal
		self.m_TeamColors[DOTA_TEAM_BADGUYS]  = { 136, 8, 8 }
	end
	self.m_TeamColors[DOTA_TEAM_CUSTOM_1] = { 197, 77, 168 }	--      Pink
	self.m_TeamColors[DOTA_TEAM_CUSTOM_2] = { 255, 108, 0 }		--		Orange
	self.m_TeamColors[DOTA_TEAM_CUSTOM_3] = { 52, 85, 255 }		--		Blue
	self.m_TeamColors[DOTA_TEAM_CUSTOM_4] = { 101, 212, 19 }	--		Green
	self.m_TeamColors[DOTA_TEAM_CUSTOM_5] = { 129, 83, 54 }		--		Brown
	self.m_TeamColors[DOTA_TEAM_CUSTOM_6] = { 27, 192, 216 }	--		Cyan
	self.m_TeamColors[DOTA_TEAM_CUSTOM_7] = { 199, 228, 13 }	--		Olive
	self.m_TeamColors[DOTA_TEAM_CUSTOM_8] = { 140, 42, 244 }	--		Purple

	for team = 0, (DOTA_TEAM_COUNT-1) do
		color = self.m_TeamColors[ team ]
		if color then
			SetTeamCustomHealthbarColor( team, color[1], color[2], color[3] )
		end
	end

	self.m_VictoryMessages = {}
	self.m_VictoryMessages[DOTA_TEAM_GOODGUYS] = "#VictoryMessage_GoodGuys"
	self.m_VictoryMessages[DOTA_TEAM_BADGUYS]  = "#VictoryMessage_BadGuys"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_1] = "#VictoryMessage_Custom1"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_2] = "#VictoryMessage_Custom2"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_3] = "#VictoryMessage_Custom3"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_4] = "#VictoryMessage_Custom4"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_5] = "#VictoryMessage_Custom5"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_6] = "#VictoryMessage_Custom6"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_7] = "#VictoryMessage_Custom7"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_8] = "#VictoryMessage_Custom8"

	self.m_GatheredShuffledTeams = {}
	self.numSpawnCamps = 6
	self.specialItem = ""
	self.spawnTime = 60
	self.warnTime = 7
	self.nNextSpawnItemNumber = 1
	self.nMaxItemSpawns = 30
	self.hasWarnedSpawn = false
	self.allSpawned = false
	self.leadingTeam = -1
	self.runnerupTeam = -1
	self.leadingTeamScore = 0
	self.runnerupTeamScore = 0
	self.isGameTied = true
	self.countdownEnabled = false
	self.itemSpawnIndex = 1
	self.itemSpawnLocation = Entities:FindByName( nil, "greevil" )
	self.tier1ItemBucket = {}
	self.tier2ItemBucket = {}
	self.tier3ItemBucket = {}
	self.tier4ItemBucket = {}
	self.tier5ItemBucket = {}

	self.itemSpawnLocations = nil
	self.KILLS_TO_WIN_SINGLES = 50
	self.KILLS_TO_WIN_DUOS = 50
	self.KILLS_TO_WIN_TRIOS = 200
	self.KILLS_TO_WIN_QUADS = 50
	self.KILLS_TO_WIN_QUINTS = 50

	self.TEAM_KILLS_TO_WIN = self.KILLS_TO_WIN_SINGLES
	self.CLOSE_TO_VICTORY_THRESHOLD = 5

	self.TEAMS_MISSING = 0
	self.GoldBonusPerTeam = 2
	self.XpBonusPerTeam = 4
	self.MIN_COUNTDOWN_TIME = 900
	self.SOLO_TIME_PER_TEAM = 120
	self.DUO_TIME_PER_TEAM = 300

	self.LeaveTeamEncounterDuration = 5

	self.bFirstBlooded = false

	self.bShowsComeback = false

	self.TeamKills = {}

	---------------------------------------------------------------------------
	
	self:GatherAndRegisterValidTeams()

	GameRules:GetGameModeEntity().COverthrowGameMode = self

	-- Adding Many Players
	if GetMapName() == "overvodka_5x5" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 5 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 5 )
		self.m_GoldRadiusMin = 300
		self.m_GoldRadiusMax = 1400
		self.m_GoldDropPercent = 8
	elseif GetMapName() == "temple_quartet" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 4 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 4 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 4 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 4 )
		self.m_GoldRadiusMin = 300
		self.m_GoldRadiusMax = 1400
		self.m_GoldDropPercent = 10
	else
		self.m_GoldRadiusMin = 250
		self.m_GoldRadiusMax = 650
		self.m_GoldDropPercent = 15
	end

	--GameRules:SetCustomGameTeamMaxPlayers( 1, 5 )
	--GameRules:SetCustomGameSetupTimeout( 3 )--Убрать когда нужно будет убрать зрителей

	-- Show the ending scoreboard immediately
	--GameRules:SetCustomGameEndDelay( 0 )
	--GameRules:SetCustomVictoryMessageDuration( 10 )
	if GetMapName() == "overvodka_duo" then
		GameRules:SetCustomGameSetupTimeout( 3 )
	else
		GameRules:SetCustomGameSetupTimeout( 0 )
	end
	if GetMapName() == "overvodka_5x5" then
		GameRules:SetPreGameTime( 90.0 )
		GameRules:SetCustomGameSetupTimeout( 3 )
	else
		GameRules:SetPreGameTime( 10.0 )
	end
	if self.m_bFastPlay then
		GameRules:SetStrategyTime( 1.0 )
	end
	GameRules:SetHeroSelectPenaltyTime( 0.0 )
	GameRules:SetShowcaseTime( 0.0 )
	GameRules:SetIgnoreLobbyTeamsInCustomGame( false )
	GameRules:SetSafeToLeave(true)
	--GameRules:SetHideKillMessageHeaders( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:SetSuggestAbilitiesEnabled( true )
	GameRules:SetSuggestItemsEnabled( true )
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_DOUBLEDAMAGE , true )
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_HASTE, true )
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_ILLUSION, true )
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_INVISIBILITY, true )
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_ARCANE, true )
	if GetMapName() == "overvodka_5x5" then
		GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_BOUNTY, true )
		GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_REGENERATION, true )
		GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_WATER, true )
		GameRules:GetGameModeEntity():SetLoseGoldOnDeath( true )
		GameRules:GetGameModeEntity():SetDefaultStickyItem( "item_tpscroll" )
		GameRules:GetGameModeEntity():SetGiveFreeTPOnDeath( true )
		GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled( true )
		GameRules:GetGameModeEntity():SetDaynightCycleDisabled( false )
		GameRules:GetGameModeEntity():SetDaynightCycleAdvanceRate( 1.0 )
		GameRules:GetGameModeEntity():SetUseDefaultDOTARuneSpawnLogic(true)
		GameRules:SetHideKillMessageHeaders( false )
		GameRules:SetUseUniversalShopMode( false )
		GameRules:SetTimeOfDay( 0.25 )
		GameRules:SetStrategyTime( 20.0 )
		GameRules:SetCustomGameBansPerTeam( 3 )
		GameRules:GetGameModeEntity():SetDraftingBanningTimeOverride( 0.0 )
	else
		GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_BOUNTY, false )
		GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_REGENERATION, false )
		GameRules:GetGameModeEntity():SetTPScrollSlotItemOverride("item_lesh")
		GameRules:GetGameModeEntity():SetDefaultStickyItem( "item_byebye" )
		GameRules:GetGameModeEntity():SetLoseGoldOnDeath( false )
		GameRules:GetGameModeEntity():SetGiveFreeTPOnDeath( false )
		GameRules:SetHideKillMessageHeaders( true )
		GameRules:SetUseUniversalShopMode( true )
		GameRules:SetStrategyTime( 1000.0 )
		if GetMapName() == "overvodka_duo" then
			GameRules:SetCustomGameBansPerTeam( 2 )
		else
			GameRules:SetCustomGameBansPerTeam( 1 )
		end
		GameRules:GetGameModeEntity():SetDraftingBanningTimeOverride( 0.0 )
	end
	GameRules:GetGameModeEntity():SetFountainPercentageHealthRegen( 0 )
	GameRules:GetGameModeEntity():SetFountainPercentageManaRegen( 0 )
	GameRules:GetGameModeEntity():SetFountainConstantManaRegen( 0 )
	GameRules:GetGameModeEntity():SetBountyRunePickupFilter( Dynamic_Wrap( COverthrowGameMode, "BountyRunePickupFilter" ), self )
	GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( COverthrowGameMode, "ExecuteOrderFilter" ), self )

	GameRules:GetGameModeEntity():SetFreeCourierModeEnabled( true )
	GameRules:GetGameModeEntity():SetUseTurboCouriers( true )
	GameRules:GetGameModeEntity():SetCanSellAnywhere( true )

	local nTeamSize = GameRules:GetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS )
	if self.m_bFastPlay then
		GameRules:GetGameModeEntity():SetDraftingBanningTimeOverride( 1.0 )
	end
	GameRules:GetGameModeEntity():SetDraftingHeroPickSelectTimeOverride( 60.0 )

	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( COverthrowGameMode, 'OnGameRulesStateChange' ), self )
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( COverthrowGameMode, "OnNPCSpawned" ), self )
	ListenToGameEvent( "dota_on_hero_finish_spawn", Dynamic_Wrap( COverthrowGameMode, "OnHeroFinishSpawn" ), self )
	ListenToGameEvent( "dota_team_kill_credit", Dynamic_Wrap( COverthrowGameMode, 'OnTeamKillCredit' ), self )
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( COverthrowGameMode, 'OnEntityKilled' ), self )
	ListenToGameEvent( "dota_item_picked_up", Dynamic_Wrap( COverthrowGameMode, "OnItemPickUp"), self )
	ListenToGameEvent( "dota_npc_goal_reached", Dynamic_Wrap( COverthrowGameMode, "OnNpcGoalReached" ), self )
	ListenToGameEvent( "player_disconnect", Dynamic_Wrap( COverthrowGameMode, "OnPlayerDisconnected" ), self )
		Convars:RegisterCommand( "overthrow_force_item_drop", function(...) self:ForceSpawnItem() end, "Force an item drop.", FCVAR_CHEAT )
		Convars:RegisterCommand( "overthrow_force_gold_drop", function(...) self:ForceSpawnGold() end, "Force gold drop.", FCVAR_CHEAT )
		Convars:RegisterCommand( "overthrow_set_timer", function(...) return SetTimer( ... ) end, "Set the timer.", FCVAR_CHEAT )
		Convars:RegisterCommand( "overthrow_force_end_game", function(...) return self:EndGame( DOTA_TEAM_GOODGUYS ) end, "Force the game to end.", FCVAR_CHEAT )
		Convars:RegisterCommand( "overthrow_team_leaved", function(...) 
				local Data = {
					team = 2,
					last_time = GameRules:GetGameTime()+self.LeaveTeamEncounterDuration,
					bonus_gold = self.GoldBonusPerTeam,
					bonus_xp = self.XpBonusPerTeam,
					time_reduce = IsSolo() and self.SOLO_TIME_PER_TEAM or self.DUO_TIME_PER_TEAM,
					missing_teams = self.TEAMS_MISSING
				}
				return CustomGameEventManager:Send_ServerToAllClients( "on_team_leaved", Data ) 
			end, "Show team leave encounter", FCVAR_CHEAT )
		Convars:RegisterCommand( "overthrow_chat_wheel_say", function(...) 
				return CustomGameEventManager:Send_ServerToAllClients("chat_wheel_say_line", {caller_player = 1, item_id = 1})
			end, "Show team leave encounter", FCVAR_CHEAT )
		Convars:SetInt( "dota_server_side_animation_heroesonly", 0 )

	COverthrowGameMode:SetUpFountains()
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, 1 ) 

	-- Spawning monsters
	spawncamps = {}
	for i = 1, self.numSpawnCamps do
		local campname = "camp"..i.."_path_customspawn"
		spawncamps[campname] =
		{
			NumberToSpawn = RandomInt(3,5),
			WaypointName = "camp"..i.."_path_wp1"
		}
	end

	GameRules:SetPostGameLayout( DOTA_POST_GAME_LAYOUT_SINGLE_COLUMN )
	GameRules:SetPostGameColumns( {
		DOTA_POST_GAME_COLUMN_LEVEL,
		DOTA_POST_GAME_COLUMN_ITEMS,
		DOTA_POST_GAME_COLUMN_KILLS,
		DOTA_POST_GAME_COLUMN_DEATHS,
		DOTA_POST_GAME_COLUMN_ASSISTS,
		DOTA_POST_GAME_COLUMN_NET_WORTH,
		DOTA_POST_GAME_COLUMN_DAMAGE,
		DOTA_POST_GAME_COLUMN_HEALING,
	} )
end

function COverthrowGameMode:IncrementTeamHeroKills(TeamID, value)
	if self.TeamKills[TeamID] == nil then
		self.TeamKills[TeamID] = 0
	end

	self.TeamKills[TeamID] = self.TeamKills[TeamID] + value

	CustomNetTables:SetTableValue("globals", "team_".. TeamID .."_kills", {kills=self.TeamKills[TeamID]})
end

function COverthrowGameMode:GetTeamHeroKills(TeamID)
	return self.TeamKills[TeamID] or 0
end

---------------------------------------------------------------------------
-- Set up fountain regen
---------------------------------------------------------------------------
function COverthrowGameMode:SetUpFountains()

	LinkLuaModifier( "modifier_fountain_aura_lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_fountain_aura_effect_lua", LUA_MODIFIER_MOTION_NONE )

	local fountainEntities = Entities:FindAllByClassname( "ent_dota_fountain")
	for _,fountainEnt in pairs( fountainEntities ) do
		fountainEnt:AddNewModifier( fountainEnt, fountainEnt, "modifier_fountain_aura_lua", {} )
	end
end

---------------------------------------------------------------------------
-- Get the color associated with a given teamID
---------------------------------------------------------------------------
function COverthrowGameMode:ColorForTeam( teamID )
	local color = self.m_TeamColors[ teamID ]
	if color == nil then
		color = { 255, 255, 255 } -- default to white
	end
	return color
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function COverthrowGameMode:EndGame( victoryTeam )
	local overBoss = Entities:FindByName( nil, "@overboss" )
	if overBoss then
		local celebrate = overBoss:FindAbilityByName( 'dota_ability_celebrate' )
		if celebrate then
			overBoss:CastAbilityNoTarget( celebrate, -1 )
		end
	end
	local tTeamScores = {}
	for team = DOTA_TEAM_FIRST, (DOTA_TEAM_COUNT-1) do
		tTeamScores[team] = self:GetTeamHeroKills(team)
	end
	GameRules:SetPostGameTeamScores( tTeamScores )
	local sortedTeams = self:GetSortedValidTeams()
	Server:OnGameEnded(sortedTeams, victoryTeam)
	GameRules:SetGameWinner( victoryTeam )
end

function COverthrowGameMode:GetSortedValidTeams()
	local sortedTeams = {}
	for _, team in pairs( self.m_GatheredShuffledTeams ) do
		if PlayerResource:GetNthPlayerIDOnTeam(team, 1) ~= -1 then
			table.insert( sortedTeams, { teamID = team, teamScore = self:GetTeamHeroKills( team ) } )
		end
	end

	table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )

	return sortedTeams
end

function COverthrowGameMode:GetSortedValidActiveTeams()
	local sortedTeams = {}
	for _, team in pairs( self.m_GatheredShuffledTeams ) do
		if PlayerResource:GetNthPlayerIDOnTeam(team, 1) ~= -1 then
			for i = 1, PlayerResource:GetPlayerCountForTeam(team) do
				local PlayerID = PlayerResource:GetNthPlayerIDOnTeam(team, i)
				if PlayerID ~= -1 then
					local Connection = PlayerResource:GetConnectionState(PlayerID)
					local FakeClient = PlayerResource:IsFakeClient(PlayerID)
					local Check = DOTA_CONNECTION_STATE_ABANDONED
					if FakeClient then
						Check = DOTA_CONNECTION_STATE_NOT_YET_CONNECTED
					end
					if Connection ~= Check and Connection ~= DOTA_CONNECTION_STATE_UNKNOWN then
						table.insert( sortedTeams, { teamID = team, teamScore = self:GetTeamHeroKills( team ) } )
						break
					end
				end
			end
		end
	end

	table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )

	return sortedTeams
end

function COverthrowGameMode:GetCountMissingTeams()
	local MaxTeamsCount = #self.m_GatheredShuffledTeams
	local CurrentActiveTeams = #self:GetSortedValidActiveTeams()
	local Diff = MaxTeamsCount - CurrentActiveTeams
	return Diff
end

function COverthrowGameMode:GetValidTeamPlayers()
	local Teams = {}

	for _, team in pairs( self.m_GatheredShuffledTeams ) do
		if PlayerResource:GetNthPlayerIDOnTeam(team, 1) ~= -1 then
			Teams[team] = {}
			for i = 1, PlayerResource:GetPlayerCountForTeam(team) do
				local PlayerID = PlayerResource:GetNthPlayerIDOnTeam(team, i)
				if PlayerID ~= -1 then
					table.insert(Teams[team], PlayerID)
				end
			end
		end
	end

	return Teams
end

function COverthrowGameMode:IsFirstBlooded()
	return self.bFirstBlooded
end

function COverthrowGameMode:OnPlayerDisconnected(event)
	local PlayerID = event.PlayerID
	local Team = PlayerResource:GetTeam(PlayerID)
	local ActiveTeams = self:GetSortedValidActiveTeams()
	local bTeamActive = false
	for _, TeamInfo in ipairs(ActiveTeams) do
		if TeamInfo.teamID == Team then
			bTeamActive = true
			break
		end
	end
	if bTeamActive == true then return end
	print("Team Disconnected: "..Team)
	self.TEAMS_MISSING = self:GetCountMissingTeams()
	local MinusTime = IsSolo() and self.SOLO_TIME_PER_TEAM or self.DUO_TIME_PER_TEAM
	self:ReduceCountdownTimer(1)

	CustomGameEventManager:Send_ServerToAllClients( "on_team_leaved", {
		team = Team, 
		last_time = GameRules:GetGameTime()+self.LeaveTeamEncounterDuration,
		bonus_gold = self.GoldBonusPerTeam,
		bonus_xp = self.XpBonusPerTeam,
		time_reduce = MinusTime,
		missing_teams = self.TEAMS_MISSING
	} )
end

function COverthrowGameMode:ReduceCountdownTimer(nTimes)
	local MinusTime = IsSolo() and self.SOLO_TIME_PER_TEAM or self.DUO_TIME_PER_TEAM
	if _G.nCOUNTDOWNTIMER > self.MIN_COUNTDOWN_TIME then
		_G.nCOUNTDOWNTIMER = math.max(self.MIN_COUNTDOWN_TIME, _G.nCOUNTDOWNTIMER-(MinusTime*nTimes))
	end
end

---------------------------------------------------------------------------
-- Put a label over a player's hero so people know who is on what team
---------------------------------------------------------------------------
function COverthrowGameMode:UpdatePlayerColor( nPlayerID )
	if not PlayerResource:HasSelectedHero( nPlayerID ) then
		return
	end

	local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
	if hero == nil then
		return
	end

	local teamID = PlayerResource:GetTeam( nPlayerID )
	local color = self:ColorForTeam( teamID )
	PlayerResource:SetCustomPlayerColor( nPlayerID, color[1], color[2], color[3] )
end


---------------------------------------------------------------------------
-- Simple scoreboard using debug text
---------------------------------------------------------------------------
function COverthrowGameMode:UpdateScoreboard()
	local sortedTeams = {}
	for _, team in pairs( self.m_GatheredShuffledTeams ) do
		table.insert( sortedTeams, { teamID = team, teamScore = self:GetTeamHeroKills( team ) } )
	end
	
	-- reverse-sort by score
	table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )

	for _, t in pairs( sortedTeams ) do
		local clr = self:ColorForTeam( t.teamID )

		-- Scaleform UI Scoreboard
		local score = 
		{
			team_id = t.teamID,
			team_score = t.teamScore
		}
		FireGameEvent( "score_board", score )
	end
	-- Leader effects (moved from OnTeamKillCredit)
	local leader = sortedTeams[1].teamID
	self.leadingTeam = leader
	self.runnerupTeam = sortedTeams[2].teamID
	self.leadingTeamScore = sortedTeams[1].teamScore
	self.runnerupTeamScore = sortedTeams[2].teamScore
	if sortedTeams[1].teamScore == sortedTeams[2].teamScore then
		self.isGameTied = true
	else
		self.isGameTied = false
	end
	--local allHeroes = HeroList:GetAllHeroes()
	--for _,entity in pairs( allHeroes) do
	--	if entity:GetTeamNumber() == leader and sortedTeams[1].teamScore ~= sortedTeams[2].teamScore and GetMapName() ~= "overvodka_5x5" then
	--		if entity:IsAlive() == true then
	--			-- Attaching a particle to the leading team heroes
	--			local existingParticle = entity:Attribute_GetIntValue( "particleID", -1 )
    --   		if existingParticle == -1 then
     --  			local particleLeader = ParticleManager:CreateParticle( "particles/leader/leader_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, entity )
	--				ParticleManager:SetParticleControlEnt( particleLeader, PATTACH_OVERHEAD_FOLLOW, entity, PATTACH_OVERHEAD_FOLLOW, "follow_overhead", entity:GetAbsOrigin(), true )
	--				entity:Attribute_SetIntValue( "particleID", particleLeader )
	--			end
	--		else
	--			local particleLeader = entity:Attribute_GetIntValue( "particleID", -1 )
	--			if particleLeader ~= -1 then
	--				ParticleManager:DestroyParticle( particleLeader, true )
	--				entity:DeleteAttribute( "particleID" )
	--			end
	--		end
	--	else
	--		local particleLeader = entity:Attribute_GetIntValue( "particleID", -1 )
	--		if particleLeader ~= -1 then
	--			ParticleManager:DestroyParticle( particleLeader, true )
	--			entity:DeleteAttribute( "particleID" )
	--		end
	--	end
	--end
end

---------------------------------------------------------------------------
-- Update player labels and the scoreboard
---------------------------------------------------------------------------
function COverthrowGameMode:OnThink()
	for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
		self:UpdatePlayerColor( nPlayerID )
	end
	self:UpdateScoreboard()
	if GameRules:IsGamePaused() == true then
        return 1
    end

	if self.countdownEnabled == true then
		CountdownTimer()

		if nCOUNTDOWNTIMER <= 900 and self.bShowsComeback == false then
			self.bShowsComeback = true

			local SortedTeams = self:GetSortedValidActiveTeams()

			CustomNetTables:SetTableValue("globals", "teams_top", SortedTeams)
		end

		if nCOUNTDOWNTIMER == 30 then
			CustomGameEventManager:Send_ServerToAllClients( "timer_alert", {} )
		end
		if nCOUNTDOWNTIMER <= 0 then
			if self.isGameTied == false then
				GameRules:SetCustomVictoryMessage( self.m_VictoryMessages[self.leadingTeam] )
				COverthrowGameMode:EndGame( self.leadingTeam )
				self.countdownEnabled = false
			else
				self.TEAM_KILLS_TO_WIN = self.leadingTeamScore + 1
				local broadcast_killcount = 
				{
					killcount = self.TEAM_KILLS_TO_WIN
				}
				CustomGameEventManager:Send_ServerToAllClients( "overtime_alert", broadcast_killcount )
			end
       	end
	end
	
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		COverthrowGameMode:ThinkGoldDrop()
		COverthrowGameMode:ThinkSpecialItemDrop()
	end

	return 1
end

---------------------------------------------------------------------------
-- Scan the map to see which teams have spawn points
---------------------------------------------------------------------------
function COverthrowGameMode:GatherAndRegisterValidTeams()
	local foundTeams = {}
	local foundTeamsList = {}
	local numTeams
	if GetMapName() ~= "overvodka_5x5" then
		for _, playerStart in pairs( Entities:FindAllByClassname( "info_player_start_dota" ) ) do
			foundTeams[  playerStart:GetTeam() ] = true
		end

		numTeams = TableCount(foundTeams)
		print( "GatherValidTeams - Found spawns for a total of " .. numTeams .. " teams" )
		
		for t, _ in pairs( foundTeams ) do
			table.insert( foundTeamsList, t )	
		end

		if numTeams == 0 then
			print( "GatherValidTeams - NO team spawns detected, defaulting to GOOD/BAD" )
			table.insert( foundTeamsList, DOTA_TEAM_GOODGUYS )
			table.insert( foundTeamsList, DOTA_TEAM_BADGUYS )
			numTeams = 2
		end
	else
		table.insert( foundTeamsList, DOTA_TEAM_GOODGUYS )
		table.insert( foundTeamsList, DOTA_TEAM_BADGUYS )
		numTeams = 2
	end


	local maxPlayersPerValidTeam = math.floor( 10 / numTeams )

	self.m_GatheredShuffledTeams = ShuffledList( foundTeamsList )

	print( "Final shuffled team list:" )
	for _, team in pairs( self.m_GatheredShuffledTeams ) do
		print( " - " .. team .. " ( " .. GetTeamName( team ) .. " )" )
	end

	print( "Setting up teams:" )
	for team = 0, (DOTA_TEAM_COUNT-1) do
		local maxPlayers = 0
		if ( nil ~= TableFindKey( foundTeamsList, team ) ) then
			maxPlayers = maxPlayersPerValidTeam
		end
		print( " - " .. team .. " ( " .. GetTeamName( team ) .. " ) -> max players = " .. tostring(maxPlayers) )
		GameRules:SetCustomGameTeamMaxPlayers( team, maxPlayers )
	end
end

function COverthrowGameMode:spawncamp(campname)
	spawnunits(campname)
end

function spawnunits(campname)
	local spawndata = spawncamps[campname]
	local NumberToSpawn = spawndata.NumberToSpawn --How many to spawn
    local SpawnLocation = Entities:FindByName( nil, campname )
    local waypointlocation = Entities:FindByName ( nil, spawndata.WaypointName )
	if SpawnLocation == nil then
		return
	end

    local randomCreature = 
    	{
			"basic_zombie",
			"berserk_zombie"
	    }
	local r = randomCreature[RandomInt(1,#randomCreature)]
    for i = 1, NumberToSpawn do
        local creature = CreateUnitByName( "npc_dota_creature_" ..r , SpawnLocation:GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_NEUTRALS )
        creature:SetInitialGoalEntity( waypointlocation )
    end
end

--------------------------------------------------------------------------------
-- Event: Filter for inventory full
--------------------------------------------------------------------------------
function COverthrowGameMode:ExecuteOrderFilter( filterTable )
	local orderType = filterTable["order_type"]
	if ( orderType ~= DOTA_UNIT_ORDER_PICKUP_ITEM or filterTable["issuer_player_id_const"] == -1 ) then
		return true
	else
		local item = EntIndexToHScript( filterTable["entindex_target"] )
		if item == nil then
			return true
		end
		local pickedItem = item:GetContainedItem()

		if pickedItem == nil then
			return true
		end
		if pickedItem:GetAbilityName() == "item_treasure_chest" then
			local player = PlayerResource:GetPlayer(filterTable["issuer_player_id_const"])
			local hero = player:GetAssignedHero()

			-- determine if we can scoop the neutral or not
			-- we need either a free backpack slot or a free neutral item slot
			local bAllowPickup = false
			local numBackpackItems = 0
			for nItemSlot = 0,DOTA_ITEM_INVENTORY_SIZE - 1 do 
				local hItem = hero:GetItemInSlot( nItemSlot )
				if hItem and hItem:IsInBackpack() then
					numBackpackItems = numBackpackItems + 1
				end
			end
			if numBackpackItems < 3 then
				bAllowPickup = true
			end

			if bAllowPickup then
				return true
			else
				local position = item:GetAbsOrigin()
				filterTable["position_x"] = position.x
				filterTable["position_y"] = position.y
				filterTable["position_z"] = position.z
				filterTable["order_type"] = DOTA_UNIT_ORDER_MOVE_TO_POSITION
				return true
			end
		end
	end
	return true
end

--------------------------------------------------------------------------------
function COverthrowGameMode:AssignTeams()
	local vecTeamValid = {}
	local vecTeamNeededPlayers = {}
	for nTeam = 0, (DOTA_TEAM_COUNT-1) do
		local nMax = GameRules:GetCustomGameTeamMaxPlayers( nTeam )
		if nMax > 0 then
			vecTeamNeededPlayers[ nTeam ] = nMax
			vecTeamValid[ nTeam ] = true
		else
			vecTeamValid[ nTeam ] = false
		end
	end

	-- loop 1: count up players on each team
	local hPlayers = {}
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:IsValidPlayerID( nPlayerID ) then
			local nTeam = PlayerResource:GetTeam( nPlayerID )
			if vecTeamValid[ nTeam ] == false then
				nTeam = PlayerResource:GetCustomTeamAssignment( nPlayerID )
			end
			--print( "Found player " .. nPlayerID .. " on team " .. nTeam )
			if vecTeamValid[ nTeam ] then
				vecTeamNeededPlayers[ nTeam ] = vecTeamNeededPlayers[ nTeam ] - 1
			else
				table.insert( hPlayers, nPlayerID )
			end
		end
	end

	-- loop 2: assign players. For each player who is on an invalid team,
	-- find the team that has the highest number of needed players
	-- and assign the player to that team
	for _,nPlayerID in pairs( hPlayers ) do
		--print( "Finding team for player " .. nPlayerID )
		local nTeamNumber = -1
		local nHighest = 0
		for nTeam = 0, (DOTA_TEAM_COUNT-1) do
			if vecTeamValid[ nTeam ] then
				local nVal = vecTeamNeededPlayers[ nTeam ]
				if nVal > nHighest then
					--print( "found team " .. nTeam .. " with needed " .. nVal .. " but highest was only " .. nHighest )
					nHighest = nVal
					nTeamNumber = nTeam
				end
			end
		end
		if nTeamNumber > 0 then
			PlayerResource:SetCustomTeamAssignment( nPlayerID, nTeamNumber )
			vecTeamNeededPlayers[ nTeamNumber ] = vecTeamNeededPlayers[ nTeamNumber ] - 1
		end
	end
	if self.m_bFillWithBots == true then
		GameRules:BotPopulate()
	end
end