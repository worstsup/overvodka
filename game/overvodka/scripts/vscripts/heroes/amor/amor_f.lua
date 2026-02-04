LinkLuaModifier("modifier_amor_f", "heroes/amor/amor_f", LUA_MODIFIER_MOTION_NONE)

amor_f = class({})

function amor_f:GetIntrinsicModifierName()
    return "modifier_amor_f"
end

modifier_amor_f = class({})

function modifier_amor_f:IsHidden() return true end
function modifier_amor_f:IsPurgable() return false end
function modifier_amor_f:RemoveOnDeath() return false end

function modifier_amor_f:OnCreated()
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return end

    self.radius = ability:GetSpecialValueFor("nearby_radius") or 0
    self._charges = self._charges or 0
    self._gold_total = self._gold_total or 0

    if not IsServer() then return end
    self._txData = self._txData or {}
    self:SetHasCustomTransmitterData(true)
    self:_SyncFromInnate(true)
end

function modifier_amor_f:OnRefresh()
    self:OnCreated()
end

function modifier_amor_f:AddCustomTransmitterData()
    self._txData.ch = self._charges or 0
    self._txData.gt = self._gold_total or 0
    return self._txData
end

function modifier_amor_f:HandleCustomTransmitterData(data)
    if not data then return end
    self._charges = tonumber(data.ch) or 0
    self._gold_total = tonumber(data.gt) or 0
end

function modifier_amor_f:_SyncFromInnate(force)
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    local stacks = 0
    local gold_total = 0

    local charges = parent:FindModifierByName("modifier_amor_innate_charges")
    if charges and not charges:IsNull() then
        stacks = charges:GetStackCount() or 0
        gold_total = charges:GetGoldBonusTotal() or 0
    end

    stacks = math.max(0, tonumber(stacks) or 0)
    gold_total = math.max(0, tonumber(gold_total) or 0)

    if (not force) and self._charges == stacks and self._gold_total == gold_total then
        return
    end

    self._charges = stacks
    self._gold_total = gold_total
    self:SendBuffRefreshToClients()
end

function modifier_amor_f:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
    }
end

function modifier_amor_f:GetModifierOverrideAbilitySpecial(params)
    if params.ability ~= self:GetAbility() then return 0 end

    local k = params.ability_special_value
    if k == "bonus_gold_owner_kill" or k == "bonus_gold_nearby_kill" then
        return 1
    end
    return 0
end

function modifier_amor_f:GetModifierOverrideAbilitySpecialValue(params)
    if params.ability ~= self:GetAbility() then return end

    local k = params.ability_special_value
    if k ~= "bonus_gold_owner_kill" and k ~= "bonus_gold_nearby_kill" then return end

    local base = params.ability:GetLevelSpecialValueNoOverride(k, params.ability_special_level)
    return base + (self._gold_total or 0)
end

function modifier_amor_f:IsValidVictimForGold(victim)
    if not victim or victim:IsNull() then return false end
    if victim:IsBuilding() then return false end
    if victim:IsOther() then return false end
    return true
end

function modifier_amor_f:_GiveGold(amount)
    if not IsServer() then return end
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return end

    parent:ModifyGoldFiltered(amount, false, 0)

    local ply = parent:GetPlayerOwner()
    if ply then
        SendOverheadEventMessage(ply, OVERHEAD_ALERT_GOLD, parent, amount, nil)
    end
end

function modifier_amor_f:OnDeath(event)
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() or not parent:IsAlive() then return end
    if not parent:IsRealHero() or parent:IsIllusion() then return end

    local victim = event.unit
    local killer = event.attacker

    if not self:IsValidVictimForGold(victim) then return end
    if not killer or killer:IsNull() then return end

    if killer:GetTeamNumber() == victim:GetTeamNumber() then return end

    local bonus_owner = self:GetAbility():GetSpecialValueFor("bonus_gold_owner_kill") or 0
    local bonus_near = self:GetAbility():GetSpecialValueFor("bonus_gold_nearby_kill") or 0

    if killer == parent then
        self:_GiveGold(bonus_owner)
        parent:EmitSound("amor_f")
        return
    end

    if self.radius > 0 then
        local dv = victim:GetAbsOrigin() - parent:GetAbsOrigin()
        dv.z = 0
        if dv:Length2D() <= self.radius then
            if RandomInt(1, 2) == 1 then 
                parent:EmitSound("amor_f")
            end
            self:_GiveGold(bonus_near)
        end
    end
end
