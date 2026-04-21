require("server/server_settings")
local DefaultGuidesData = require("server/default_guides_data")
local ShopItemsData = require("server/shop_items_data")

if Guides == nil then
    Guides = class({})
end

local GUIDES_LIST_CACHE_TTL = 60
local GUIDES_DETAIL_CACHE_TTL = 120
local DEFAULT_GUIDE_ID = 0
local DEFAULT_GUIDE_SECTION_ORDER = { "starting", "early", "core", "luxury", "situational" }
local GUIDE_ITEM_NAME_REMAP = {
    item_octarine_core = "item_octarine_vodka",
    item_heart = "item_heart_vodka",
    item_bloodstone = "item_bloodstone_vodka",
}
local DEFAULT_GUIDE_SECTION_KEY_BY_TOKEN = {
    ["#DOTA_Item_Build_Starting_Items"] = "starting",
    ["#DOTA_Item_Build_Early_Game"] = "early",
    ["#DOTA_Item_Build_Mid_Items"] = "core",
    ["#DOTA_Item_Build_Core_Items"] = "core",
    ["#DOTA_Item_Build_Late_Items"] = "core",
    ["#DOTA_Item_Build_Luxury"] = "luxury",
}

function Guides:NormalizeGuideItemNameForGame(itemName)
    local normalized = tostring(itemName or "")
    return GUIDE_ITEM_NAME_REMAP[normalized] or normalized
end

function Guides:IsGuideItemAvailableInShop(itemName)
    local normalized = self:NormalizeGuideItemNameForGame(itemName)
    return normalized ~= "" and type(ShopItemsData) == "table" and ShopItemsData[normalized] == true
end

function Guides:FilterGuideItemSectionsForGame(guide)
    if type(guide) ~= "table" or type(guide.item_sections) ~= "table" then
        return guide
    end

    local filteredSections = {}

    for _, section in ipairs(guide.item_sections) do
        if type(section) == "table" then
            local filteredItems = {}
            if type(section.items) == "table" then
                for _, itemEntry in ipairs(section.items) do
                    if type(itemEntry) == "table" then
                        local normalizedItemName = self:NormalizeGuideItemNameForGame(itemEntry.item_name)
                        if self:IsGuideItemAvailableInShop(normalizedItemName) then
                            itemEntry.item_name = normalizedItemName
                            table.insert(filteredItems, itemEntry)
                        end
                    end
                end
            end

            if #filteredItems > 0 then
                section.items = filteredItems
                table.insert(filteredSections, section)
            end
        end
    end

    guide.item_sections = filteredSections
    return guide
end

function Guides:GetDefaultGuideListEntry(heroScriptName)
    return {
        id = DEFAULT_GUIDE_ID,
        is_default_guide = 1,
        hero_script_name = heroScriptName,
        title = "STANDARD_GUIDE",
        summary = "STANDARD_GUIDE",
        author_display_name = "worstsup",
        updated_msk_date = "",
        rating = 0,
        likes_count = 0,
        dislikes_count = 0,
        viewer_vote = 0,
        is_favorite = 0,
        is_own_guide = 0,
        views_count = 0,
    }
end

function Guides:Init()
    if self.bStarted then
        return
    end

    self.bStarted = true
    self.ListCache = {}
    self.DetailCache = {}
    self.DefaultGuideCache = {}
    self.PlayerSelections = {}

    CustomGameEventManager:RegisterListener("guides_request_list", function(_, event)
        self:OnRequestList(event)
    end)
    CustomGameEventManager:RegisterListener("guides_select_guide", function(_, event)
        self:OnSelectGuide(event)
    end)
    CustomGameEventManager:RegisterListener("guides_request_preview", function(_, event)
        self:OnRequestPreview(event)
    end)
    CustomGameEventManager:RegisterListener("guides_request_skill_suggestion", function(_, event)
        self:OnRequestSkillSuggestion(event)
    end)
    CustomGameEventManager:RegisterListener("guides_vote_guide", function(_, event)
        self:OnVoteGuide(event)
    end)
    CustomGameEventManager:RegisterListener("guides_toggle_favorite", function(_, event)
        self:OnToggleFavorite(event)
    end)
end

