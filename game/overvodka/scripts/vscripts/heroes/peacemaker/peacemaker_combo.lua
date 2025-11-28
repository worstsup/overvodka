LinkLuaModifier("modifier_peacemaker_combo", "heroes/peacemaker/peacemaker_combo", LUA_MODIFIER_MOTION_NONE)

peacemaker_combo = class({})

function peacemaker_combo:GetIntrinsicModifierName()
    return "modifier_peacemaker_combo"
end

modifier_peacemaker_combo = class({})

function modifier_peacemaker_combo:IsHidden()        return self:GetStackCount() == 0 end
function modifier_peacemaker_combo:IsPurgable()      return false end
function modifier_peacemaker_combo:RemoveOnDeath()   return false end

function modifier_peacemaker_combo:OnCreated()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    if not IsServer() then return end

    self.stack_timers = {}
    self:SetStackCount(0)

    self:StartIntervalThink(0.1)
end

function modifier_peacemaker_combo:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }
end

local function _IsValidCastForStacks(parent, ability)
    if not ability then return false end
    if ability:IsItem() then return false end
    if ability:IsToggle() then return false end
    return true
end

function modifier_peacemaker_combo:OnAbilityExecuted(event)
    if not IsServer() then return end
    if event.unit ~= self.parent then return end
    if self.parent:PassivesDisabled() then return end
    if not self:GetAbility():IsCooldownReady() then return end
    local ability = event.ability
    if not _IsValidCastForStacks(self.parent, ability) then return end

    local stack_duration = self.ability:GetSpecialValueFor("each_stack_duration")

    table.insert(self.stack_timers, GameRules:GetGameTime() + stack_duration)
    self:SetStackCount(#self.stack_timers)
end

function modifier_peacemaker_combo:OnIntervalThink()
    if not IsServer() then return end
    if not self.ability then return end
    if not self.parent then return end
    if #self.stack_timers == 0 then return end

    local now = GameRules:GetGameTime()
    local changed = false

    local alive = {}
    for _,expire in ipairs(self.stack_timers) do
        if expire > now then
            table.insert(alive, expire)
        else
            changed = true
        end
    end
    if changed then
        self.stack_timers = alive
        self:SetStackCount(#self.stack_timers)
    end
end

function modifier_peacemaker_combo:GetModifierSpellAmplify_Percentage()
    if self.parent:PassivesDisabled() then return 0 end
    return self.ability:GetSpecialValueFor("bonus_magic_damage") * self:GetStackCount()
end