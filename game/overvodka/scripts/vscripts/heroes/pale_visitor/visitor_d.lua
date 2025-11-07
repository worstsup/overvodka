LinkLuaModifier("modifier_visitor_d", "heroes/pale_visitor/visitor_d", LUA_MODIFIER_MOTION_NONE)

visitor_d = class({})

function visitor_d:GetIntrinsicModifierName()
    return "modifier_visitor_d"
end

local function CountTrueSeers(parent, radius)
    local origin    = parent:GetAbsOrigin()

    local enemies = FindUnitsInRadius(
        parent:GetTeamNumber(),
        origin, nil, radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
        FIND_ANY_ORDER, false
    )

    local seers = 0
    for _,e in ipairs(enemies) do
        if e:IsRealHero() and e:IsAlive() then
            if e:CanEntityBeSeenByMyTeam(parent) then
                seers = seers + 1
            end
        end
    end

    local others = FindUnitsInRadius(
        parent:GetTeamNumber(),
        origin, nil, radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_OTHER,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_ANY_ORDER, false
    )
    for _,u in ipairs(others) do
        if u and not u:IsNull() then
            local n = u:GetUnitName() or ""
            if (n=="npc_dota_observer_wards" or n=="npc_dota_sentry_wards") and u:CanEntityBeSeenByMyTeam(parent) then
                seers = seers + 1
            end
        end
    end

    return seers
end


modifier_visitor_d = class({})

function modifier_visitor_d:IsHidden() return self:GetStackCount() <= 0 end
function modifier_visitor_d:IsPurgable() return false end

function modifier_visitor_d:OnCreated()
    self.ability = self:GetAbility()
    self.parent  = self:GetParent()
    self.team    = self.parent:GetTeamNumber()

    if not self.ability then return end

    self.gain_time_per_enemy = self.ability:GetSpecialValueFor("gain_time_per_enemy")
    self.loss_time_base      = self.ability:GetSpecialValueFor("loss_time_base")
    self.loss_speed_extra    = self.ability:GetSpecialValueFor("loss_speed_extra")
    self.heal_amp_pct        = self.ability:GetSpecialValueFor("heal_amp_pct")
    self.radius              = self.ability:GetSpecialValueFor("vision_radius")
    self.max_per_enemy       = self.ability:GetSpecialValueFor("max_stacks_per_enemy")

    -- per_enemy[entindex] = { stacks = current_stacks_from_this_enemy }
    self.per_enemy   = {}
    self._acc_gain   = 0.0
    self._seen       = false
    self._was_seen   = false
    self.start_stacks_on_loss = 0
    self._loss_acc   = 0.0

    if not IsServer() then return end
    self:StartIntervalThink(0.1)
end

function modifier_visitor_d:OnRefresh()
    if not self.ability then return end

    self.gain_time_per_enemy = self.ability:GetSpecialValueFor("gain_time_per_enemy")
    self.loss_time_base      = self.ability:GetSpecialValueFor("loss_time_base")
    self.loss_speed_extra    = self.ability:GetSpecialValueFor("loss_speed_extra")
    self.heal_amp_pct        = self.ability:GetSpecialValueFor("heal_amp_pct")
    self.radius              = self.ability:GetSpecialValueFor("vision_radius")
    self.max_per_enemy       = self.ability:GetSpecialValueFor("max_stacks_per_enemy")
end