function Guides:GetDefaultGuideFileCandidates(heroScriptName)
    local shortName = tostring(heroScriptName or ""):gsub("^npc_dota_hero_", "")
    if shortName == "" then
        return {}
    end

    local relativePath = "itembuilds/default_" .. shortName .. ".txt"
    local addonRootPath = "game/overvodka/" .. relativePath
    local runtimeAddonRootPath = "game/dota_addons/overvodka/" .. relativePath
    local scriptDirectory = self:GetCurrentScriptDirectory()
    local candidates = {}

    if scriptDirectory ~= "" then
        table.insert(candidates, scriptDirectory .. "/../../../" .. relativePath)
    end

    table.insert(candidates, relativePath)
    table.insert(candidates, runtimeAddonRootPath)
    table.insert(candidates, addonRootPath)
    table.insert(candidates, "./" .. relativePath)
    table.insert(candidates, "./" .. runtimeAddonRootPath)
    table.insert(candidates, "./" .. addonRootPath)
    table.insert(candidates, "../" .. relativePath)
    table.insert(candidates, "../" .. runtimeAddonRootPath)
    table.insert(candidates, "../../" .. runtimeAddonRootPath)
    table.insert(candidates, "../../" .. relativePath)
    table.insert(candidates, "../../../" .. runtimeAddonRootPath)
    table.insert(candidates, "../../../" .. relativePath)
    table.insert(candidates, "../../../../" .. runtimeAddonRootPath)
    table.insert(candidates, "../../../../" .. relativePath)

    return candidates
end

function Guides:GetCurrentScriptDirectory()
    if not debug or not debug.getinfo then
        return ""
    end

    local info = debug.getinfo(1, "S")
    local source = info and info.source or ""
    if type(source) ~= "string" or source == "" then
        return ""
    end

    if string.sub(source, 1, 1) == "@" then
        source = string.sub(source, 2)
    end

    return string.match(source, "^(.*)[/\\][^/\\]+$") or ""
end

function Guides:GetNpcScriptFileCandidates(fileName)
    local safeFileName = tostring(fileName or "")
    if safeFileName == "" then
        return {}
    end

    local relativePath = "scripts/npc/" .. safeFileName
    local addonRootPath = "game/overvodka/" .. relativePath
    local runtimeAddonRootPath = "game/dota_addons/overvodka/" .. relativePath
    local scriptDirectory = self:GetCurrentScriptDirectory()
    local candidates = {}

    if scriptDirectory ~= "" then
        table.insert(candidates, scriptDirectory .. "/../../npc/" .. safeFileName)
    end

    table.insert(candidates, relativePath)
    table.insert(candidates, runtimeAddonRootPath)
    table.insert(candidates, addonRootPath)
    table.insert(candidates, "./" .. relativePath)
    table.insert(candidates, "./" .. runtimeAddonRootPath)
    table.insert(candidates, "./" .. addonRootPath)
    table.insert(candidates, "../" .. relativePath)
    table.insert(candidates, "../" .. runtimeAddonRootPath)
    table.insert(candidates, "../../" .. relativePath)
    table.insert(candidates, "../../" .. runtimeAddonRootPath)

    return candidates
end

function Guides:LoadKeyValuesFromCandidates(candidates)
    if type(LoadKeyValues) ~= "function" or type(candidates) ~= "table" then
        return nil
    end

    for _, candidate in ipairs(candidates) do
        if type(candidate) ~= "string" or candidate == "" then
            goto continue
        end

        local ok, kv = pcall(LoadKeyValues, candidate)
        if ok and type(kv) == "table" and next(kv) ~= nil then
            return kv
        end

        ::continue::
    end

    return nil
end

function Guides:EnsureHeroAbilityOrderDataLoaded()
    if self.HeroAbilityOrderDataLoaded then
        return
    end

    self.HeroAbilityOrderDataLoaded = true
    self.HeroAbilityOrderCache = self.HeroAbilityOrderCache or {}
    self.HeroesCustomKV = self:LoadKeyValuesFromCandidates(self:GetNpcScriptFileCandidates("npc_heroes_custom.txt")) or {}
    self.HeroesBaseKV = self:LoadKeyValuesFromCandidates(self:GetNpcScriptFileCandidates("npc_heroes.txt")) or {}
end

function Guides:ShouldIncludeGuideAbilityInOrder(abilityName)
    if type(abilityName) ~= "string" or abilityName == "" then
        return false
    end

    if abilityName == "attribute_bonus" or string.sub(abilityName, 1, 14) == "special_bonus_" then
        return false
    end

    if string.find(abilityName, "^generic_hidden") then
        return false
    end

    if string.find(abilityName, "_shard", 1, true) or string.find(abilityName, "_scepter", 1, true) then
        return false
    end

    if string.find(string.lower(abilityName), "innate", 1, true) then
        return false
    end

    return true
end

