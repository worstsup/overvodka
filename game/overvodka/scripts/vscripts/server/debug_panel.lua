DebugPanel = DebugPanel or {
	allowedSteamIDS = {
		188428188, -- Nears
		409188637, -- Worstsup
		885116894, -- dolbayobi
		349446348, -- mefisto
	},
	SelectedBot = {}
}

function DebugPanel:Init()
	if(not IsServer()) then
		return
	end
	DebugPanel:RegisterPanoramaListeners()
end

function DebugPanel:RegisterPanoramaListeners()
	CustomGameEventManager:RegisterListener('debug_panel_set_hero', Dynamic_Wrap(DebugPanel, 'OnSetHeroRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_set_bot', Dynamic_Wrap(DebugPanel, 'OnSetBotRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_create_bot', Dynamic_Wrap(DebugPanel, 'OnCreateBotRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_create_dummy', Dynamic_Wrap(DebugPanel, 'OnCreateDummyRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_destroy_dummy', Dynamic_Wrap(DebugPanel, 'OnDestroyDummyRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_adjust_hero_level', Dynamic_Wrap(DebugPanel, 'OnHeroAdjustLevelRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_adjust_hero_stats', Dynamic_Wrap(DebugPanel, 'OnHeroAdjustStatsRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_add_scepter_to_hero', Dynamic_Wrap(DebugPanel, 'OnHeroScepterRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_add_shard_to_hero', Dynamic_Wrap(DebugPanel, 'OnHeroShardRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_switch_invul_on_hero', Dynamic_Wrap(DebugPanel, 'OnHeroInvulRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_switch_fly_on_hero', Dynamic_Wrap(DebugPanel, 'OnHeroFlyRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_switch_grave_on_hero', Dynamic_Wrap(DebugPanel, 'OnHeroGraveRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_kick_player', Dynamic_Wrap(DebugPanel, 'OnKickPlayerRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_remove_unit', Dynamic_Wrap(DebugPanel, 'OnRemoveUnitRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_give_item', Dynamic_Wrap(DebugPanel, 'OnItemRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_set_time_scale', Dynamic_Wrap(DebugPanel, 'OnSetHostTimescaleRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_wtf_toggle', Dynamic_Wrap(DebugPanel, 'OnWTFToggleRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_refresh_abilities', Dynamic_Wrap(DebugPanel, 'OnRefreshAbilitiesRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_set_gold', Dynamic_Wrap(DebugPanel, 'OnSetGoldRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_change_gold', Dynamic_Wrap(DebugPanel, 'OnChangeGoldRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_state_for_player', Dynamic_Wrap(DebugPanel, 'OnStateRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_teleport', Dynamic_Wrap(DebugPanel, 'OnTeleportRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_spawn_unit', Dynamic_Wrap(DebugPanel, 'OnSpawnUnitRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_set_difficulty', Dynamic_Wrap(DebugPanel, 'OnSetDifficultyRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_hurt_me_bad', Dynamic_Wrap(DebugPanel, 'OnHurtMeBadRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_kill', Dynamic_Wrap(DebugPanel, 'OnKillRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_remove_items_on_ground', Dynamic_Wrap(DebugPanel, 'OnRemoveItemsOnGroundRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_respawn_hero', Dynamic_Wrap(DebugPanel, 'OnRespawnHeroRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_add_ability', Dynamic_Wrap(DebugPanel, 'OnAddAbilityRequest'))
	CustomGameEventManager:RegisterListener('debug_panel_switch_title_status', Dynamic_Wrap(DebugPanel, 'OnSwitchTitleStatus'))
end

function DebugPanel:IsDeveloper(playerID)
	local steamID = tonumber(PlayerResource:GetSteamAccountID(playerID))
	if table.contains(DebugPanel.allowedSteamIDS, steamID) then
		return true
	end
	return false
end

function DebugPanel:IsPlayerAllowedToExecuteCommand(playerID)
	if DebugPanel:IsDeveloper(playerID) then
		return true
	end
	return false
end

function DebugPanel:OnGameRulesStateChange()
	local newState = GameRules:State_Get()
	if newState >= DOTA_GAMERULES_STATE_PRE_GAME and not DebugPanel._gameModePreGameStateReached then
		for i=1, PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) do
			local playerID = PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, i)
			DebugPanel:RestorePanelForPlayer(playerID)
		end
		DebugPanel._gameModePreGameStateReached = true
	end
end

function DebugPanel:RestorePanelForPlayer(playerID)
	if(PlayerResource:IsValidPlayer(playerID) == false or playerID < 0) then
		return
	end

	if(DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) == false) then
		return
	end

	Timers:CreateTimer(0, function()
		local playerHero = PlayerResource:GetSelectedHeroEntity(playerID)
		if playerHero then
			DebugPanel:SendSetHeroResponse(playerID, DOTAGameManager:GetHeroIDByName(playerHero:GetUnitName()))
			DebugPanel:OnSetBotRequest({PlayerID = playerID, id = DOTAGameManager:GetHeroIDByName(playerHero:GetUnitName())})
			DebugPanel:SendDebugPanelState(playerID, DebugPanel:IsPlayerAllowedToExecuteCommand(playerID))
		else
			return 1
		end
	end)
end

function DebugPanel:OnStateRequest(kv)
	local playerID = kv.PlayerID
	DebugPanel:RestorePanelForPlayer(playerID)
end

function DebugPanel:OnSetBotRequest(kv)
	local playerID = kv.PlayerID
	if not DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) then return end

	local hero = DOTAGameManager:GetHeroUnitNameByID(kv.id)

	if hero == nil then
		Debug_PrintError("Unable to find hero named "..tostring(hero)..".")
		return
	end

	DebugPanel.SelectedBot[playerID] = hero

	DebugPanel:SendSetBotResponse(playerID, kv.id)
end

function DebugPanel:SendSetBotResponse(playerID, id)
	local heroName = DOTAGameManager:GetHeroUnitNameByID(id)
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "debug_panel_set_bot_response", {
		hero_id = id,
		hero_name = heroName
	})
end

function DebugPanel:OnSetHeroRequest(kv)
	local playerID = kv.PlayerID
	if not DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) then return end

	local hero = DOTAGameManager:GetHeroUnitNameByID(kv.id)
	if(hero == nil) then
		Debug_PrintError("Unable to find hero named "..tostring(hero)..".")
		return
	end

	PlayerResource:ReplacePlayerHero(playerID, hero, false, false, true)
	DebugPanel:SendSetHeroResponse(playerID, kv.id)
end

function DebugPanel:SendSetHeroResponse(playerID, id)
	local heroName = DOTAGameManager:GetHeroUnitNameByID(id)
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "debug_panel_set_hero_response", {
		hero_id = id,
		hero_name = heroName
	})
end

function DebugPanel:SendDebugPanelState(playerID, enabled)
	local disabled = true
	if(enabled == true) then
		disabled = false
	end
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "debug_panel_state_for_player_response", {
		disabled = disabled
	})
end

function DebugPanel:OnSwitchTitleStatus(event)
	local PlayerID = event.PlayerID
	
	Server:SwitchTitleStatus(PlayerID)
end

function DebugPanel:OnSpawnUnitRequest(kv)
	local playerID = kv.PlayerID
	if(DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) == false) then
		return
	end
	kv.unitName = kv.unitName
	kv.team = tonumber(kv.team)
	kv.count = tonumber(kv.count)
	if(kv.team == nil or kv.count == nil) then
		Debug_PrintError("DebugPanel:OnSpawnUnitRequest() valve break something.")
		return
	end
	local playerHero = PlayerResource:GetSelectedHeroEntity(playerID)
	local position = playerHero:GetAbsOrigin()
	for i=0,kv.count-1 do
		local unit = CreateUnitByName(
			kv.unitName,
			position,
			true,
			nil,
			nil,
			kv.team
		)
		unit:AddNewModifier(unit, nil, "modifier_phased", {duration = 0.05})
		unit:Hold()
		unit:SetControllableByPlayer(playerID, true)
	end
end

function DebugPanel:OnHurtMeBadRequest(kv)
	local playerID = kv.PlayerID
	if not DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) then return end

	local UnitIndex = kv.unit
	local Unit = EntIndexToHScript(UnitIndex)
	if Unit and not Unit:IsNull() and Unit:IsAlive() then
		Unit:ModifyHealth(1, nil, false, 0)
	end
end

function DebugPanel:OnKillRequest(kv)
	local playerID = kv.PlayerID
	if not DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) then return end

	local UnitIndex = kv.unit
	local Unit = EntIndexToHScript(UnitIndex)
	if Unit and not Unit:IsNull() and Unit:IsAlive() then
		if (Unit:IsCreep()) then
			UTIL_Remove(Unit)
		else
			if (kv.force == 1) then
				Unit:ForceKill(false)
			else
				Unit:Kill(nil, nil)
			end
		end
	end
end

function DebugPanel:OnRemoveItemsOnGroundRequest(kv)
	local playerID = kv.PlayerID
	if(DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) == false) then
		return
	end
	local items = {}
	for i=0, GameRules:NumDroppedItems()-1, 1 do
		table.insert(items, GameRules:GetDroppedItem(i))
	end
	for _, item in pairs(items) do
		UTIL_Remove(item:GetContainedItem())
		UTIL_Remove(item)
	end
end

function DebugPanel:OnRespawnHeroRequest(kv)
	local playerID = kv.PlayerID
	if not DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) then return end

	local UnitIndex = kv.unit
	local Unit = EntIndexToHScript(UnitIndex)
	if Unit and not Unit:IsNull() and IsRealHero(Unit) then
		Unit:RespawnHero(false, false)
		Unit:SetBuybackCooldownTime(1)
	end
end

function DebugPanel:OnAddAbilityRequest(kv)
	local playerID = kv.PlayerID
	if(DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) == false) then
		return
	end
	local playerHero = PlayerResource:GetSelectedHeroEntity(playerID)
	if(not playerHero) then
		return
	end
	playerHero:AddAbility(kv.abilityName)
end

function DebugPanel:OnCreateBotRequest(kv)
	local playerID = kv.PlayerID

	if not DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) then return end
	
	local Team = kv.team

	if DebugPanel.SelectedBot[playerID] == nil then 
		SendErrorToPlayer(playerID, "Выберите героя", "UUI_SOUNDS.NoGold")
		return 
	end

	print("2", playerID, Team, DebugPanel.SelectedBot[playerID])

	local playerHero = PlayerResource:GetSelectedHeroEntity(playerID)
	if playerHero then
		DebugCreateHeroWithVariant( playerHero:GetPlayerOwner(), DebugPanel.SelectedBot[playerID], 1, Team, false, function (bot) 
			bot:SetControllableByPlayer( playerID, false )
			bot:SetRespawnPosition( playerHero:GetAbsOrigin() )
			FindClearSpaceForUnit( bot, playerHero:GetAbsOrigin(), false )
			bot:Hold()
			bot:SetIdleAcquire( false )
			bot:SetAcquisitionRange( 0 )
		end)
	end
end

function DebugPanel:OnCreateDummyRequest(kv)
	local playerID = kv.PlayerID
	if not DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) then return end

	DebugPanel._dummies = DebugPanel._dummies or {}
	if(DebugPanel._dummies[playerID]) then
		UTIL_Remove(DebugPanel._dummies[playerID])
	end
	local playerHero = PlayerResource:GetSelectedHeroEntity(playerID)
	DebugPanel._dummies[playerID] = CreateUnitByName(
		DebugPanel:GetDummyUnitName(),
		playerHero:GetAbsOrigin(),
		true,
		playerHero,
		playerHero,
		DOTA_TEAM_BADGUYS
	)
	-- DebugPanel._dummies[playerID]:AddNewModifier(
	-- 	DebugPanel._dummies[playerID],
	-- 	nil,
	-- 	"modifier_debug_panel_dummy",
	-- 	{
	-- 		duration = -1
	-- 	}
	-- )
end

function DebugPanel:OnDestroyDummyRequest(kv)
	local playerID = kv.PlayerID
	if(DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) == false) then
		return
	end
	if(DebugPanel._dummies[playerID] == nil) then return end
	if(DebugPanel._dummies[playerID]) then
		UTIL_Remove(DebugPanel._dummies[playerID])
	end
end

function DebugPanel:OnHeroAdjustLevelRequest(kv)
	local playerID = kv.PlayerID
	if not DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) then return end

	local UnitIndex = kv.unit
	local Unit = EntIndexToHScript(UnitIndex)
	if Unit and not Unit:IsNull() and Unit:IsAlive() and IsRealHero(Unit) then
		local level = tonumber(kv.lvl) or -1
		local bIncrease = (kv.increase == 1)

		if level < 0 then
			Debug_PrintError("DebugPanel:OnHeroAdjustLevelRequest can't determine lvl from data. Wtf?")
			return
		end

		local gameModeEntity = GameRules:GetGameModeEntity()
		level = math.min(level, gameModeEntity:GetCustomHeroMaxLevel())

		if bIncrease then
			local desiredLevel = Unit:GetLevel() + level - 1
			for i = Unit:GetLevel(), desiredLevel do
				Unit:HeroLevelUp(false)
			end
		else
			PlayerResource:ReplacePlayerHero(Unit:GetPlayerID(), Unit:GetUnitName(), true, false, true)
		end
	end
end

function DebugPanel:OnHeroAdjustStatsRequest(kv) --Повышение статов
	local playerID = kv.PlayerID
	if(DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) == false) then
		return
	end
	local type = tonumber(kv.type) or DOTA_ATTRIBUTE_INVALID
	local value = tonumber(kv.value) or 0
	local playerHero = PlayerResource:GetSelectedHeroEntity(playerID)
	local mod = nil
	if(type == DOTA_ATTRIBUTE_STRENGTH) then
		mod = playerHero:AddNewModifier(playerHero,nil,"modifier_item_bonus_strength",nil)
	end
	if(type == DOTA_ATTRIBUTE_AGILITY) then
		mod = playerHero:AddNewModifier(playerHero,nil,"modifier_item_bonus_agility",nil)
	end
	if(type == DOTA_ATTRIBUTE_INTELLECT) then
		mod = playerHero:AddNewModifier(playerHero,nil,"modifier_item_bonus_intellect",nil)
	end
	if(mod) then
		if(value > 0) then
			mod:SetStackCount(mod:GetStackCount() + value)
		else
			mod:Destroy()
		end
	end
	playerHero:CalculateStatBonus(true)
end

function DebugPanel:OnHeroScepterRequest(kv)
	local playerID = kv.PlayerID
	if not DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) then return end

	local UnitIndex = kv.unit
	local Unit = EntIndexToHScript(UnitIndex)
	if Unit and not Unit:IsNull() and Unit:IsAlive() and Unit:IsRealHero() then
		if not Unit:FindModifierByName( "modifier_item_ultimate_scepter_consumed" ) then
			Unit:AddNewModifier(Unit, nil, "modifier_item_ultimate_scepter_consumed", nil)
		else
			Unit:RemoveModifierByName("modifier_item_ultimate_scepter_consumed")
		end
	end
end

function DebugPanel:OnHeroShardRequest(kv)
	local playerID = kv.PlayerID
	if not DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) then return end

	local UnitIndex = kv.unit
	local Unit = EntIndexToHScript(UnitIndex)
	if Unit and not Unit:IsNull() and Unit:IsAlive() and Unit:IsRealHero() then
		if not Unit:FindModifierByName( "modifier_item_aghanims_shard" ) then
			Unit:AddItemByName( "item_aghanims_shard" )
		else
			Unit:RemoveModifierByName("modifier_item_aghanims_shard")
		end
	end
end

function DebugPanel:OnHeroInvulRequest(kv)
	local playerID = kv.PlayerID
	if not DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) then return end

	local UnitIndex = kv.unit
	local Unit = EntIndexToHScript(UnitIndex)
	if Unit and not Unit:IsNull() and Unit:IsAlive() then
		if not Unit:HasModifier("modifier_debug_panel_no_damage") then
			Unit:AddNewModifier(Unit, nil, "modifier_debug_panel_no_damage", nil)
		else
			Unit:RemoveModifierByName("modifier_debug_panel_no_damage")
		end
	end
end

function DebugPanel:OnHeroFlyRequest(kv)
	local playerID = kv.PlayerID
	if not DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) then return end

	local UnitIndex = kv.unit
	local Unit = EntIndexToHScript(UnitIndex)
	if Unit and not Unit:IsNull() and Unit:IsAlive() then
		if not Unit:HasModifier("modifier_debug_panel_fly_mode") then
			Unit:AddNewModifier(Unit, nil, "modifier_debug_panel_fly_mode", nil)
		else
			Unit:RemoveModifierByName("modifier_debug_panel_fly_mode")
		end
	end
end

function DebugPanel:OnHeroGraveRequest(kv)
	local playerID = kv.PlayerID
	if not DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) then return end

	local UnitIndex = kv.unit
	local Unit = EntIndexToHScript(UnitIndex)
	if Unit and not Unit:IsNull() and Unit:IsAlive() then
		if not Unit:HasModifier("modifier_debug_panel_grave") then
			Unit:AddNewModifier(Unit, nil, "modifier_debug_panel_grave", nil)
		else
			Unit:RemoveModifierByName("modifier_debug_panel_grave")
		end
	end
end

function DebugPanel:OnKickPlayerRequest(kv)
	local playerID = kv.PlayerID
	if(DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) == false) then
		return
	end
	local target = EntIndexToHScript(kv.target)
	if (not target) then return end
	local playerHero = PlayerResource:GetSelectedHeroEntity(playerID)
	local targetID = target:GetPlayerOwnerID()
	local playerID = playerHero:GetPlayerOwnerID()
	if(targetID == playerID) then
		SendErrorToPlayer(playerID, "Are you a clown? Do not try to kick yourself!", "UUI_SOUNDS.NoGold")
		return
	end
	DisconnectClient(targetID, true)
end

function DebugPanel:OnRemoveUnitRequest(kv)
	local playerID = kv.PlayerID
	if(DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) == false) then
		return
	end
	local target = EntIndexToHScript(kv.target)
	if(not target) then
		return
	end
	local playerHero = PlayerResource:GetSelectedHeroEntity(playerID)
	local targetID = target:GetPlayerOwnerID()
	local playerID = playerHero:GetPlayerOwnerID()
	if(target == playerHero or target:IsCourier() == true) then
		SendErrorToPlayer(playerID, "Retard. You can't play without your hero or courier, you know?", "UUI_SOUNDS.NoGold")
		return
	end
	if(target.GetStrength ~= nil) then
		SendErrorToPlayer(playerID, "Use kick to remove players instead.", "UUI_SOUNDS.NoGold")
		return
	end
	target:Kill(nil,nil)
	if (target) then UTIL_Remove(target) end
end

function DebugPanel:OnWTFToggleRequest(kv)
	local playerID = kv.PlayerID
	if(DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) == false) then
		return
	end
	Convars:SetBool("dota_ability_debug", kv.isActive == 1)
	DebugPanel:OnRefreshAbilitiesRequest(kv)
end

function DebugPanel:RemoveAllCooldownForUnit(unit, useEffect)
	if(type(unit) ~= "table" or unit.GetUnitName == nil) then
		Debug_PrintError("DebugPanel:RemoveAllCooldownForUnit expected unit to be valid unit. Got "..tostring(unit).."("..type(unit)..").")
		return
	end
	if(useEffect == nil) then
		useEffect = false
	end
	if(useEffect ~= true and useEffect ~= false) then
		Debug_PrintError("DebugPanel:RemoveAllCooldownForUnit expected useEffect to be boolean. Got "..tostring(useEffect).."("..type(useEffect)..").")
	end
	for i = 0, DOTA_MAX_ABILITIES -1 do
		local ability = unit:GetAbilityByIndex(i)
		if(ability) then
			ability:EndCooldown()
			ability:RefreshCharges()
		end
	end
	for i = 0, DOTA_ITEM_MAX -1 do
		local item = unit:GetItemInSlot(i)
		if(item) then
			item:EndCooldown()
			item:RefreshCharges()
		end
	end
	if(useEffect == true) then
		local nFXIndex = ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", PATTACH_CUSTOMORIGIN, unit)
		ParticleManager:SetParticleControlEnt(nFXIndex, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
		ParticleManager:ReleaseParticleIndex(nFXIndex)
		ParticleManager:DestroyParticle(nFXIndex, false)
		EmitSoundOn("RefresherCore.Activate", unit)
	end
end

function DebugPanel:OnRefreshAbilitiesRequest(kv)
	local playerID = kv.PlayerID
	if not DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) then return end

	local UnitIndex = kv.unit
	local Unit = EntIndexToHScript(UnitIndex)
	if Unit and not Unit:IsNull() and Unit:IsAlive() then
		DebugPanel:RemoveAllCooldownForUnit(Unit, true)
		Unit:SetHealth(Unit:GetMaxHealth())
		Unit:SetMana(Unit:GetMaxMana())
	end
end

function DebugPanel:OnSetHostTimescaleRequest(kv)
	local playerID = kv.PlayerID
	if(DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) == false) then
		return
	end
	kv.value = tonumber(kv.value)
	if(not kv.value) then
		return
	end
	Convars:SetFloat("host_timescale", kv.value)