function modifier_visitor_d:OnIntervalThink()
    if not IsServer() then return end
    if not self.parent:IsAlive() then return end
    if self.parent:PassivesDisabled() then return end
    
    local dt     = 0.1
    local radius = self.radius

    local seers = CountTrueSeers(self.parent, radius)
    self._seen = (seers > 0)

    local liveEnemies = 0
    local allEnemies = FindUnitsInRadius(
        self.parent:GetTeamNumber(),
        self.parent:GetAbsOrigin(),
        nil, radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_ANY_ORDER, false
    )
    for _,h in ipairs(allEnemies) do
        if h:IsRealHero() and h:IsAlive() then
            liveEnemies = liveEnemies + 1
        end
    end

    if self._seen then
        if not self._was_seen then
            self.start_stacks_on_loss = self:GetStackCount() or 0
            self._loss_acc            = 0
        end

        local base_total = self.start_stacks_on_loss or 0

        if base_total > 0 and self:GetStackCount() > 0 then
            local base_time = math.max(0.05, self.loss_time_base or 3)
            if self.parent:HasModifier("modifier_visitor_q_shard") then
                base_time = base_time * 2
            end
            local accel     = math.max(0, self.loss_speed_extra or 0) * 0.01
            local factor    = 1 + math.max(0, seers - 1) * accel

            local eff_time  = base_time / math.max(0.01, factor)

            local loss_rate = base_total / eff_time

            self._loss_acc = (self._loss_acc or 0) + loss_rate * dt
            local lose_int = math.floor(self._loss_acc)

            if lose_int > 0 then
                self._loss_acc = self._loss_acc - lose_int
                self:RemoveStacks(lose_int)
            end
            if self:GetStackCount() <= 0 then
                self.start_stacks_on_loss = 0
                self._loss_acc            = 0
            end
        else
            self._loss_acc            = 0
            self.start_stacks_on_loss = 0
            self:SetStackCount(0)
        end

        self._acc_gain = 0

    else
        if self._was_seen then
            self._loss_acc            = 0
            self.start_stacks_on_loss = 0
        end

        if liveEnemies <= 0 or self.max_per_enemy <= 0 then
            self._acc_gain = 0
        else
            local gain_t = math.max(0.05, (self.gain_time_per_enemy or 2.0) / liveEnemies)
            self._acc_gain = (self._acc_gain or 0) + dt

            while self._acc_gain >= gain_t do
                self._acc_gain = self._acc_gain - gain_t
                self:AddOneStackFromEnemies(allEnemies)
            end
        end
    end

    self._was_seen = self._seen
    self.parent:CalculateStatBonus(true)
end

function modifier_visitor_d:AddOneStackFromEnemies(enemies)
    if self.max_per_enemy <= 0 then return end
    if not self.per_enemy then self.per_enemy = {} end

    local candidates = {}

    for _,h in ipairs(enemies) do
        if h and not h:IsNull() and h:IsRealHero() and h:IsAlive() then
            local id = h:entindex()
            local data = self.per_enemy[id]
            if not data then
                data = { stacks = 0 }
                self.per_enemy[id] = data
            end

            if data.stacks < self.max_per_enemy then
                table.insert(candidates, { id = id, data = data })
            end
        end
    end

    if #candidates == 0 then
        return
    end

    table.sort(candidates, function(a,b) return a.data.stacks < b.data.stacks end)
    local chosen = candidates[1]
    chosen.data.stacks = chosen.data.stacks + 1

    self:SetStackCount(self:GetStackCount() + 1)
end

function modifier_visitor_d:RemoveStacks(amount)
    if amount <= 0 then return end
    local total = self:GetStackCount()
    if total <= 0 then return end

    if amount > total then amount = total end
    if not self.per_enemy then
        self:SetStackCount(total - amount)
        return
    end

    local entries = {}
    local current_total = 0
    for id,data in pairs(self.per_enemy) do
        local s = data.stacks or 0
        if s > 0 then
            table.insert(entries, { id=id, stacks=s })
            current_total = current_total + s
        end
    end

    if current_total <= 0 then
        self.per_enemy = {}
        self:SetStackCount(0)
        return
    end

    local remaining = amount

    for _,e in ipairs(entries) do
        if remaining <= 0 then break end
        local share = math.floor(amount * (e.stacks / current_total) + 0.5)
        if share > remaining then share = remaining end
        if share > e.stacks then share = e.stacks end

        local data = self.per_enemy[e.id]
        if data then
            data.stacks = math.max(0, (data.stacks or 0) - share)
        end
        remaining = remaining - share
    end

    if remaining > 0 then
        for _,e in ipairs(entries) do
            if remaining <= 0 then break end
            local data = self.per_enemy[e.id]
            if data and data.stacks and data.stacks > 0 then
                local take = math.min(data.stacks, remaining)
                data.stacks = data.stacks - take
                remaining = remaining - take
            end
        end
    end

    local new_total = 0
    for id,data in pairs(self.per_enemy) do
        if data.stacks and data.stacks > 0 then
            new_total = new_total + data.stacks
        else
            self.per_enemy[id] = nil
        end
    end

    self:SetStackCount(new_total)
end

function modifier_visitor_d:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_SOURCE,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
    }
end

function modifier_visitor_d:GetModifierBonusStats_Strength()   return self:GetStackCount() end
function modifier_visitor_d:GetModifierBonusStats_Agility()    return self:GetStackCount() end
function modifier_visitor_d:GetModifierBonusStats_Intellect()  return self:GetStackCount() end

function modifier_visitor_d:GetModifierHealAmplify_PercentageSource()
    if self._seen then return 0 end
    return self.heal_amp_pct or 0
end

function modifier_visitor_d:GetModifierHPRegenAmplify_Percentage()
    if self._seen then return 0 end
    return self.heal_amp_pct or 0
end