function Guides:BuildHeroAbilityOrder(heroData)
    if type(heroData) ~= "table" then
        return {}
    end

    local order = {}
    local seen = {}

    for index = 1, 24 do
        local abilityName = tostring(heroData["Ability" .. tostring(index)] or "")
        if self:ShouldIncludeGuideAbilityInOrder(abilityName) and not seen[abilityName] then
            seen[abilityName] = true
            table.insert(order, abilityName)
        end
    end

    return order
end

function Guides:BuildHeroTalentTree(heroData)
    if type(heroData) ~= "table" then
        return {}
    end

    local talentAbilities = {}
    for index = 1, 24 do
        local abilityName = tostring(heroData["Ability" .. tostring(index)] or "")
        if string.sub(abilityName, 1, 14) == "special_bonus_" then
            table.insert(talentAbilities, abilityName)
        end
    end

    local levels = { 10, 15, 20, 25 }
    local tree = {}
    for pairIndex = 1, #levels do
        local leftAbility = talentAbilities[(pairIndex - 1) * 2 + 1]
        local rightAbility = talentAbilities[(pairIndex - 1) * 2 + 2]
        if leftAbility and rightAbility then
            tree[levels[pairIndex]] = {
                left_ability_name = leftAbility,
                right_ability_name = rightAbility,
            }
        end
    end

    return tree
end

function Guides:GetHeroAbilityOrder(heroScriptName)
    local safeHeroScriptName = self:NormalizeHeroScriptName(heroScriptName)
    if safeHeroScriptName == "" then
        return {}
    end

    self:EnsureHeroAbilityOrderDataLoaded()

    local cached = self.HeroAbilityOrderCache[safeHeroScriptName]
    if type(cached) == "table" then
        return cached
    end

    local heroData =
        (type(self.HeroesCustomKV) == "table" and self.HeroesCustomKV[safeHeroScriptName]) or
        (type(self.HeroesBaseKV) == "table" and self.HeroesBaseKV[safeHeroScriptName]) or
        nil

    local order = self:BuildHeroAbilityOrder(heroData)
    self.HeroAbilityOrderCache[safeHeroScriptName] = order
    return order
end

function Guides:GetHeroTalentTree(heroScriptName)
    local safeHeroScriptName = self:NormalizeHeroScriptName(heroScriptName)
    if safeHeroScriptName == "" then
        return {}
    end

    self:EnsureHeroAbilityOrderDataLoaded()
    self.HeroTalentTreeCache = self.HeroTalentTreeCache or {}

    local cached = self.HeroTalentTreeCache[safeHeroScriptName]
    if type(cached) == "table" then
        return cached
    end

    local heroData =
        (type(self.HeroesCustomKV) == "table" and self.HeroesCustomKV[safeHeroScriptName]) or
        (type(self.HeroesBaseKV) == "table" and self.HeroesBaseKV[safeHeroScriptName]) or
        nil

    local tree = self:BuildHeroTalentTree(heroData)
    self.HeroTalentTreeCache[safeHeroScriptName] = tree
    return tree
end

function Guides:AttachAbilityOrderToGuide(guide)
    if type(guide) ~= "table" then
        return guide
    end

    local heroScriptName = self:NormalizeHeroScriptName(guide.hero_script_name)
    if heroScriptName == "" then
        return guide
    end

    guide.ability_order = self:GetHeroAbilityOrder(heroScriptName)
    guide.talent_tree = self:GetHeroTalentTree(heroScriptName)
    return guide
end

function Guides:DefaultGuideHasParsedContent(guide)
    if type(guide) ~= "table" then
        return false
    end

    return type(guide.item_sections) == "table" and #guide.item_sections > 0
end

function Guides:GetBundledDefaultGuideData(heroScriptName)
    if type(DefaultGuidesData) ~= "table" then
        return nil
    end

    local bundled = DefaultGuidesData[heroScriptName]
    if type(bundled) ~= "table" or type(bundled.item_sections) ~= "table" or #bundled.item_sections == 0 then
        return nil
    end

    return bundled
end

function Guides:ReadDefaultGuideFile(heroScriptName)
    if not io or not io.open then
        return nil
    end

    for _, candidate in ipairs(self:GetDefaultGuideFileCandidates(heroScriptName)) do
        if type(candidate) ~= "string" or candidate == "" then
            goto continue
        end

        local file = io.open(candidate, "r")
        if file then
            local content = file:read("*a")
            file:close()
            if type(content) == "string" and content ~= "" then
                return content
            end
        end

        ::continue::
    end

    return nil
end

