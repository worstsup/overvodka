require('chat_wheel/chat_wheel_settings')

if ChatWheel == nil then
	ChatWheel = class({})
end

function ChatWheel:Init()
    cprint('[ChatWheel] Module is active!')
    self.bStarted = true

    self.Players = {}

    CustomGameEventManager:RegisterListener("chat_wheel_item_selected", function(source, event) self:OnPlayerSelectedItem(event) end)
    CustomGameEventManager:RegisterListener("chat_wheel_line_selected", function(source, event) self:OnPlayerSelectedLine(event) end)

    CustomNetTables:SetTableValue("globals", "chat_wheel_items_list", CHAT_WHEEL_LIST)
end

function ChatWheel:LoadPlayer(PlayerID, ChatWheelTable)
    if self.Players[PlayerID] == nil then
        self.Players[PlayerID] = {}
    end

    local NormalTable = {}
    for LineID, ItemID in pairs(ChatWheelTable) do
        local LID = tonumber(LineID)
        local IID = tonumber(ItemID)
        if LID ~= nil and IID ~= nil then
            NormalTable[LID] = IID
        end
    end

    self.Players[PlayerID].ChatWheel = NormalTable
    self.Players[PlayerID].Cooldown = {}

    self:UpdateNetTable(PlayerID)
end

function ChatWheel:OnPlayerSelectedItem(event)
    local PlayerID = event.PlayerID

    if self.Players[PlayerID] == nil then return end

    if not Server:IsPlayerSubscribed(PlayerID) then 
        SendErrorToPlayer(PlayerID, "#PLAYER_HUD_Error_ChatWheel_NotSubscribed")
        return
    end

    local ItemID = tonumber(event.item_id)
    local LineID = tonumber(event.line_id)

    if ItemID == nil or LineID == nil then return end

    self.Players[PlayerID].ChatWheel[LineID] = ItemID

    self:UpdateNetTable(PlayerID)

    Server:RecordChatWheelChanges(PlayerID, LineID, ItemID)
end

function ChatWheel:OnPlayerSelectedLine(event)
    local PlayerID = event.PlayerID

    if self.Players[PlayerID] == nil then return end

    if not Server:IsPlayerSubscribed(PlayerID) then 
        SendErrorToPlayer(PlayerID, "#PLAYER_HUD_Error_ChatWheel_NotSubscribed")
        return
    end

    local LineID = tonumber(event.line_id)

    if LineID == nil then return end

    if self.Players[PlayerID].ChatWheel[LineID] == nil or self.Players[PlayerID].ChatWheel[LineID] == 0 then
        return
    end

    local ItemID = self.Players[PlayerID].ChatWheel[LineID]

    if CHAT_WHEEL_LIST[ItemID] == nil then return end

    local ItemInfo = CHAT_WHEEL_LIST[ItemID]

    local ChatWheelCooldown = self:GetCooldownInfo(PlayerID)
    if ChatWheelCooldown then
        if ChatWheelCooldown.free_charges > 0 then
            self:StartChargeCooldown(PlayerID)
            if ItemInfo.ForAll == true then
                CustomGameEventManager:Send_ServerToAllClients("chat_wheel_say_line", {caller_player = PlayerID, item_id = ItemID})
            else
                local Team = PlayerResource:GetTeam(PlayerID)
                CustomGameEventManager:Send_ServerToTeam(Team, "chat_wheel_say_line", {caller_player = PlayerID,item_id = ItemID})
            end
        else
            SendErrorToPlayer(PlayerID, "#PLAYER_HUD_Error_Tip_Cooldown")
        end
    end
end

function ChatWheel:StartChargeCooldown(PlayerID)
    if self.Players[PlayerID] == nil then return end

    table.insert(self.Players[PlayerID].Cooldown, GameRules:GetGameTime()+CHAT_WHEEL_COOLDOWN)
end

function ChatWheel:GetCooldownInfo(PlayerID)
    if self.Players[PlayerID] == nil then return nil end
    
    local CloseCooldown = 0

    if #self.Players[PlayerID].Cooldown > 0 then
        for i = #self.Players[PlayerID].Cooldown, 1, -1 do
            if GameRules:GetGameTime() >=  self.Players[PlayerID].Cooldown[i] then
                table.remove(self.Players[PlayerID].Cooldown, i)
            end
        end
        table.sort(self.Players[PlayerID].Cooldown)

        CloseCooldown = self.Players[PlayerID].Cooldown[1]
    end

    local FreeCharges = CHAT_WHEEL_MAX_BEFORE_COOLDOWN - #self.Players[PlayerID].Cooldown
    
    local Info = {
        free_charges = FreeCharges,
        close_cooldown = CloseCooldown,
    }

    return Info
end

function ChatWheel:UpdateNetTable(PlayerID)
    if self.Players[PlayerID] == nil then return end

    CustomNetTables:SetTableValue("players", "player_".. PlayerID .."_chat_wheel", self.Players[PlayerID].ChatWheel)
end

if not ChatWheel.bStarted then ChatWheel:Init() end