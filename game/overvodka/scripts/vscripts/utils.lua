LinkLuaModifier("modifier_subscriber_effect", "modifiers/modifier_subscriber_effect", LUA_MODIFIER_MOTION_NONE)

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

    if not Unit:IsRealHero() or Unit:IsIllusion() or Unit:IsStrongIllusion() or Unit:IsTempestDouble() or Unit:IsClone() or Unit:GetClassname() == "npc_dota_lone_druid_bear" then return false end

    return true
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