function Guides:LoadDefaultGuideKeyValues(heroScriptName)
    if type(LoadKeyValues) ~= "function" then
        return nil
    end

    for _, candidate in ipairs(self:GetDefaultGuideFileCandidates(heroScriptName)) do
        if type(candidate) ~= "string" or candidate == "" then
            goto continue
        end

        local ok, kv = pcall(LoadKeyValues, candidate)
        if ok and type(kv) == "table" and next(kv) ~= nil then
            return kv
        end

        ::continue::
    end

    return nil
end

function Guides:ParseDefaultGuideSections(content)
    local depth = 0
    local pendingItemsBlock = false
    local itemsBlockDepth = nil
    local insideItemsBlock = false
    local pendingSectionToken = nil
    local currentSection = nil
    local currentSectionDepth = nil
    local result = {}

    for rawLine in tostring(content or ""):gmatch("[^\r\n]+") do
        local line = rawLine:gsub("//.*$", "")
        local trimmed = line:match("^%s*(.-)%s*$")
        local token = trimmed:match('^"([^"]+)"')
        local depthBefore = depth
        local openCount = select(2, line:gsub("{", ""))
        local closeCount = select(2, line:gsub("}", ""))

        if token == "Items" then
            pendingItemsBlock = true
        elseif insideItemsBlock and token and DEFAULT_GUIDE_SECTION_KEY_BY_TOKEN[token] then
            pendingSectionToken = token
        end

        if pendingItemsBlock and openCount > 0 then
            insideItemsBlock = true
            itemsBlockDepth = depthBefore + openCount
            pendingItemsBlock = false
        end

        if pendingSectionToken and openCount > 0 then
            currentSection = {
                key = pendingSectionToken,
                title = pendingSectionToken,
                items = {},
            }
            table.insert(result, currentSection)
            currentSectionDepth = depthBefore + openCount
            pendingSectionToken = nil
        end

        if currentSection then
            for itemName in line:gmatch('"item"%s*"([^"]+)"') do
                table.insert(currentSection.items, {
                    item_name = itemName,
                    note = "",
                })
            end
        end

        depth = depthBefore + openCount - closeCount

        if currentSection and depth < currentSectionDepth then
            currentSection = nil
            currentSectionDepth = nil
        end

        if insideItemsBlock and depth < itemsBlockDepth then
            insideItemsBlock = false
            itemsBlockDepth = nil
        end
    end

    return result
end

function Guides:AppendDefaultGuideItemsFromKV(value, result)
    if type(value) == "string" then
        if string.match(value, "^item_") then
            table.insert(result, {
                item_name = value,
                note = "",
            })
        end
        return
    end

    if type(value) ~= "table" then
        return
    end

    if type(value.item) == "string" then
        self:AppendDefaultGuideItemsFromKV(value.item, result)
    end

    local numericIndex = 1
    while value[numericIndex] ~= nil do
        self:AppendDefaultGuideItemsFromKV(value[numericIndex], result)
        numericIndex = numericIndex + 1
    end

    for key, nestedValue in pairs(value) do
        if key ~= "item" and type(key) ~= "number" then
            self:AppendDefaultGuideItemsFromKV(nestedValue, result)
        end
    end
end

function Guides:ParseDefaultGuideSectionsFromKV(kv)
    local root = kv
    if type(root.itembuilds) == "table" then
        root = root.itembuilds
    end

    local itemsRoot = type(root.Items) == "table" and root.Items or nil
    if not itemsRoot then
        return {}
    end

    local sectionsByKey = {}
    local orderedSections = {}

    for _, sectionOrderKey in ipairs(DEFAULT_GUIDE_SECTION_ORDER) do
        sectionsByKey[sectionOrderKey] = {
            key = sectionOrderKey,
            title = "",
            items = {},
        }
    end

    for sectionToken, sectionValue in pairs(itemsRoot) do
        if type(sectionToken) == "string" then
            local normalizedKey = DEFAULT_GUIDE_SECTION_KEY_BY_TOKEN[sectionToken]
            if normalizedKey and sectionsByKey[normalizedKey] then
                local section = sectionsByKey[normalizedKey]
                section.key = normalizedKey
                section.title = sectionToken
                self:AppendDefaultGuideItemsFromKV(sectionValue, section.items)
            end
        end
    end

    for _, sectionOrderKey in ipairs(DEFAULT_GUIDE_SECTION_ORDER) do
        local section = sectionsByKey[sectionOrderKey]
        if section and #section.items > 0 then
            if section.title == "" then
                section.title = section.key
            end
            table.insert(orderedSections, section)
        end
    end

    return orderedSections
end

