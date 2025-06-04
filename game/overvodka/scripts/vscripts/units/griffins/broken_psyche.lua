LinkLuaModifier("modifier_broken_psyche", "units/griffins/broken_psyche.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_broken_psyche_buff", "units/griffins/broken_psyche.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_broken_psyche_counter", "units/griffins/broken_psyche.lua", LUA_MODIFIER_MOTION_NONE)

broken_psyche = class({})

function broken_psyche:GetIntrinsicModifierName()
    return "modifier_broken_psyche"
end

modifier_broken_psyche = class({})

function modifier_broken_psyche:IsHidden() return true end
function modifier_broken_psyche:IsPurgable() return false end

function modifier_broken_psyche:OnCreated()
    if not IsServer() then return end
    self.required_hits = self:GetAbility():GetSpecialValueFor("required_hits")
    self.activated = false
end

function modifier_broken_psyche:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACKED }
end

function modifier_broken_psyche:OnAttacked(keys)
    if not IsServer() then return end
    local parent = self:GetParent()

    if self.activated then return end

    if keys.target == parent and not keys.attacker:IsOther() then
        local modifier = parent:FindModifierByName("modifier_broken_psyche_counter")

        if not modifier then
            modifier = parent:AddNewModifier(parent, self:GetAbility(), "modifier_broken_psyche_counter", {
                count = self.required_hits
            })
        else
            modifier:DecrementStackCount()
        end

        if modifier:GetStackCount() <= 0 then
            parent:AddNewModifier(parent, self:GetAbility(), "modifier_broken_psyche_buff", {
                duration = self:GetAbility():GetSpecialValueFor("buff_duration")
            })
            modifier:Destroy()
            self.activated = true
        end
    end
end


modifier_broken_psyche_counter = class({})

function modifier_broken_psyche_counter:IsHidden() return false end
function modifier_broken_psyche_counter:IsPurgable() return false end
function modifier_broken_psyche_counter:RemoveOnDeath() return true end

function modifier_broken_psyche_counter:OnCreated(params)
    if not IsServer() then return end
    local count = params.count or self:GetAbility():GetSpecialValueFor("required_hits")
    self:SetStackCount(count)
end

modifier_broken_psyche_buff = class({})

function modifier_broken_psyche_buff:IsBuff() return true end
function modifier_broken_psyche_buff:IsPurgable() return false end

function modifier_broken_psyche_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
end

function modifier_broken_psyche_buff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed_bonus_pct")
end

function modifier_broken_psyche_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("attack_speed_bonus")
end