end

function DebugPanel:OnSetGoldRequest(kv)
	local playerID = kv.PlayerID
	if not DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) then return end

	local UnitIndex = kv.unit
	local Unit = EntIndexToHScript(UnitIndex)
	if Unit and not Unit:IsNull() and Unit:IsAlive() and Unit:IsRealHero() then
		Unit:SetGold(kv.gold, true)
		Unit:SetGold(kv.gold, false)
	end
end

function DebugPanel:OnChangeGoldRequest(kv)
	local playerID = kv.PlayerID
	if not DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) then return end

	local UnitIndex = kv.unit
	local Unit = EntIndexToHScript(UnitIndex)
	if Unit and not Unit:IsNull() and Unit:IsAlive() and Unit:IsRealHero() then
		Unit:SpendGold(-kv.gold, 0)
	end
end

function DebugPanel:OnTeleportRequest(kv)
	local playerID = kv.PlayerID

	if not DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) then return end

	local UnitIndex = kv.unit
	local Unit = EntIndexToHScript(UnitIndex)
	local point = Vector(kv.point_x, kv.point_y, kv.point_z)

	if Unit and not Unit:IsNull() and Unit:IsAlive() then
		Unit:SetAbsOrigin(point)
	end
end

function DebugPanel:OnItemRequest(kv)
	local playerID = kv.PlayerID
	local itemName = kv.itemName
	if(DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) == false) then
		return
	end
	local playerHero = PlayerResource:GetSelectedHeroEntity(playerID)
	playerHero:AddItemByName(itemName)