function Guides:GetDefaultGuide(heroScriptName)
    if heroScriptName == "" then
        return nil
    end

    local cached = self.DefaultGuideCache[heroScriptName]
    if cached and self:DefaultGuideHasParsedContent(cached) then
        return cached
    end

    local bundledDefaultGuide = self:GetBundledDefaultGuideData(heroScriptName)
    if bundledDefaultGuide then
        local guide = {
            id = DEFAULT_GUIDE_ID,
            is_default_guide = 1,
            hero_script_name = heroScriptName,
            title = "STANDARD_GUIDE",
            summary = "STANDARD_GUIDE",
            author_display_name = "worstsup",
            updated_msk_date = "",
            rating = 0,
            likes_count = 0,
            dislikes_count = 0,
            viewer_vote = 0,
            is_favorite = 0,
            is_own_guide = 0,
            views_count = 0,
            item_sections = bundledDefaultGuide.item_sections,
            skill_build = {},
            talent_choices = {},
        }

        self.DefaultGuideCache[heroScriptName] = guide
        return guide
    end

    local content = self:ReadDefaultGuideFile(heroScriptName)
    local parsedSections = content and self:ParseDefaultGuideSections(content) or {}

    if #parsedSections == 0 then
        local kv = self:LoadDefaultGuideKeyValues(heroScriptName)
        if type(kv) == "table" then
            parsedSections = self:ParseDefaultGuideSectionsFromKV(kv)
        end
    end

    local guide = {
        id = DEFAULT_GUIDE_ID,
        is_default_guide = 1,
        hero_script_name = heroScriptName,
        title = "STANDARD_GUIDE",
        summary = "STANDARD_GUIDE",
        author_display_name = "worstsup",
        updated_msk_date = "",
        rating = 0,
        likes_count = 0,
        dislikes_count = 0,
        viewer_vote = 0,
        is_favorite = 0,
        is_own_guide = 0,
        views_count = 0,
        item_sections = parsedSections,
        skill_build = {},
        talent_choices = {},
    }

    self.DefaultGuideCache[heroScriptName] = guide
    return guide
end

function Guides:BuildGuidesListWithDefault(heroScriptName, guides)
    local result = {
        self:GetDefaultGuideListEntry(heroScriptName),
    }

    if type(guides) == "table" then
        for _, guide in ipairs(guides) do
            table.insert(result, guide)
        end
    end

    return result
end

function Guides:SelectDefaultGuideForPlayer(playerID, heroScriptName)
    local normalizedHeroScriptName = self:NormalizeHeroScriptName(heroScriptName)
    if normalizedHeroScriptName == "" then
        return nil
    end

    local guide = self:GetDefaultGuide(normalizedHeroScriptName)
    if not guide then
        return nil
    end

    self.PlayerSelections[playerID] = {
        hero_script_name = normalizedHeroScriptName,
        guide_id = DEFAULT_GUIDE_ID,
    }

    return guide
end

function Guides:NormalizeHeroScriptName(value)
    if type(value) ~= "string" then
        return ""
    end

    local hero = value:gsub("^%s+", ""):gsub("%s+$", "")
    if hero:match("^[%w_]+$") then
        return hero
    end

    return ""
end

function Guides:GetNow()
    return GameRules:GetGameTime()
end

function Guides:GetCached(cache, key)
    local entry = cache[key]
    if not entry then
        return nil
    end

    if entry.expires_at <= self:GetNow() then
        cache[key] = nil
        return nil
    end

    return entry.data
end

function Guides:SetCached(cache, key, data, ttl)
    cache[key] = {
        data = data,
        expires_at = self:GetNow() + ttl,
    }
end

function Guides:SendRequest(endpoint, payload, callback)
    if IsInToolsMode() or GameRules:IsCheatMode() then
        if callback then
            callback(nil)
        end
        return
    end

    if Server and Server.SendRequest then
        Server:SendRequest(SERVER_URL .. endpoint, payload or {}, function(result)
            if callback then
                callback(result)
            end
        end, true)
        return
    end

    if callback then
        callback(nil)
    end
end

function Guides:MakeListCacheKey(heroScriptName, steamID)
    return tostring(heroScriptName or "") .. ":" .. tostring(steamID or "0")
end

function Guides:FetchGuideList(heroScriptName, steamID, callback)
    local cacheKey = self:MakeListCacheKey(heroScriptName, steamID)
    local cached = self:GetCached(self.ListCache, cacheKey)
    if cached then
        callback(cached)
        return
    end

    self:SendRequest("get_guides_for_hero", {
        hero_script_name = heroScriptName,
        SteamID = steamID,
    }, function(response)
        if response and response.ok == 1 then
            self:SetCached(self.ListCache, cacheKey, response, GUIDES_LIST_CACHE_TTL)
            callback(response)
            return
        end

        callback(nil)
    end)
