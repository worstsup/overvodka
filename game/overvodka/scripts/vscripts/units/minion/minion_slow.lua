LinkLuaModifier("modifier_minion_slow_passive", "units/minion/minion_slow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_minion_slow_debuff", "units/minion/minion_slow", LUA_MODIFIER_MOTION_NONE)

minion_slow = class({})

function minion_slow:Precache(context)
    PrecacheResource("particle", "particles/generic_gameplay/generic_slowed_cold.vpcf", context)
    PrecacheResource("soundfile", "particles/units/heroes/hero_monkey_king/monkey_king_taunt_bananas.vpcf", context)
end

function minion_slow:GetIntrinsicModifierName()
    return "modifier_minion_slow_passive"
end

modifier_minion_slow_passive = class({})

function modifier_minion_slow_passive:IsHidden() return true end
function modifier_minion_slow_passive:IsPurgable() return false end
function modifier_minion_slow_passive:RemoveOnDeath() return false end

function modifier_minion_slow_passive:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_minion_slow_passive:OnAttackLanded(params)
    if not IsServer() then return end
    if self:GetParent():PassivesDisabled() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsBuilding() then return end

    local target = params.target
    local ability = self:GetAbility()
    local slow_value = ability:GetSpecialValueFor("slow")
    local duration = ability:GetSpecialValueFor("duration")
    local max_stacks = ability:GetSpecialValueFor("max_stacks")
    local modifierName = "modifier_minion_slow_debuff"
    local debuff = target:FindModifierByNameAndCaster(modifierName, self:GetParent())
    if debuff then
        if debuff:GetStackCount() < max_stacks then
            debuff:IncrementStackCount()
        end
        debuff:SetDuration(duration, true)
    else
        target:AddNewModifier(self:GetParent(), ability, modifierName, {duration = duration})
        debuff = target:FindModifierByNameAndCaster(modifierName, self:GetParent())
        if debuff then
            debuff:SetStackCount(1)
        end
    end
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_taunt_bananas.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
end

modifier_minion_slow_debuff = class({})

function modifier_minion_slow_debuff:IsHidden() return false end
function modifier_minion_slow_debuff:IsDebuff() return true end
function modifier_minion_slow_debuff:IsPurgable() return true end
function modifier_minion_slow_debuff:RemoveOnDeath() return true end

function modifier_minion_slow_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end

function modifier_minion_slow_debuff:GetModifierMoveSpeedBonus_Percentage()
    local ability = self:GetAbility()
    if not ability then return 0 end
    local slow_value = ability:GetSpecialValueFor("slow")
    return self:GetStackCount() * (-slow_value)
end

function modifier_minion_slow_debuff:GetEffectName()
    return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end

function modifier_minion_slow_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_minion_slow_debuff:GetTexture()
    return "minion_slow"
end
