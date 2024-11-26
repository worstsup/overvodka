mellstroy_casino_allin = class({})

function mellstroy_casino_allin:OnSpellStart()
    local caster = self:GetCaster()
    local player_id = caster:GetPlayerID()
    local hero_level = caster:GetLevel()
    local ability_cost = PlayerResource:GetGold(player_id)
    PlayerResource:SpendGold(player_id, ability_cost, 4)
    local random_chance = RandomInt(1, 100)
    if random_chance <= 50 then -- 50% chance to give double the cost 
        local reward = ability_cost * 2 
        local notion = reward - ability_cost
        caster:ModifyGold(reward, false, 0)
        caster:EmitSound("jackpot") -- Play gold pickup sound
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, caster, notion, nil)
    else -- 50% chance to give nothing
        caster:EmitSound("lose") -- play cancel sound for no reward
    end
end

-- Register the ability
function mellstroy_casino_allin:OnUpgrade()
    -- This ability has only one level, so no additional behavior needed
end