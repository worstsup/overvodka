if Quests == nil then
    Quests = {}
end

function Quests:Init()
    self.qStarted = true
    self.progress = {}
    ListenToGameEvent("player_connect_full", Dynamic_Wrap(Quests, "OnPlayerConnectFull"), self)
    ListenToGameEvent("entity_killed", Dynamic_Wrap(Quests, "OnEntityKilled"), self)
    ListenToGameEvent("dota_player_used_ability", Dynamic_Wrap(Quests, "OnAbilityUsed"), self)
    ListenToGameEvent("entity_hurt", Dynamic_Wrap(Quests, "OnEntityHurt"), self)
end

function Quests:OnPlayerConnectFull(event)
    local playerID = event.PlayerID
    if playerID and playerID >= 0 then
        self:InitializeForPlayer(playerID)
    end
end

function Quests:InitializeForPlayer(playerID)
    self.progress[playerID] = { kills = 0, ults = 0, magicDamage = 0 }
    self:UpdateQuestForPlayer(playerID, "kills", 0)
    self:UpdateQuestForPlayer(playerID, "ults",  0)
    self:UpdateQuestForPlayer(playerID, "magicDamage", 0)
    self:UpdateQuestForPlayer(playerID, "physDamage", 0)
end

function Quests:UpdateQuestForPlayer(playerID, questId, value)
    local player = PlayerResource:GetPlayer(playerID)
    if player then
        CustomGameEventManager:Send_ServerToPlayer(player, "quests_update_progress", {questId = questId,value = value})
    end
end

function Quests:OnEntityKilled(event)
    local attackerIndex = event.entindex_attacker
    if not attackerIndex then return end
    local killer = EntIndexToHScript(attackerIndex)
    if not killer or not killer:IsHero() then return end

    local playerID = killer:GetPlayerOwnerID()
    if not self.progress[playerID] then return end

    self.progress[playerID].kills = self.progress[playerID].kills + 1
    self:UpdateQuestForPlayer(playerID, "kills", self.progress[playerID].kills)
end

function Quests:OnAbilityUsed(event)
    local playerID    = event.PlayerID
    local abilityName = event.abilityname
    if not playerID or playerID < 0 or not abilityName then return end
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    if not hero then return end
    local ability = hero:FindAbilityByName(abilityName)
    if not ability then return end
    if ability:GetAbilityType() ~= ABILITY_TYPE_ULTIMATE then return end
    self.progress[playerID].ults = self.progress[playerID].ults + 1
    self:UpdateQuestForPlayer(playerID, "ults", self.progress[playerID].ults)
end


function Quests:OnEntityHurt(event)
    local attackerIndex  = event.entindex_attacker
    local inflictorIndex = event.entindex_inflictor
    local damage         = math.floor(event.damage or 0)
    if not attackerIndex or damage <= 0 then return end
    local hero = EntIndexToHScript(attackerIndex)
    if not hero or not hero:IsHero() then return end

    local playerID = hero:GetPlayerOwnerID()
    if not self.progress[playerID] then return end
    local isMagic    = false
    local isPhysical = false

    if inflictorIndex then
        local ability = EntIndexToHScript(inflictorIndex)
        if ability and ability.GetAbilityDamageType then
            local dt = ability:GetAbilityDamageType()
            if dt == DAMAGE_TYPE_MAGICAL then
                isMagic = true
            elseif dt == DAMAGE_TYPE_PHYSICAL then
                isPhysical = true
            end
        end
    else
        isPhysical = true
    end
    if isMagic then
        self.progress[playerID].magicDamage = self.progress[playerID].magicDamage + damage
        self:UpdateQuestForPlayer(playerID, "magicDamage", self.progress[playerID].magicDamage)
    end
    if isPhysical then
        self.progress[playerID].physDamage = (self.progress[playerID].physDamage or 0) + damage
        self:UpdateQuestForPlayer(playerID, "physDamage", self.progress[playerID].physDamage)
    end
end


if not Quests.qStarted then Quests:Init() end