LinkLuaModifier("modifier_silvername_innate_facet_1", "heroes/silvername/silvername_innate_facet_1", LUA_MODIFIER_MOTION_NONE)

silvername_innate_facet_1 = class({})

function silvername_innate_facet_1:GetIntrinsicModifierName()
    return "modifier_silvername_innate_facet_1"
end

modifier_silvername_innate_facet_1 = class({})

function modifier_silvername_innate_facet_1:IsHidden()      return self:GetStackCount() == 0 end
function modifier_silvername_innate_facet_1:IsPurgable()    return false end
function modifier_silvername_innate_facet_1:IsDebuff()      return false end
function modifier_silvername_innate_facet_1:IsBuff()        return true end
function modifier_silvername_innate_facet_1:RemoveOnDeath() return false end

function modifier_silvername_innate_facet_1:OnCreated()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    self.max_networth = 0

    if self.ability and not self.ability:IsNull() then
        self.networth_step      = self.ability:GetSpecialValueFor("networth_step")     or 2500
        self.bonus_as_per_stack = self.ability:GetSpecialValueFor("bonus_as")          or 5
        self.bonus_hp_per_stack = self.ability:GetSpecialValueFor("bonus_hp")          or 50
        self.bonus_ms_per_stack = self.ability:GetSpecialValueFor("bonus_ms")          or 3
    end

    if not IsServer() then return end

    self:StartIntervalThink(1.0)
end

function modifier_silvername_innate_facet_1:OnIntervalThink()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then
        self:Destroy()
        return
    end

    local playerID = self.parent:GetPlayerOwnerID()
    if playerID == nil or playerID < 0 then
        return
    end

    local networth = PlayerResource:GetNetWorth(playerID) or 0

    if networth > self.max_networth then
        self.max_networth = networth

        if self.networth_step > 0 then
            local newStacks = math.floor(self.max_networth / self.networth_step)
            local oldStacks = self:GetStackCount()

            if newStacks > oldStacks then
                self:SetStackCount(newStacks)
                self.parent:CalculateStatBonus(true)
            end
        end
    end
end

function modifier_silvername_innate_facet_1:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    }
end

function modifier_silvername_innate_facet_1:GetModifierAttackSpeedBonus_Constant()
    return self:GetStackCount() * self.bonus_as_per_stack
end

function modifier_silvername_innate_facet_1:GetModifierHealthBonus()
    return self:GetStackCount() * self.bonus_hp_per_stack
end

function modifier_silvername_innate_facet_1:GetModifierMoveSpeedBonus_Constant()
    return self:GetStackCount() * self.bonus_ms_per_stack
end