end

function DebugPanel:OnSetDifficultyRequest(kv)
	local playerID = kv.PlayerID
	if(DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) == false) then
		return
	end
	kv.difficulty = tonumber(kv.difficulty)
	Spawn:SetDifficulty(kv.difficulty)
end


function DebugPanel:SendTestResults(playerID, data)
	if(DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) == false) then
		return
	end
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "debug_panel_on_tests_data", {
		data = data
	})
end

function DebugPanel:OnRunTestsRequest(kv)
	local playerID = kv.PlayerID
	if(DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) == false) then
		return
	end
	UnitTests:ExecuteTestsForPlayer(playerID)
end
function DebugPanel:OnSetDifficultyRequest(kv)
	local playerID = kv.PlayerID
	if(DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) == false) then
		return
	end
	kv.difficulty = tonumber(kv.difficulty)
	Spawn:SetDifficulty(kv.difficulty)
end


function DebugPanel:SendTestResults(playerID, data)
	if(DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) == false) then
		return
	end
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "debug_panel_on_tests_data", {
		data = data
	})
end

function DebugPanel:OnResetDummyRequest(kv)
	local playerID = kv.PlayerID
	if(DebugPanel:IsPlayerAllowedToExecuteCommand(playerID) == false) then
		return
	end
	DebugPanel._dummyDamageData = DebugPanel._dummyDamageData or {}
	DebugPanel._dummyDamageData[playerID] = DebugPanel._dummyDamageData[playerID] or {}
	DebugPanel._dummyDamageData[playerID]._dummyTotalDamage = 0
	DebugPanel._dummyDamageData[playerID]._dummyDPS = 0
	DebugPanel._dummyDamageData[playerID]._dummyLastHit = 0
	DebugPanel._dummyDamageData[playerID]._dummyResetTime = nil
	DebugPanel._dummyDamageData[playerID]._dummyStartTime = nil
	DebugPanel:ReportDummyStats(playerID)
