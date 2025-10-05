LinkLuaModifier("modifier_mellstroy_casino_sounds", "heroes/mellstroy/casino", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mellstroy_casino_sounds_cd", "heroes/mellstroy/casino", LUA_MODIFIER_MOTION_NONE)

mellstroy_casino = class({})

function mellstroy_casino:Precache(context)
    PrecacheResource( "soundfile", "soundevents/nomoney.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/jackpot.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/lose.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/normalwin.vsndevts", context )
end

function mellstroy_casino:GetIntrinsicModifierName()
    return "modifier_mellstroy_casino_sounds"
end

loses = 0
function mellstroy_casino:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local player_id = caster:GetPlayerID()
    local hero_level = caster:GetLevel()
    local gold = PlayerResource:GetGold(player_id)
    local base_cost = self:GetSpecialValueFor( "base_cost" )
    local each_level = self:GetSpecialValueFor( "each_level" )
    local jackpot_chance = self:GetSpecialValueFor( "jackpot_chance" )
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
    if random_chance <= jackpot_chance then
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
    elseif random_chance <= 55 or loses >= 2 then
        local reward = ability_cost * 2 
        local notion = reward - ability_cost
        caster:ModifyGold(reward, false, 0)
        caster:EmitSound("normalwin")
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, caster, notion, nil)
        loses = 0
    else
        caster:EmitSound("lose_"..RandomInt(1,2))
        loses = loses + 1
    end
end

modifier_mellstroy_casino_sounds = class({})

function modifier_mellstroy_casino_sounds:IsHidden() return true end
function modifier_mellstroy_casino_sounds:IsPurgable() return false end

function modifier_mellstroy_casino_sounds:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
    self:OnIntervalThink()
end

function modifier_mellstroy_casino_sounds:OnIntervalThink()
    local parent = self:GetParent()
    local player_id = parent:GetPlayerID()
	local gold = PlayerResource:GetGold(player_id)
    if gold < 50 then
        if not parent:HasModifier("modifier_mellstroy_casino_sounds_cd") then
            parent:EmitSound("mellstroy_nishiy")
            parent:AddNewModifier(parent, self:GetAbility(), "modifier_mellstroy_casino_sounds_cd", {duration = 30})
        end
    end
end

function modifier_mellstroy_casino_sounds:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_DEATH
    }
end

function modifier_mellstroy_casino_sounds:OnAttack(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    if params.attacker == parent then
        if RandomInt(1, 100) <= 3 then
            parent:EmitSound("mellstroy_attack")
        end
    end
end

function modifier_mellstroy_casino_sounds:OnDeath(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    if params.unit == parent then
        if RandomInt(1, 2) >= 1 then
            parent:EmitSound("mellstroy_death")
        end
    end
end

modifier_mellstroy_casino_sounds_cd = class({})

function modifier_mellstroy_casino_sounds_cd:IsHidden() return true end
function modifier_mellstroy_casino_sounds_cd:IsPurgable() return false end