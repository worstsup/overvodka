LinkLuaModifier("modifier_subscriber_effect", "modifiers/modifier_subscriber_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_win_condition", "modifiers/modifier_win_condition", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sans_arcana", "modifiers/modifier_sans_arcana", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invincible_arcana", "modifiers/modifier_invincible_arcana", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_overvodka_pet", "modifiers/modifier_overvodka_pet", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_overvodka_store_effect_1", "modifiers/store/modifier_overvodka_store_effect_1", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_overvodka_store_effect_2", "modifiers/store/modifier_overvodka_store_effect_2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_overvodka_store_effect_3", "modifiers/store/modifier_overvodka_store_effect_3", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_overvodka_store_skin_1", "modifiers/store/modifier_overvodka_store_skin_1", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_overvodka_store_skin_2", "modifiers/store/modifier_overvodka_store_skin_2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_overvodka_store_skin_3", "modifiers/store/modifier_overvodka_store_skin_3", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_overvodka_store_skin_4", "modifiers/store/modifier_overvodka_store_skin_4", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_overvodka_store_pet_1", "modifiers/store/modifier_overvodka_store_pet_1", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_overvodka_store_pet_2", "modifiers/store/modifier_overvodka_store_pet_2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_overvodka_store_pet_3", "modifiers/store/modifier_overvodka_store_pet_3", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_overvodka_store_pet_4", "modifiers/store/modifier_overvodka_store_pet_4", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_overvodka_store_pet_5", "modifiers/store/modifier_overvodka_store_pet_5", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_overvodka_store_pet_6", "modifiers/store/modifier_overvodka_store_pet_6", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_overvodka_store_pet_7", "modifiers/store/modifier_overvodka_store_pet_7", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_overvodka_store_pet_8", "modifiers/store/modifier_overvodka_store_pet_8", LUA_MODIFIER_MOTION_NONE)

GAME_CATEGORY_DEFINITIONS = {
	NONE = 0,
	SOLO = 1,
	DUO = 2,
	DOTA = 3,
}

OVERVODKA_DISABLED_EBASHER = {
	["npc_dota_hero_meepo"] = true,
	["npc_dota_hero_furion"] = true,
	["npc_dota_hero_juggernaut"] = true
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

function RollPseudoRandom(base_chance, entity)
	local chances_table = {
		{1, 0.015604},
		{2, 0.062009},
		{3, 0.138618},
		{4, 0.244856},
		{5, 0.380166},
		{6, 0.544011},
		{7, 0.735871},
		{8, 0.955242},
		{9, 1.201637},
		{10, 1.474584},
		{11, 1.773627},
		{12, 2.098323},
		{13, 2.448241},
		{14, 2.822965},
		{15, 3.222091},
		{16, 3.645227},
		{17, 4.091991},
		{18, 4.562014},
		{19, 5.054934},
		{20, 5.570404},
		{21, 6.108083},
		{22, 6.667640},
		{23, 7.248754},
		{24, 7.851112},
		{25, 8.474409},
		{26, 9.118346},
		{27, 9.782638},
		{28, 10.467023},
		{29, 11.171176},
		{30, 11.894919},
		{31, 12.637932},
		{32, 13.400086},
		{33, 14.180520},
		{34, 14.981009},
		{35, 15.798310},
		{36, 16.632878},
		{37, 17.490924},
		{38, 18.362465},
		{39, 19.248596},
		{40, 20.154741},
		{41, 21.092003},
		{42, 22.036458},
		{43, 22.989868},
		{44, 23.954015},
		{45, 24.930700},
		{46, 25.987235},
		{47, 27.045294},
		{48, 28.100764},
		{49, 29.155227},
		{50, 30.210303},
		{51, 31.267664},
		{52, 32.329055},
		{53, 33.411996},
		{54, 34.736999},
		{55, 36.039785},
		{56, 37.321683},
		{57, 38.583961},
		{58, 39.827833},
		{59, 41.054464},
		{60, 42.264973},
		{61, 43.460445},
		{62, 44.641928},
		{63, 45.810444},
		{64, 46.966991},
		{65, 48.112548},
		{66, 49.248078},
		{67, 50.746269},
		{68, 52.941176},
		{69, 55.072464},
		{70, 57.142857},
		{71, 59.154930},
		{72, 61.111111},
		{73, 63.013699},
		{74, 64.864865},
		{75, 66.666667},
		{76, 68.421053},
		{77, 70.129870},
		{78, 71.794872},
		{79, 73.417722},
		{80, 75.000000},
		{81, 76.543210},
		{82, 78.048780},
		{83, 79.518072},
		{84, 80.952381},
		{85, 82.352941},
		{86, 83.720930},
		{87, 85.057471},
		{88, 86.363636},
		{89, 87.640449},
		{90, 88.888889},
		{91, 90.109890},
		{92, 91.304348},
		{93, 92.473118},
		{94, 93.617021},
		{95, 94.736842},
		{96, 95.833333},
		{97, 96.907216},
		{98, 97.959184},
		{99, 98.989899},	
		{100, 100}
	}

	entity.pseudoRandomModifier = entity.pseudoRandomModifier or 0
	local prngBase
	for i = 1, #chances_table do
		if base_chance == chances_table[i][1] then		  
			prngBase = chances_table[i][2]
		end	 
	end

	if not prngBase then
		return false
	end
	
	if RollPercentage( prngBase + entity.pseudoRandomModifier ) then
		entity.pseudoRandomModifier = 0
		return true
	else
		entity.pseudoRandomModifier = entity.pseudoRandomModifier + prngBase		
		return false
	end
end

function IsComebackTeam(TeamID)
	local CurrentTeams = OvervodkaGameMode:GetSortedValidActiveTeams()
	local bIsFirstBlooded = OvervodkaGameMode:IsFirstBlooded()

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
	local CurrentTeams = OvervodkaGameMode:GetSortedValidActiveTeams()
	local bIsFirstBlooded = OvervodkaGameMode:IsFirstBlooded()

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

function SortUnits_HeroesFirst(units)
    local heroes = {}
    local others = {}

    for idx, unit in ipairs(units) do
        if unit:IsHero() then
            heroes[#heroes + 1] = unit
        else
            others[#others + 1] = unit
        end
    end

    local sorted = {}
    for i = 1, #heroes do
        sorted[#sorted + 1] = heroes[i]
    end
    for i = 1, #others do
        sorted[#sorted + 1] = others[i]
    end

    return sorted
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