if not VectorTarget then 
	VectorTarget = class({})
end

local ORDER_DEBUG = false
local function dprint(...) if ORDER_DEBUG then print("[ORDER]", ...) end end

local MOVEMENT_FIX = {
    modifier_peterka_e_cast   = true,
    modifier_peterka_e_charge = true,
	modifier_invincible_w = true,
	modifier_macan_r = true,
	modifier_macan_r_charge = true,
	modifier_shkolnik_r = true,
	modifier_prince_r = true,
}

function VectorTarget:RouteOrderToModifiers(unit, order, target, new_pos)
    if not unit or unit:IsNull() then return end
    local mods = unit.FindAllModifiers and unit:FindAllModifiers() or {}
    dprint("route->", unit:GetUnitName(), "order=", order, "pos=", new_pos)

    for _, mod in ipairs(mods) do
        local name = mod:GetName()
        if MOVEMENT_FIX[name] and mod.OnOrder then
            local ok, err = pcall(function()
                mod:OnOrder({
                    unit       = unit,
                    order_type = order,
                    target     = target,
                    new_pos    = new_pos,
                })
            end)
            if not ok then
                print("[ORDER][ERROR] OnOrder failed in "..tostring(name)..": "..tostring(err))
            end
        end
    end
end

ListenToGameEvent("game_rules_state_change", function()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		VectorTarget:Init()
	end
end, nil)

function VectorTarget:Init()
	print("[VT] Initializing VectorTarget...")
	local mode = GameRules:GetGameModeEntity()
	mode:SetExecuteOrderFilter(Dynamic_Wrap(VectorTarget, 'OrderFilter'), VectorTarget)
	ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(VectorTarget, 'OnAbilityLearned'), self)
	ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(VectorTarget, 'OnItemBought'), self)
	ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(VectorTarget, 'OnItemPickup'), self)

	CustomGameEventManager:RegisterListener("check_ability", Dynamic_Wrap(VectorTarget, "OnAbilityCheck"))
end

function VectorTarget:OrderFilter(event)
    if not event.units or not event.units["0"] then return true end

    local unit = EntIndexToHScript(event.units["0"])
    local ability = (event.entindex_ability and event.entindex_ability ~= 0) and EntIndexToHScript(event.entindex_ability) or nil

    if ability and ability.GetBehaviorInt then
        local behavior = ability:GetBehaviorInt()

        if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING) ~= 0 then
            if event.order_type == DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION then
                ability.vectorTargetPosition2 = Vector(event.position_x, event.position_y, 0)
            end

            if event.order_type == DOTA_UNIT_ORDER_CAST_POSITION then
                ability.vectorTargetPosition = Vector(event.position_x, event.position_y, 0)
                local position  = ability.vectorTargetPosition
                local position2 = ability.vectorTargetPosition2
                local direction = (position2 - position):Normalized()

                if position == position2 then
                    direction = (position - unit:GetAbsOrigin()):Normalized()
                end
                direction = Vector(direction.x, direction.y, 0)
                ability.vectorTargetDirection = direction

                local function OverrideSpellStart(self, pos, dir)
                    self:OnVectorCastStart(pos, dir)
                end
                ability.OnSpellStart = function(self) return OverrideSpellStart(self, position, direction) end
            end
        end
    end

    local order = event.order_type

    local target = nil
    if event.entindex_target and event.entindex_target ~= 0 then
        local h = EntIndexToHScript(event.entindex_target)
        if h and not h:IsNull() then target = h end
    end

    local new_pos = nil
    if event.position_x ~= nil then
        new_pos = Vector(event.position_x, event.position_y or 0, event.position_z or 0)
    end

    if event.units then
        for _, entindex in pairs(event.units) do
            local u = EntIndexToHScript(entindex or -1)
            if u and not u:IsNull() then
                self:RouteOrderToModifiers(u, order, target, new_pos)
            end
        end
    end

    return true
end


function VectorTarget:UpdateNettable(ability)
	local vectorData = {
		startWidth = ability:GetVectorTargetStartRadius(),
		endWidth = ability:GetVectorTargetEndRadius(),
		castLength = ability:GetVectorTargetRange(),
		dual = ability:IsDualVectorDirection(),
		ignoreArrow = ability:IgnoreVectorArrowWidth(),
	}
	CustomNetTables:SetTableValue("vector_targeting", tostring(ability:entindex()), vectorData)
end

function VectorTarget:OnAbilityLearned(event)
	local playerID = event.PlayerID
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)
	local ability = hero:FindAbilityByName(event.abilityname)

	if not ability or not ability.GetBehaviorInt then return true end
	local behavior = ability:GetBehaviorInt()

	-- check if the ability exists and if it is Vector targeting
	if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING) ~= 0 then
		VectorTarget:UpdateNettable(ability)
	end
end

function VectorTarget:OnItemPickup(event)
	local index = event.item_entindex
	if not index then
		index = event.ItemEntityIndex
	end
	local ability = EntIndexToHScript(index)

	if not ability or not ability.GetBehaviorInt then return true end
	local behavior = ability:GetBehaviorInt()

	-- check if the item exists and if it is Vector targeting
	if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING) ~= 0 then
		VectorTarget:UpdateNettable(ability)
	end
end

function VectorTarget:OnItemBought(event)
	local playerID = event.PlayerID
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)

	for i=0, 15 do
		local item = hero:GetItemInSlot(i)
		if item and item.GetBehaviorInt then
			local behavior = item:GetBehaviorInt()
			if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING) ~= 0 then
				VectorTarget:UpdateNettable(item)
			end
		end
	end
end

function VectorTarget:OnAbilityCheck(event)
	local ability = EntIndexToHScript(event.abilityIndex)
	VectorTarget:UpdateNettable(ability)
end

function CDOTABaseAbility:GetVectorTargetRange()
	return 800
end 

function CDOTABaseAbility:GetVectorTargetStartRadius()
	return 125
end 

function CDOTABaseAbility:GetVectorTargetEndRadius()
	return self:GetVectorTargetStartRadius()
end 

function CDOTABaseAbility:GetVectorPosition()
	return self.vectorTargetPosition
end 

function CDOTABaseAbility:GetVector2Position() -- world click
	return self.vectorTargetPosition2
end 

function CDOTABaseAbility:GetVectorDirection()
	return self.vectorTargetDirection
end 

function CDOTABaseAbility:OnVectorCastStart(vStartLocation, vDirection)
	print("Vector Cast")
end

function CDOTABaseAbility:UpdateVectorValues()
	VectorTarget:UpdateNettable(self)
end

function CDOTABaseAbility:IsDualVectorDirection()
	return false
end

function CDOTABaseAbility:IgnoreVectorArrowWidth()
	return false
end
