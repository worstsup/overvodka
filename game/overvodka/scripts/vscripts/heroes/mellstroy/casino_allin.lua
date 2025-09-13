LinkLuaModifier( "modifier_mell_success_counter", "heroes/mellstroy/mellstroy_casino_allin", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mell_two",   "heroes/mellstroy/mellstroy_casino_allin", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mell_one",   "heroes/mellstroy/mellstroy_casino_allin", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mell_three", "heroes/mellstroy/mellstroy_casino_allin", LUA_MODIFIER_MOTION_NONE )

mellstroy_casino_allin = class({})

function mellstroy_casino_allin:Precache(context)
    PrecacheResource( "soundfile", "soundevents/jackpot.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/lose.vsndevts", context )
end

function mellstroy_casino_allin:OnOwnerSpawned()
    if not IsServer() then return end
    local c = self:GetCaster()
    local m = c:FindModifierByName("modifier_mell_success_counter")
    self:SetActivated( not (m and m:GetStackCount() >= 3) )
end

function mellstroy_casino_allin:OnSpellStart()
    if not IsServer() then return end
    local caster    = self:GetCaster()
    local player_id = caster:GetPlayerID()

    local counter = caster:FindModifierByName("modifier_mell_success_counter")
    if not counter then
        counter = caster:AddNewModifier(caster, self, "modifier_mell_success_counter", {})
    end
    local wins = counter:GetStackCount()
    if wins >= 3 then
        self:SetActivated(false)
        return
    end

    local gold_now     = PlayerResource:GetGold(player_id)
    local ability_cost = math.max(0, math.floor(gold_now * 0.5))
    if ability_cost > 0 then
        PlayerResource:SpendGold(player_id, ability_cost, 4)
    end

    local random_chance = RandomInt(1, 100)
    if random_chance <= 60 then
        local reward = ability_cost * 2
        local delta  = reward - ability_cost
        caster:ModifyGold(reward, false, 0)
        caster:EmitSound("jackpot")
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, caster, delta, nil)
        wins = wins + 1
        counter:SetStackCount(wins)

        if wins == 1 then
            caster:AddNewModifier(caster, self, "modifier_mell_one",   { duration = 3 })
        elseif wins == 2 then
            caster:AddNewModifier(caster, self, "modifier_mell_two",   { duration = 3 })
        elseif wins == 3 then
            caster:AddNewModifier(caster, self, "modifier_mell_three", { duration = 3 })
        end

        if wins >= 3 then
            self:SetActivated(false)
        end
    else
        caster:EmitSound("lose")
    end
end

modifier_mell_success_counter = class({})

function modifier_mell_success_counter:IsHidden() return true end
function modifier_mell_success_counter:IsPurgable() return false end
function modifier_mell_success_counter:RemoveOnDeath() return false end


modifier_mell_one = class({})

function modifier_mell_one:IsPurgable()
	return false
end
function modifier_mell_one:IsHidden()
	return true
end

function modifier_mell_one:GetEffectName()
	return "particles/marci_unleash_stack_number_one.vpcf"
end

function modifier_mell_one:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end


modifier_mell_two = class({})

function modifier_mell_two:IsPurgable()
	return false
end
function modifier_mell_two:IsHidden()
	return true
end

function modifier_mell_two:GetEffectName()
	return "particles/marci_unleash_stack_number_two.vpcf"
end

function modifier_mell_two:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end


modifier_mell_three = class({})

function modifier_mell_three:IsPurgable()
	return false
end
function modifier_mell_three:IsHidden()
	return true
end

function modifier_mell_three:GetEffectName()
	return "particles/marci_unleash_stack_number_three.vpcf"
end

function modifier_mell_three:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end