end

function Guides:GetPlayerSteamID(playerID)
    if not PlayerResource:IsValidPlayerID(playerID) then
        return nil
    end

    local steamID = PlayerResource:GetSteamAccountID(playerID)
    if not steamID or steamID == 0 then
        return nil
    end

    return tostring(steamID)
end

function Guides:MakeDetailCacheKey(guideID, steamID)
    return tostring(guideID) .. ":" .. tostring(steamID or "0")
end

function Guides:FetchGuideDetail(guideID, steamID, callback)
    local cacheKey = self:MakeDetailCacheKey(guideID, steamID)
    local cached = self:GetCached(self.DetailCache, cacheKey)
    if cached then
        callback(cached)
        return
    end

    self:SendRequest("get_guide_for_game", {
        guide_id = guideID,
        SteamID = steamID,
    }, function(response)
        if response and response.ok == 1 and response.guide then
            self:SetCached(self.DetailCache, cacheKey, response, GUIDES_DETAIL_CACHE_TTL)
            callback(response)
            return
        end

        callback(nil)
    end)
end

function Guides:InvalidateGuideCaches(guideID, heroScriptName)
    local guideKeyPrefix = tostring(guideID) .. ":"
    self.DetailCache[tostring(guideID)] = nil

    for cacheKey in pairs(self.DetailCache) do
        if type(cacheKey) == "string" and string.sub(cacheKey, 1, string.len(guideKeyPrefix)) == guideKeyPrefix then
            self.DetailCache[cacheKey] = nil
        end
    end

    if heroScriptName and heroScriptName ~= "" then
        local listKeyPrefix = tostring(heroScriptName) .. ":"
        for cacheKey in pairs(self.ListCache) do
            if type(cacheKey) == "string" and string.sub(cacheKey, 1, string.len(listKeyPrefix)) == listKeyPrefix then
                self.ListCache[cacheKey] = nil
            end
        end
    end
end

function Guides:IsGuideInList(guideID, list)
    if type(list) ~= "table" then
        return false
    end

    for _, guide in ipairs(list) do
        if tonumber(guide.id) == tonumber(guideID) then
            return true
        end
    end

    return false
end

function Guides:SendListResponse(playerID, heroScriptName, guides, selectedGuideID)
    local player = PlayerResource:GetPlayer(playerID)
    if not player then
        return
    end

    CustomGameEventManager:Send_ServerToPlayer(player, "guides_list_response", {
        hero_script_name = heroScriptName,
        selected_guide_id = selectedGuideID or 0,
        count = type(guides) == "table" and #guides or 0,
        guides = guides or {},
    })
end

function Guides:SendGuideResponse(playerID, guide)
    local player = PlayerResource:GetPlayer(playerID)
    if not player or not guide then
        return
    end

    self:AttachAbilityOrderToGuide(guide)
    self:FilterGuideItemSectionsForGame(guide)

    CustomGameEventManager:Send_ServerToPlayer(player, "guides_guide_response", {
        guide = guide,
    })
end

function Guides:SendPreviewResponse(playerID, guide)
    local player = PlayerResource:GetPlayer(playerID)
    if not player or not guide then
        return
    end

    self:AttachAbilityOrderToGuide(guide)
    self:FilterGuideItemSectionsForGame(guide)

    CustomGameEventManager:Send_ServerToPlayer(player, "guides_preview_response", {
        guide = guide,
    })
end

function Guides:SendSkillSuggestionResponse(playerID, heroScriptName, guide)
    local player = PlayerResource:GetPlayer(playerID)
    if not player then
        return
    end

    self:AttachAbilityOrderToGuide(guide)
    self:FilterGuideItemSectionsForGame(guide)

    CustomGameEventManager:Send_ServerToPlayer(player, "guides_skill_suggestion_response", {
        hero_script_name = heroScriptName or "",
        guide = guide,
    })
end

function Guides:SendVoteResponse(playerID, payload)
    local player = PlayerResource:GetPlayer(playerID)
    if not player then
        return
    end

    CustomGameEventManager:Send_ServerToPlayer(player, "guides_vote_response", payload or {})
end

function Guides:SendFavoriteResponse(playerID, payload)
    local player = PlayerResource:GetPlayer(playerID)
    if not player then
        return
    end

    CustomGameEventManager:Send_ServerToPlayer(player, "guides_favorite_response", payload or {})
end

function Guides:SendError(playerID, errorCode)
    local player = PlayerResource:GetPlayer(playerID)
    if not player then
        return
    end

    CustomGameEventManager:Send_ServerToPlayer(player, "guides_error_response", {
        error = errorCode or "unknown",
    })
