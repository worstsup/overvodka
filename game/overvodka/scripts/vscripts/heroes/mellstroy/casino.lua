mellstroy_casino = class({})

loses = 0

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
    if random_chance <= 3 then
        local reward = ability_cost * 10
        local notion = reward - ability_cost
        caster:ModifyGold(reward, false, 0)
        caster:EmitSound("jackpot")
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, caster, notion, nil)
        local abilities_count = caster:GetAbilityCount()
        for i = 0, abilities_count - 1 do
            local ability = caster:GetAbilityByIndex(i)
            if ability and ability ~= self and ability:GetCooldownTimeRemaining() > 0 then
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
    elseif random_chance <= 60 or loses >= 5 then
        local reward = ability_cost * 2 
        local notion = reward - ability_cost
        caster:ModifyGold(reward, false, 0)
        caster:EmitSound("normalwin")
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, caster, notion, nil)
        if caster:HasScepter() then
            caster:ModifyStrength(1)
            caster:ModifyAgility(1)
            caster:ModifyIntellect(1)
        end
        loses = 0
    else
        caster:EmitSound("lose")
        loses = loses + 1
    end
end

function mellstroy_casino:OnUpgrade()
end