end

function DebugPanel:_ReportDamageDoneToDummy(playerID, kv)
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "debug_panel_dummy_on_take_damage", kv)
end

function DebugPanel:ReportDummyStats(playerID)
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "debug_panel_dummy_on_stats", {
		dummy_total_damage = DebugPanel._dummyDamageData[playerID]._dummyTotalDamage,
		dummy_dps = DebugPanel._dummyDamageData[playerID]._dummyDPS,
		dummy_last_hit = DebugPanel._dummyDamageData[playerID]._dummyLastHit
	})
end

function DebugPanel:ReportDamageDoneToDummy(playerID, kv)
	DebugPanel._dummyDamageData = DebugPanel._dummyDamageData or {}
	DebugPanel._dummyDamageData[playerID] = DebugPanel._dummyDamageData[playerID] or {}
	DebugPanel._dummyDamageData[playerID]._dummyTotalDamage = DebugPanel._dummyDamageData[playerID]._dummyTotalDamage or 0
	DebugPanel._dummyDamageData[playerID]._dummyDPS = DebugPanel._dummyDamageData[playerID]._dummyDPS or 0
	DebugPanel._dummyDamageData[playerID]._dummyLastHit = DebugPanel._dummyDamageData[playerID]._dummyLastHit or 0

	DebugPanel._dummyDamageData[playerID]._dummyTotalDamage = DebugPanel._dummyDamageData[playerID]._dummyTotalDamage + kv.damage
	DebugPanel._dummyDamageData[playerID]._dummyLastHit = kv.damage
	local gameTime = GameRules:GetGameTime()
	DebugPanel._dummyDamageData[playerID]._dummyResetTime = gameTime + 10
	if(DebugPanel._dummyDamageData[playerID]._dummyStartTime == nil) then
		DebugPanel._dummyDamageData[playerID]._dummyStartTime = gameTime
	end

	local timePassed = math.max((gameTime - DebugPanel._dummyDamageData[playerID]._dummyStartTime), 1)
	DebugPanel._dummyDamageData[playerID]._dummyDPS = DebugPanel._dummyDamageData[playerID]._dummyTotalDamage / timePassed
	DebugPanel:ReportDummyStats(playerID)
	DebugPanel:_ReportDamageDoneToDummy(playerID, kv)
