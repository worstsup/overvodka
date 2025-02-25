LinkLuaModifier( "modifier_mell_two", "heroes/mellstroy/modifier_mell_two", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mell_one", "heroes/mellstroy/modifier_mell_one", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mell_three", "heroes/mellstroy/modifier_mell_three", LUA_MODIFIER_MOTION_NONE )
mellstroy_casino_allin = class({})
k = 0
function mellstroy_casino_allin:OnSpellStart()
    local caster = self:GetCaster()
    local player_id = caster:GetPlayerID()
    local hero_level = caster:GetLevel()
    local ability_cost = PlayerResource:GetGold(player_id) * 0.5
    PlayerResource:SpendGold(player_id, ability_cost, 4)
    local random_chance = RandomInt(1, 100)
    if random_chance <= 50 then
        local reward = ability_cost * 2 
        local notion = reward - ability_cost
        caster:ModifyGold(reward, false, 0)
        caster:EmitSound("jackpot")
        if k == 0 then
            caster:AddNewModifier(caster, self, "modifier_mell_one", { duration = 3 })
        end
        if k == 1 then
            caster:AddNewModifier(caster, self, "modifier_mell_two", { duration = 3 })
        end
        if k == 2 then
            caster:AddNewModifier(caster, self, "modifier_mell_three", { duration = 3 })
        end
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, caster, notion, nil)
        k = k + 1
    else
        caster:EmitSound("lose")
    end
    if k >= 3 then
        self:SetActivated( false )
    end
end

function mellstroy_casino_allin:OnUpgrade()
end