end

function Guides:OnRequestList(event)
    local playerID = event.PlayerID
    if not PlayerResource:IsValidPlayerID(playerID) then
        return
    end
    local steamID = self:GetPlayerSteamID(playerID)

    local heroScriptName = self:NormalizeHeroScriptName(event.hero_script_name or event.hero)
    if heroScriptName == "" then
        self:SendListResponse(playerID, "", {}, 0)
        return
    end

    self:FetchGuideList(heroScriptName, steamID, function(response)
        local requestFailed = not response or response.ok ~= 1
        local guides = {}
        if response and type(response.guides) == "table" then
            guides = response.guides
        end

        guides = self:BuildGuidesListWithDefault(heroScriptName, guides)

        local selection = self.PlayerSelections[playerID]
        local selectedGuideID = selection and selection.hero_script_name == heroScriptName and selection.guide_id or nil

        if not self:IsGuideInList(selectedGuideID, guides) then
            selectedGuideID = DEFAULT_GUIDE_ID
        end

        if requestFailed then
            selectedGuideID = DEFAULT_GUIDE_ID
        end

        self.PlayerSelections[playerID] = {
            hero_script_name = heroScriptName,
            guide_id = selectedGuideID,
        }

        self:SendListResponse(playerID, heroScriptName, guides, selectedGuideID or 0)

        if requestFailed then
            local defaultGuide = self:SelectDefaultGuideForPlayer(playerID, heroScriptName)
            if defaultGuide then
                self:SendGuideResponse(playerID, defaultGuide)
            end
            return
        end

        if selectedGuideID ~= DEFAULT_GUIDE_ID and selectedGuideID then
            self:FetchGuideDetail(selectedGuideID, steamID, function(detailResponse)
                if detailResponse and detailResponse.guide then
                    self:SendGuideResponse(playerID, detailResponse.guide)
                    return
                end

                local defaultGuide = self:SelectDefaultGuideForPlayer(playerID, heroScriptName)
                if defaultGuide then
                    self:SendGuideResponse(playerID, defaultGuide)
                end
            end)
        end
    end)
end

function Guides:OnSelectGuide(event)
    local playerID = event.PlayerID
    if not PlayerResource:IsValidPlayerID(playerID) then
        return
    end
    local steamID = self:GetPlayerSteamID(playerID)

    local guideID = tonumber(event.guide_id or 0)
    if guideID == nil or guideID < 0 then
        self:SendError(playerID, "bad_guide_id")
        return
    end

    local heroScriptName = self:NormalizeHeroScriptName(event.hero_script_name or event.hero)
    if heroScriptName == "" then
        local selection = self.PlayerSelections[playerID]
        if selection and type(selection.hero_script_name) == "string" then
            heroScriptName = self:NormalizeHeroScriptName(selection.hero_script_name)
        end
    end

    local currentSelection = self.PlayerSelections[playerID]
    if currentSelection and
        self:NormalizeHeroScriptName(currentSelection.hero_script_name or "") == heroScriptName and
        tonumber(currentSelection.guide_id or DEFAULT_GUIDE_ID) == guideID then
        return
    end

    if guideID == DEFAULT_GUIDE_ID then
        if heroScriptName == "" then
            self:SendError(playerID, "bad_hero")
            return
        end

        self.PlayerSelections[playerID] = {
            hero_script_name = heroScriptName,
            guide_id = DEFAULT_GUIDE_ID,
        }

        self:SendGuideResponse(playerID, self:GetDefaultGuide(heroScriptName))
        return
    end

    self:FetchGuideDetail(guideID, steamID, function(response)
        if not response or not response.guide then
            local defaultGuide = self:SelectDefaultGuideForPlayer(playerID, heroScriptName)
            if defaultGuide then
                self:SendGuideResponse(playerID, defaultGuide)
                return
            end

            self:SendError(playerID, "guide_not_found")
            return
        end

        local guide = response.guide
        self.PlayerSelections[playerID] = {
            hero_script_name = guide.hero_script_name or "",
            guide_id = tonumber(guide.id) or guideID,
        }

        self:SendGuideResponse(playerID, guide)
    end)
end

function Guides:OnRequestPreview(event)
    local playerID = event.PlayerID
    if not PlayerResource:IsValidPlayerID(playerID) then
        return
    end

    local steamID = self:GetPlayerSteamID(playerID)
    local guideID = tonumber(event.guide_id or 0)
    if guideID == nil or guideID < 0 then
        return
    end

    local heroScriptName = self:NormalizeHeroScriptName(event.hero_script_name or event.hero)
    if guideID == DEFAULT_GUIDE_ID then
        if heroScriptName ~= "" then
            self:SendPreviewResponse(playerID, self:GetDefaultGuide(heroScriptName))
        end
        return
    end

    self:FetchGuideDetail(guideID, steamID, function(response)
        if response and response.guide then
            self:SendPreviewResponse(playerID, response.guide)
        end
    end)
