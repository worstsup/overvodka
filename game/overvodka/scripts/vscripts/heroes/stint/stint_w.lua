LinkLuaModifier("modifier_stint_w_debt", "heroes/stint/stint_w", LUA_MODIFIER_MOTION_NONE)

stint_w = class({})

function stint_w:Precache(context)
    -- pre-cache particles
    PrecacheResource("particle", "particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_lich/lich_frost_nova.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_invoker/invoker_emp.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_invoker/invoker_chaos_meteor_explosion.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_bane/bane_nightmare.vpcf", context)
end

-- Use GetGoldCost to define the wager amount per level
function stint_w:GetGoldCost(level)
    return self:GetSpecialValueFor("investment")
end

-- Custom cast error: check both caster and target have enough gold
function stint_w:GetCustomCastErrorTarget(target)
    local cost = self:GetGoldCost(self:GetLevel())
    if self:GetCaster():GetGold() < cost then
        return "dota_hud_error_not_enough_gold"
    end
    if target:GetGold() < cost then
        return "dota_hud_error_not_enough_gold"
    end
    return nil
end

function stint_w:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    -- retrieve values
    local cost      = self:GetGoldCost(self:GetLevel())
    local ch_bad    = self:GetSpecialValueFor("chance_bad")
    local ch_15     = self:GetSpecialValueFor("chance_1_5")
    local ch_2      = self:GetSpecialValueFor("chance_2")
    local ch_25     = self:GetSpecialValueFor("chance_2_5")
    local max_debt  = self:GetSpecialValueFor("max_debt")
    local shard_max = self:GetSpecialValueFor("shard_max_debt")

    -- roll multiplier for each participant
    local function rollMult()
        local r = RandomInt(1,100)
        if r <= ch_bad then return 0 end
        r = r - ch_bad
        if r <= ch_15 then return 1.5 end
        r = r - ch_15
        if r <= ch_2 then return 2 end
        return 2.5
    end
    local mC = rollMult()
    local mT = rollMult()

    -- both succeed: refund caster's wager
    if mC > 1 and mT > 1 then
        PlayerResource:ModifyGold(caster:GetPlayerOwnerID(), cost, false, 0)
        -- particles
        local p1 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:DestroyParticle(p1, false)
        ParticleManager:ReleaseParticleIndex(p1)
        local p2 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:DestroyParticle(p2, false)
        ParticleManager:ReleaseParticleIndex(p2)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, caster, cost, nil)
        return
    end

    -- determine winner/loser
    local winner, loser, mW
    if mC > 1 and mT <= 1 then
        winner, loser, mW = caster, target, mC
    elseif mT > 1 and mC <= 1 then
        winner, loser, mW = target, caster, mT
    else
        -- neither succeeded: failure particles/message
        local p3 = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_frost_nova.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:DestroyParticle(p3, false)
        ParticleManager:ReleaseParticleIndex(p3)
        local p4 = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_frost_nova.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:DestroyParticle(p4, false)
        ParticleManager:ReleaseParticleIndex(p4)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, caster, 0, nil)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, target, 0, nil)
        return
    end

    -- compute amounts
    local gain = cost * mW
    local loss = cost + gain

    -- player IDs
    local loserID = loser:GetPlayerOwnerID() or loser:GetPlayerID()
    local winnerID = winner:GetPlayerOwnerID() or winner:GetPlayerID()

    -- available gold
    local available = loser:GetGold()
    if available >= loss then
        PlayerResource:SpendGold(loserID, loss, 4)
        PlayerResource:ModifyGold(winnerID, gain, false, 0)
        -- win/lose particles
        local p5 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_emp.vpcf", PATTACH_ABSORIGIN_FOLLOW, winner)
        ParticleManager:DestroyParticle(p5, false)
        ParticleManager:ReleaseParticleIndex(p5)
        local p6 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, loser)
        ParticleManager:DestroyParticle(p6, false)
        ParticleManager:ReleaseParticleIndex(p6)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, winner, gain, nil)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, loser, -loss, nil)
    else
        -- partial payment and debt
        PlayerResource:SpendGold(loserID, available, 4)
        local paid = math.min(available, gain)
        PlayerResource:ModifyGold(winnerID, paid, false, 0)
        local unpaid = loss - available
        local existing = loser:HasModifier("modifier_stint_w_debt") and loser:FindModifierByName("modifier_stint_w_debt"):GetStackCount() or 0
        local cap = caster:HasShard() and shard_max or max_debt
        local new_debt = math.min(existing + unpaid, cap)
        if not loser:HasModifier("modifier_stint_w_debt") then
            loser:AddNewModifier(caster, self, "modifier_stint_w_debt", {})
        end
        loser:FindModifierByName("modifier_stint_w_debt"):SetStackCount(new_debt)
        if caster:HasShard() then
            PlayerResource:ModifyGold(winnerID, unpaid, false, 0)
        end
        -- debt particle
        local p7 = ParticleManager:CreateParticle("particles/units/heroes/hero_bane/bane_nightmare.vpcf", PATTACH_OVERHEAD_FOLLOW, loser)
        ParticleManager:DestroyParticle(p7, false)
        ParticleManager:ReleaseParticleIndex(p7)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, winner, paid, nil)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, loser, -available, nil)
    end
end

-- Modifier to track debt stacks (tooltip shows amount)
modifier_stint_w_debt = class({})

function modifier_stint_w_debt:IsHidden()      return false end
function modifier_stint_w_debt:IsPurgable()    return false end
function modifier_stint_w_debt:RemoveOnDeath() return false end

function modifier_stint_w_debt:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(0)
end

function modifier_stint_w_debt:DeclareFunctions()
    return { MODIFIER_PROPERTY_TOOLTIP }
end

function modifier_stint_w_debt:OnTooltip()
    return self:GetStackCount()
end