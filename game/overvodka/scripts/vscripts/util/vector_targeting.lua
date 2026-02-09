if not VectorTarget then 
	VectorTarget = class({})
end

local ORDER_DEBUG = false
local function dprint(...) if ORDER_DEBUG then print("[ORDER]", ...) end end

local MOVEMENT_FIX = {
    modifier_peterka_e_cast = true,
    modifier_peterka_e_charge = true,
	modifier_invincible_w = true,
	modifier_macan_r = true,
	modifier_macan_r_charge = true,
	modifier_shkolnik_r = true,
	modifier_prince_r = true,
	modifier_generic_vector_target = true,
    modifier_epstein_innate_phase = true,
}

LEON_INTERNAL_DISARM_MODS = LEON_INTERNAL_DISARM_MODS or {
    ["modifier_leon_q_controller"] = true,
}

local function Leon_IsExternallyDisarmed(unit)
    if not unit or unit:IsNull() then return false end
    if not unit:IsDisarmed() then return false end

    for _, mod in pairs(unit:FindAllModifiers()) do
        local tables = {}
        mod:CheckStateToTable(tables)
        for state_name, mod_table in pairs(tables) do
            if tostring(state_name) == tostring(MODIFIER_STATE_DISARMED) and LEON_INTERNAL_DISARM_MODS[mod:GetName()] == nil then
                return true
            end
        end
    end
    return false
end

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

VectorTarget._leonOrderGuard = VectorTarget._leonOrderGuard or {}

local function _CountSelectedUnits(unitsTable)
    local c = 0
    if not unitsTable then return 0 end
    for _, _ in pairs(unitsTable) do c = c + 1 end
    return c
end