end

function DebugPanel:GetDummyUnitName()
	return "npc_dota_hero_target_dummy"
end

function DebugPanel:IsDummy(unit)
	if(not unit or unit:IsNull() == true) then
		return false
	end
	return unit:GetUnitName() == DebugPanel:GetDummyUnitName()
end











LinkLuaModifier("modifier_debug_panel_dummy", "server/debug_panel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_debug_panel_no_damage", "server/debug_panel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_debug_panel_grave", "server/debug_panel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_debug_panel_free_spells_aura", "server/debug_panel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_debug_panel_free_spells_aura_buff", "server/debug_panel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_debug_panel_fly_mode", "server/debug_panel", LUA_MODIFIER_MOTION_NONE)

modifier_debug_panel_no_damage = class({
	IsDebuff = function()
		return false
	end,
	GetTexture = function()
		return "modifier_invulnerable"
	end,
	GetEffectName = function() return "particles/dev/library/base_overhead_follow.vpcf" end,
	GetEffectAttachType = function() return PATTACH_OVERHEAD_FOLLOW end,
	IsPurgable = function()
		return false
	end,
	IsPurgeException = function()
		return false
	end,
	RemoveOnDeath = function()
		return false
	end,
	GetAbsoluteNoDamageMagical = function()
		return 1
	end,
	GetAbsoluteNoDamagePhysical = function()
		return 1
	end,
	GetAbsoluteNoDamagePure = function()
		return 1
	end,
	CheckState = function()
		return
		{
			[MODIFIER_STATE_INVULNERABLE] = true
		}
	end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE
	} end
})