end

function Guides:OnRequestSkillSuggestion(event)
    local playerID = event.PlayerID
    if not PlayerResource:IsValidPlayerID(playerID) then
        return
    end
    local steamID = self:GetPlayerSteamID(playerID)

    local heroScriptName = self:NormalizeHeroScriptName(event.hero_script_name or event.hero)
    if heroScriptName == "" then
        self:SendSkillSuggestionResponse(playerID, "", nil)
        return
    end

    self:FetchGuideList(heroScriptName, steamID, function(response)
        local guides = {}
        if response and type(response.guides) == "table" then
            guides = response.guides
        end

        guides = self:BuildGuidesListWithDefault(heroScriptName, guides)

        local selection = self.PlayerSelections[playerID]
        local selectedGuideID = selection and selection.hero_script_name == heroScriptName and selection.guide_id or nil

        if not self:IsGuideInList(selectedGuideID, guides) then
            selectedGuideID = DEFAULT_GUIDE_ID
        end

        self.PlayerSelections[playerID] = {
            hero_script_name = heroScriptName,
            guide_id = selectedGuideID,
        }

        if selectedGuideID == DEFAULT_GUIDE_ID then
            self:SendSkillSuggestionResponse(playerID, heroScriptName, self:GetDefaultGuide(heroScriptName))
            return
        end

        self:FetchGuideDetail(selectedGuideID, steamID, function(detailResponse)
            local guide = detailResponse and detailResponse.guide or nil
            if not guide or self:NormalizeHeroScriptName(guide.hero_script_name or "") ~= heroScriptName then
                guide = self:GetDefaultGuide(heroScriptName)
            end

            self:SendSkillSuggestionResponse(playerID, heroScriptName, guide)
        end)
    end)
end

function Guides:OnVoteGuide(event)
    local playerID = event.PlayerID
    if not PlayerResource:IsValidPlayerID(playerID) then
        return
    end

    local guideID = tonumber(event.guide_id or 0)
    local voteValue = tonumber(event.value or 0)
    local steamID = self:GetPlayerSteamID(playerID)

    if not steamID then
        self:SendVoteResponse(playerID, { ok = 0, error = "bad_steamid" })
        return
    end

    if not guideID or guideID <= 0 then
        self:SendVoteResponse(playerID, { ok = 0, error = "bad_guide_id", guide_id = guideID or 0 })
        return
    end

    if voteValue ~= 1 and voteValue ~= -1 then
        self:SendVoteResponse(playerID, { ok = 0, error = "bad_vote_value", guide_id = guideID })
        return
    end

    self:SendRequest("vote_guide_for_game", {
        SteamID = steamID,
        guide_id = guideID,
        value = voteValue,
    }, function(response)
        if response and response.ok == 1 then
            self:InvalidateGuideCaches(guideID, self:NormalizeHeroScriptName(response.hero_script_name or ""))
            self:SendVoteResponse(playerID, response)
            return
        end

        self:SendVoteResponse(playerID, {
            ok = 0,
            guide_id = guideID,
            error = response and response.error or "vote_failed",
        })
    end)
end

function Guides:OnToggleFavorite(event)
    local playerID = event.PlayerID
    if not PlayerResource:IsValidPlayerID(playerID) then
        return
    end

    local guideID = tonumber(event.guide_id or 0)
    local steamID = self:GetPlayerSteamID(playerID)

    if not steamID then
        self:SendFavoriteResponse(playerID, { ok = 0, error = "bad_steamid" })
        return
    end

    if not guideID or guideID <= 0 then
        self:SendFavoriteResponse(playerID, { ok = 0, error = "bad_guide_id", guide_id = guideID or 0 })
        return
    end

    self:SendRequest("toggle_guide_favorite_for_game", {
        SteamID = steamID,
        guide_id = guideID,
    }, function(response)
        if response and response.ok == 1 then
            self:InvalidateGuideCaches(guideID, self:NormalizeHeroScriptName(response.hero_script_name or ""))
            self:SendFavoriteResponse(playerID, response)
            return
        end

        self:SendFavoriteResponse(playerID, {
            ok = 0,
            guide_id = guideID,
            error = response and response.error or "favorite_failed",
        })
    end)
end

if not Guides.bStarted then
    Guides:Init()
end
