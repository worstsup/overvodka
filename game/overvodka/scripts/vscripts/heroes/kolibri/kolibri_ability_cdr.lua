LinkLuaModifier("modifier_kolibri_ability_cdr", "heroes/kolibri/kolibri_ability_cdr", LUA_MODIFIER_MOTION_NONE)

kolibri_ability_cdr = class({})

function kolibri_ability_cdr:GetIntrinsicModifierName()
    return "modifier_kolibri_ability_cdr"
end

modifier_kolibri_ability_cdr = class({})

function modifier_kolibri_ability_cdr:IsHidden()      return self:GetStackCount() == 0 end
function modifier_kolibri_ability_cdr:IsPurgable()    return false end
function modifier_kolibri_ability_cdr:RemoveOnDeath() return false end

function modifier_kolibri_ability_cdr:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
    }
end

function modifier_kolibri_ability_cdr:OnCreated()
    self.parent  = self:GetParent()
    self.ability = self:GetAbility()

    if not IsServer() then return end

    self.stack_timers = {}
    self:SetStackCount(0)

    self:StartIntervalThink(-1)
end

function modifier_kolibri_ability_cdr:OnRefresh()
    self.parent  = self:GetParent()
    self.ability = self:GetAbility()
end

function modifier_kolibri_ability_cdr:GetModifierPercentageCooldown()
    if self.parent and self.parent:PassivesDisabled() then return 0 end
    if not self.ability or self.ability:IsNull() then return 0 end

    local cdr = self.ability:GetSpecialValueFor("cdr") or 0
    return cdr * (self:GetStackCount() or 0)
end

function modifier_kolibri_ability_cdr:OnIntervalThink()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end
    if not self.ability or self.ability:IsNull() then return end

    local timers = self.stack_timers
    if not timers or #timers == 0 then
        if self:GetStackCount() ~= 0 then self:SetStackCount(0) end
        self:StartIntervalThink(-1)
        return
    end

    local now = GameRules:GetGameTime()

    local i = #timers
    local changed = false
    while i >= 1 do
        if timers[i] <= now then
            timers[i] = timers[#timers]
            timers[#timers] = nil
            changed = true
        end
        i = i - 1
    end

    if changed then
        self:SetStackCount(#timers)
        if #timers == 0 then
            self:StartIntervalThink(-1)
        end
    end
end

local function _FindOldestIndex(timers)
    local oldest_i = 1
    local oldest_t = timers[1] or 0
    for i = 2, #timers do
        local t = timers[i] or 0
        if t < oldest_t then
            oldest_t = t
            oldest_i = i
        end
    end
    return oldest_i
end

function modifier_kolibri_ability_cdr:OnAttackLanded(params)
    if not IsServer() then return end

    local parent = self.parent
    if not parent or parent:IsNull() then return end
    if parent:IsIllusion() then return end
    if parent:PassivesDisabled() then return end

    if not params or params.attacker ~= parent then return end

    local target = params.target
    if not target or target:IsNull() then return end
    if not target:IsAlive() then return end
    if not target:IsRealHero() then return end
    if target:GetTeamNumber() == parent:GetTeamNumber() then return end

    local ability = self.ability
    if not ability or ability:IsNull() then return end

    local cdr = ability:GetSpecialValueFor("cdr") or 0
    if cdr <= 0 then return end

    local stack_duration = ability:GetSpecialValueFor("duration") or 0
    local max_stacks     = ability:GetSpecialValueFor("max_stacks") or 0
    if stack_duration <= 0 or max_stacks <= 0 then return end

    local now = GameRules:GetGameTime()
    local expire = now + stack_duration

    local timers = self.stack_timers
    if not timers then
        timers = {}
        self.stack_timers = timers
    end

    local i = #timers
    while i >= 1 do
        if timers[i] <= now then
            timers[i] = timers[#timers]
            timers[#timers] = nil
        end
        i = i - 1
    end

    if #timers < max_stacks then
        timers[#timers + 1] = expire
    else
        local oldest_i = _FindOldestIndex(timers)
        timers[oldest_i] = expire
    end

    self:SetStackCount(#timers)

    self:StartIntervalThink(0.1)
end
