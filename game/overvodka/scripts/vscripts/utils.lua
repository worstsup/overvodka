LinkLuaModifier("modifier_subscriber_effect", "modifiers/modifier_subscriber_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_win_condition", "modifiers/modifier_win_condition", LUA_MODIFIER_MOTION_NONE)

GAME_CATEGORY_DEFINITIONS = {
	NONE = 0,
	SOLO = 1,
	DUO = 2,
	DOTA = 3,
}

function SendErrorToPlayer(PID, errorText, errorSound)
    if errorSound == nil then
        errorSound = "UUI_SOUNDS.NoGold"
    end
    local player = PlayerResource:GetPlayer(PID)
    if player then
        CustomGameEventManager:Send_ServerToPlayer(player, "SEND_ERROR_TO_PLAYER", {errorText=errorText, errorSound=errorSound})
    end
end

function IsRealHero(Unit)
    if not Unit or Unit:IsNull() then return false end

    if not Unit:IsRealHero() or Unit:IsIllusion() or Unit:IsStrongIllusion() or Unit:IsTempestDouble() or Unit:IsClone() or Unit:GetClassname() == "npc_dota_lone_druid_bear" or DebugPanel:IsDummy(Unit) then return false end

    return true
end

function IsComebackTeam(TeamID)
	local CurrentTeams = COverthrowGameMode:GetSortedValidActiveTeams()
	local bIsFirstBlooded = COverthrowGameMode:IsFirstBlooded()

	if not bIsFirstBlooded or nCOUNTDOWNTIMER > 900 then
		return false
	end

	if IsSolo() then
		if #CurrentTeams > 2 then
			if TeamID == CurrentTeams[#CurrentTeams].teamID or TeamID == CurrentTeams[#CurrentTeams-1].teamID then
				return true
			end
		end
	elseif IsDuo() then
		if #CurrentTeams > 3 then
			if TeamID == CurrentTeams[#CurrentTeams].teamID then
				return true
			end
		end
	end
	
	return false
end

function ChangeValueByTeamPlace(value, Team)
	local CurrentTeams = COverthrowGameMode:GetSortedValidActiveTeams()
	local bIsFirstBlooded = COverthrowGameMode:IsFirstBlooded()

	if not bIsFirstBlooded or nCOUNTDOWNTIMER > 900 then
		return value
	end
	
	if IsSolo() then
		if #CurrentTeams > 2 then
			if Team == CurrentTeams[#CurrentTeams].teamID then
				value = value * 2
			elseif Team == CurrentTeams[#CurrentTeams-1].teamID then
				value = value * 1.5
			end
		end
	elseif IsDuo() then
		if #CurrentTeams > 3 then
			if Team == CurrentTeams[#CurrentTeams].teamID then
				value = value * 2
			end
		end
	end

	return value
end

function table.count(t)
    local key_table = {}
    for k in pairs(t) do
        table.insert(key_table, k)
    end

    return #key_table
end

function table.find(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then
            return i
        end
    end
    return nil
end

function cprint(...)
    local list = {...}
	for _,value in pairs(list) do
		if type(value) == "table" then
			print(dump(value))
		else
			print(value)
		end
	end
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

function table.contains(_self, value)
   if(not _self or not value) then
       return false
   end
   for _, v in pairs(_self) do
       if v == value then
           return true
       end
   end
   return false
end

if IsServer() then
	function CDOTA_PlayerResource:ReplacePlayerHero(playerID, heroName, restoreGold, restoreExp, restoreItems--[[, restoreBuffs]])
		if (not IsServer()) then return end

		playerID = tonumber(playerID) or -1

	--Shit checks
		if(playerID < 0 or PlayerResource:IsValidPlayerID(playerID) == false) then
			Debug_PrintError("CDOTA_PlayerResource:ReplaceHeroWith attempt to replace hero for invalid player ("..tostring(playerID)..").")
			return
		end
		local playerHero = PlayerResource:GetSelectedHeroEntity(playerID)
		if(not playerHero) then
			Debug_PrintError("CDOTA_PlayerResource:ReplaceHeroWith attempt to replace hero for player ("..tostring(playerID)..") with no hero.")
			return
		end
		if(type(heroName) ~= "string") then
			Debug_PrintError("Attempt to call CDOTA_PlayerResource:ReplaceHeroWith with invalid heroName argument. String expected, got "..tostring(heroName).." ("..type(heroName)..")")
			return
		end
		if(DOTAGameManager:GetHeroIDByName(heroName) < 1) then
			Debug_PrintError("CDOTA_PlayerResource:ReplaceHeroWith "..tostring(heroName).." is invalid hero name or hero is disabled.")
			return
		end

		if (restoreGold ~= nil and type(restoreGold) ~= "boolean") then
			Debug_PrintError("Attempt to call CDOTA_PlayerResource:ReplaceHeroWith with invalid restoreGold argument. Boolean expected, got "..tostring(restoreGold).." ("..type(restoreGold)..")")
			return
		end

		if (restoreExp ~= nil and type(restoreExp) ~= "boolean") then
			Debug_PrintError("Attempt to call CDOTA_PlayerResource:ReplaceHeroWith with invalid restoreExp argument. Boolean expected, got "..tostring(restoreExp).." ("..type(restoreExp)..")")
			return
		end

		if (restoreItems ~= nil and type(restoreExp) ~= "boolean") then
			Debug_PrintError("Attempt to call CDOTA_PlayerResource:ReplaceHeroWith with invalid restoreItems argument. Boolean expected, got "..tostring(restoreExp).." ("..type(restoreExp)..")")
			return
		end


	-- variables
		local gold = 0
		local level = 0
		local allHeroItems = {}

	-- Nil checks
		if (restoreGold == nil) then
			restoreGold = false
		end

		if (restoreExp == nil) then
			restoreExp = false
		end

		if (restoreItems == nil) then
			restoreItems = false
		end


	-- just checks
		if (restoreGold == true) then
			gold = PlayerResource:GetGold(playerID)
		end

		if (restoreExp == true) then
			level = playerHero:GetLevel()
		end

		if (restoreItems == true) then
			for i = 0, 23 do
				local itemInSlot = playerHero:GetItemInSlot(i)
				if (itemInSlot) then
					allHeroItems[i] = {
						itemName = itemInSlot:GetName(),
						cd = itemInSlot:GetCooldownTimeRemaining() or 0,
						charges = itemInSlot:GetCurrentCharges() or 0,
					}
				end
			end
		end

		UTIL_Remove(playerHero)
		local new_hero = PlayerResource:ReplaceHeroWith(playerID, heroName, gold, 0)

		if (restoreExp == true) then
			for _ = 1, (level - 1) do
				new_hero:HeroLevelUp(false)
			end
		end

		if (restoreItems == true) then
			for _, itemData in pairs(allHeroItems) do
				local item = new_hero:AddItemByName(itemData.itemName)
				if item then
					item:StartCooldown(itemData.cd)
					item:SetCurrentCharges(itemData.charges)
				end
			end
		end

		return new_hero
	end
end

function GetRealHero(hAttacker)
    if not hAttacker then
        return hAttacker
    end
    
    if hAttacker.IsRealHero and hAttacker.IsIllusion and not hAttacker:IsRealHero() and not hAttacker:IsIllusion() then
        local owner = hAttacker:GetOwner()
        if owner and owner:IsBaseNPC() then
            return owner
        end
    end
    if hAttacker.IsRealHero and hAttacker.IsIllusion and hAttacker:IsRealHero() and not hAttacker:IsIllusion() and hAttacker.IS_CUSTOM_ILLUSION_RD then
        local playerID = hAttacker:GetPlayerID()
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        if hero then
            return hero
        end
    end
    if hAttacker.IsHero and hAttacker.IsIllusion and hAttacker:IsHero() and hAttacker:IsIllusion() then
        local playerID = hAttacker:GetPlayerID()
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        if hero then
            return hero
        end
    end
    return hAttacker
end

function IsSolo()
	return GetMapName() == "overvodka_solo"
end

function IsDuo()
	return GetMapName() == "overvodka_duo"
end

function Is5v5()
	return GetMapName() == "overvodka_5x5"
end

function GetCurrentCategory()
	if IsSolo() then 
		return GAME_CATEGORY_DEFINITIONS.SOLO
	elseif IsDuo() then 
		return GAME_CATEGORY_DEFINITIONS.DUO
	elseif Is5v5() then
		return GAME_CATEGORY_DEFINITIONS.DOTA
	end

	return GAME_CATEGORY_DEFINITIONS.NONE
end