modifier_debug_panel_fly_mode = class({
	IsDebuff = function()
		return false
	end,
	IsPurgable = function()
		return false
	end,
	IsPurgeException = function()
		return false
	end,
	RemoveOnDeath = function()
		return false
	end,
	CheckState = function()
		return
		{
			[MODIFIER_STATE_FLYING] = true
		}
	end,
})

modifier_debug_panel_grave = class({
	IsDebuff = function()
		return false
	end,
	GetTexture = function()
		return "dazzle_shallow_grave"
	end,
	IsPurgable = function()
		return false
	end,
	IsPurgeException = function()
		return false
	end,
	RemoveOnDeath = function()
		return false
	end,
	GetMinHealth = function()
		return 1
	end,
	GetEffectName = function()
		return "particles/econ/items/dazzle/dazzle_dark_light_weapon/dazzle_dark_shallow_grave.vpcf"
	end,
	GetEffectAttachType = function()
		return PATTACH_ABSORIGIN_FOLLOW
	end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_MIN_HEALTH
	} end
})

modifier_debug_panel_free_spells_aura = class({
	IsHidden = function()
		return true
	end,
	IsDebuff = function()
		return false
	end,
	IsPurgable = function()
		return false
	end,
	IsPurgeException = function()
		return false
	end,
	IsAuraActiveOnDeath = function()
		return false
	end,
	GetAuraRadius = function(self)
		return FIND_UNITS_EVERYWHERE
	end,
	GetAuraSearchFlags = function(self)
		return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
	end,
	GetAuraSearchTeam = function(self)
		return DOTA_UNIT_TARGET_TEAM_BOTH
	end,
	IsAura = function()
		return true
	end,
	GetAuraSearchType = function(self)
		return DOTA_UNIT_TARGET_ALL
	end,
	GetModifierAura = function()
		return "modifier_debug_panel_free_spells_aura_buff"
	end,
	GetAuraDuration = function()
		return 0
	end,
	GetAttributes = function()
		return MODIFIER_ATTRIBUTE_MULTIPLE
	end,
	RemoveOnDeath = function()
		return false
	end
})

