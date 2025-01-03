mellstroy_casino = class({})

-- Function to handle the spell cast
function mellstroy_casino:OnSpellStart()
    local caster = self:GetCaster()
    local player_id = caster:GetPlayerID()
    local hero_level = caster:GetLevel()
    local gold = PlayerResource:GetGold(player_id)
    local base_cost = self:GetSpecialValueFor( "base_cost" )
    local each_level = self:GetSpecialValueFor( "each_level" )
    local ability_cost = base_cost + (each_level * hero_level)
    if gold < ability_cost then
        caster:EmitSound("nomoney")
        if self:GetCaster():GetUnitName() == "npc_dota_hero_bounty_hunter" then
            self:EndCooldown()
        end
        return
    end
    PlayerResource:SpendGold(player_id, ability_cost, 4)
    local random_chance = RandomInt(1, 100)
    if random_chance <= 3 then -- 3% chance to give 10x the cost
        local reward = ability_cost * 10
        local notion = reward - ability_cost
        caster:ModifyGold(reward, false, 0)
        caster:EmitSound("jackpot") -- Play gold pickup sound
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, caster, notion, nil)
        local abilities_count = caster:GetAbilityCount()
        for i = 0, abilities_count - 1 do
            local ability = caster:GetAbilityByIndex(i)
            if ability and ability ~= self and ability:GetCooldownTimeRemaining() > 0 then
                -- Reduce the cooldown by half
                local new_cooldown = ability:GetCooldownTimeRemaining() * 0.5
                ability:EndCooldown()
                ability:StartCooldown(new_cooldown)
            end
        end
        if caster:HasScepter() then
            caster:ModifyStrength(1)
            caster:ModifyAgility(1)
            caster:ModifyIntellect(1)
        end
    elseif random_chance <= 57 then -- 50% chance to give double the cost 
        local reward = ability_cost * 2 
        local notion = reward - ability_cost
        caster:ModifyGold(reward, false, 0)
        caster:EmitSound("normalwin") -- Play gold pickup sound
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, caster, notion, nil)
        if caster:HasScepter() then
            caster:ModifyStrength(1)
            caster:ModifyAgility(1)
            caster:ModifyIntellect(1)
        end
    else -- 47% chance to give nothing
        caster:EmitSound("lose") -- Optional: play cancel sound for no reward
    end
end

-- Register the ability
function mellstroy_casino:OnUpgrade()
    -- This ability has only one level, so no additional behavior needed
end