function VectorTarget:TryLeonAttackOverride(event, unit, target)
    if not IsServer() then return false end
    if not unit or unit:IsNull() then return false end
    if not target or target:IsNull() then return false end
    if event.order_type ~= DOTA_UNIT_ORDER_ATTACK_TARGET then return false end
    
    if _CountSelectedUnits(event.units) ~= 1 then return false end

    local ab = unit:FindAbilityByName("leon_q")
    if not ab or ab:IsNull() then return false end
    if ab:GetLevel() <= 0 then return false end
    if ab:IsHidden() or (not ab:IsActivated()) then return false end

    local idx = unit:entindex()
    if self._leonOrderGuard[idx] then
        return true
    end

    self._leonOrderGuard[idx] = true

    Timers:CreateTimer(0, function()
        if not unit or unit:IsNull() then self._leonOrderGuard[idx] = nil return end
        local ab2 = unit:FindAbilityByName("leon_q")
        if not ab2 or ab2:IsNull() then self._leonOrderGuard[idx] = nil return end
        if not target or target:IsNull() then self._leonOrderGuard[idx] = nil return end
        if Leon_IsExternallyDisarmed(unit) or unit:IsStunned() or unit:IsHexed() then
            ExecuteOrderFromTable({
                UnitIndex = unit:entindex(),
                OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET,
                TargetIndex = target:entindex(),
                Queue = false,
            })
            self._leonOrderGuard[idx] = nil
            return
        end

        if unit:IsSilenced() then
            ExecuteOrderFromTable({
                UnitIndex = unit:entindex(),
                OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET,
                TargetIndex = target:entindex(),
                Queue = false,
            })
            self._leonOrderGuard[idx] = nil
            return
        end

        local has_charges = true
        if ab2.GetCurrentAbilityCharges then
            has_charges = (ab2:GetCurrentAbilityCharges() > 0)
        end

        local can_cast = has_charges and ab2:IsCooldownReady()

        if can_cast then
            local pos = target:GetAbsOrigin()
            pos.z = 0
            if not unit:IsIllusion() then
                ExecuteOrderFromTable({
                    UnitIndex    = unit:entindex(),
                    OrderType    = DOTA_UNIT_ORDER_CAST_POSITION,
                    AbilityIndex = ab2:entindex(),
                    Position     = pos,
                    Queue        = false,
                })
            else
                unit:Stop()
                ab2:FireAttack(pos)
                ab2:SetCurrentAbilityCharges(math.max(0, ab2:GetCurrentAbilityCharges() - 1))
            end
            if target:GetClassname() ~= "dota_item_drop" and target:GetClassname() ~= "dota_item_rune"  then
                if target:IsOther() then
                    local dist = (unit:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
                    if dist <= unit:Script_GetAttackRange() then
                        local idx = unit:entindex()
                        local lastAttackTime = self._leonLastAttackTime or {}
                        local currentTime = GameRules:GetGameTime()
                        
                        if not lastAttackTime[idx] or currentTime - lastAttackTime[idx] >= 0.5 then
                            Timers:CreateTimer(0.05 + dist / 1400, function()
                                if not unit or unit:IsNull() then return end
                                if not target or target:IsNull() then return end
                                unit:PerformAttack(target, true, true, true, false, false, false, true)
                                lastAttackTime[idx] = currentTime
                                self._leonLastAttackTime = lastAttackTime
                            end)
                        end
                    end
                end
            else
                local dist = (unit:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
                if dist <= unit:Script_GetAttackRange() then
                    Timers:CreateTimer(0.05 + dist / 1400, function()
                        if not unit or unit:IsNull() then return end
                        if not target or target:IsNull() then return end
                        target:RemoveSelf()
                    end)
                end
            end
        else
            ExecuteOrderFromTable({
                UnitIndex = unit:entindex(),
                OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET,
                TargetIndex = target:entindex(),
                Queue = false,
            })
        end

        self._leonOrderGuard[idx] = nil
    end)

    return true
end

function VectorTarget:TryLeonAttackMoveOverride(event, unit, pos)
    if not IsServer() then return false end
    if not unit or unit:IsNull() then return false end
    if not pos then return false end
    if event.order_type ~= DOTA_UNIT_ORDER_ATTACK_MOVE then return false end

    if _CountSelectedUnits(event.units) ~= 1 then return false end

    local ab = unit:FindAbilityByName("leon_q")
    if not ab or ab:IsNull() then return false end
    if ab:GetLevel() <= 0 then return false end
    if ab:IsHidden() or (not ab:IsActivated()) then return false end

    local idx = unit:entindex()
    if self._leonOrderGuard[idx] then
        return true
    end
    self._leonOrderGuard[idx] = true

    local cast_pos = Vector(pos.x, pos.y, 0)

    Timers:CreateTimer(0, function()
        if not unit or unit:IsNull() then self._leonOrderGuard[idx] = nil return end
        local ab2 = unit:FindAbilityByName("leon_q")
        if not ab2 or ab2:IsNull() then self._leonOrderGuard[idx] = nil return end

        if Leon_IsExternallyDisarmed(unit) or unit:IsStunned() or unit:IsHexed() or unit:IsSilenced() then
            ExecuteOrderFromTable({
                UnitIndex = unit:entindex(),
                OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                Position  = cast_pos,
                Queue     = false,
            })
            self._leonOrderGuard[idx] = nil
            return
        end

        local has_charges = true
        if ab2.GetCurrentAbilityCharges then
            has_charges = (ab2:GetCurrentAbilityCharges() > 0)
        end

        local can_cast = has_charges and ab2:IsCooldownReady()

        if can_cast then
            if not unit:IsIllusion() then
                ExecuteOrderFromTable({
                    UnitIndex    = unit:entindex(),
                    OrderType    = DOTA_UNIT_ORDER_CAST_POSITION,
                    AbilityIndex = ab2:entindex(),
                    Position     = cast_pos,
                    Queue        = false,
                })
            else
                unit:Stop()
                ab2:FireAttack(cast_pos)
                ab2:SetCurrentAbilityCharges(math.max(0, ab2:GetCurrentAbilityCharges() - 1))
            end
        else
            ExecuteOrderFromTable({
                UnitIndex = unit:entindex(),
                OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                Position  = cast_pos,
                Queue     = false,
            })
        end

        self._leonOrderGuard[idx] = nil
    end)

    return true
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

	if unit:HasModifier("modifier_peterka_e_cast") or unit:HasModifier("modifier_macan_r_charge") then
        local LOCKED_ORDERS = {
            [DOTA_UNIT_ORDER_DROP_ITEM] = true,
            [DOTA_UNIT_ORDER_PICKUP_ITEM] = true,
            [DOTA_UNIT_ORDER_CAST_POSITION] = true,
        }
        if LOCKED_ORDERS[order] then
            return false
        end
    end

    local target = nil
    if event.entindex_target and event.entindex_target ~= 0 then
        local h = EntIndexToHScript(event.entindex_target)
        if h and not h:IsNull() then target = h end
    end

    local new_pos = nil
    if event.position_x ~= nil then
        new_pos = Vector(event.position_x, event.position_y or 0, event.position_z or 0)
    end

    if target and self:TryLeonAttackOverride(event, unit, target) then
        return false
    end

    if new_pos and self:TryLeonAttackMoveOverride(event, unit, new_pos) then
        return false
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