function modifier_debug_panel_free_spells_aura:OnCreated(kv)
	if(not IsServer()) then
		return
	end
	self.playerID = kv.playerID
end

function modifier_debug_panel_free_spells_aura:GetAuraEntityReject(npc)
	return npc:GetPlayerOwnerID() ~= self.playerID
end

function modifier_debug_panel_free_spells_aura:GetPlayerOwnerID(npc)
	return self.playerID
end

modifier_debug_panel_free_spells_aura_buff = class({
	IsHidden = function()
		return true
	end,
	IsDebuff = function()
		return false
	end,
	IsPurgable = function()
		return false
	end,
	IsPurgeException = function()
		return false
	end,
	RemoveOnDeath = function()
		return false
	end,
	DeclareFunctions = function()
		return {
			MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING,
			MODIFIER_EVENT_ON_SPENT_MANA
		}
	end,
	GetModifierPercentageCooldownStacking = function()
		return 100
	end
})

function modifier_debug_panel_free_spells_aura_buff:OnCreated()
	self.parent = self:GetParent()
	if(not IsServer()) then
		return
	end
	DebugPanel:RemoveAllCooldownForUnit(self.parent, false)
end

function modifier_debug_panel_free_spells_aura_buff:OnSpentMana(kv)
	if(kv.unit ~= self.parent) then
		return
	end
	self.parent:SetMana(self.parent:GetMana() + kv.cost)
	if(kv.ability) then
		kv.ability:EndCooldown()
		kv.ability:RefreshCharges()
	end
end