LinkLuaModifier("modifier_stint_w_debt", "heroes/stint/stint_w", LUA_MODIFIER_MOTION_NONE)

stint_w = class({})

function stint_w:Precache(context)
    PrecacheResource("particle", "particles/stint_counter.vpcf", context)
    PrecacheResource("particle", "particles/stint_debt.vpcf", context)
    PrecacheResource("soundfile", "soundevents/stint_w.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_ogre_magi.vsndevts", context)
end

function stint_w:CastFilterResultTarget( hTarget )
    if not IsServer() then
        return UF_SUCCESS
    end
    local filterResult = UnitFilter(
        hTarget,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
        self:GetCaster():GetTeamNumber()
    )
    if filterResult ~= UF_SUCCESS then
        return filterResult
    end
    local cost = self:GetSpecialValueFor("investment")
    local playerID = hTarget:GetPlayerID()
    if PlayerResource:GetGold(playerID) < cost then
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end

function stint_w:GetCustomCastErrorTarget( hTarget )
    return "#dota_hud_error_stint_enemy_no_gold"
end

function stint_w:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local cost   = self:GetSpecialValueFor("investment")
    local casterID = caster:GetPlayerOwnerID()
    PlayerResource:SpendGold(casterID, cost, DOTA_ModifyGold_Unspecified)
    local targetID = target:GetPlayerOwnerID()
    local target_gold = PlayerResource:GetGold(targetID)
    PlayerResource:SpendGold(targetID, cost, DOTA_ModifyGold_Unspecified)
    target_gold = PlayerResource:GetGold(targetID)
    EmitSoundOn("stint_w", caster)
    local function roll(ch_bad, ch_15, ch_2, ch_25)
        local r = RandomInt(1, 100)
        if r <= ch_bad then return 0 end
        r = r - ch_bad
        if r <= ch_15 then return 1.5 end
        r = r - ch_15
        if r <= ch_2 then return 2 end
        return 2.5
    end
    local ch_bad   = self:GetSpecialValueFor("chance_bad")
    local ch_15    = self:GetSpecialValueFor("chance_1_5")
    local ch_2     = self:GetSpecialValueFor("chance_2")
    local ch_25    = self:GetSpecialValueFor("chance_2_5")
    local max_debt = self:GetSpecialValueFor("max_debt")

    local mC = roll(0, ch_15 + ch_bad/3, ch_2 + ch_bad/3, ch_25 + ch_bad/3)
    local mT = roll(ch_bad, ch_15, ch_2, ch_25)
    print(string.format("[Stint W] %s rolled %.1fx, %s rolled %.1fx", caster:GetName(), mC, target:GetName(), mT))
    local part1_caster = math.floor(mC) + 10
    local part2_caster
    if mC == 1.5 or mC == 2.5 then
        part2_caster = 28
    end
    local part1_target = math.floor(mT) + 10
    local part2_target
    if mT == 1.5 or mT == 2.5 then
        part2_target = 28
    end
    local effect_caster = ParticleManager:CreateParticle("particles/stint_counter.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
    ParticleManager:SetParticleControl(effect_caster, 1, Vector(part1_caster, 0, 0))
    ParticleManager:SetParticleControl(effect_caster, 2, Vector(part2_caster, 0, 0))
    local effect_target = ParticleManager:CreateParticle("particles/stint_counter.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
    ParticleManager:SetParticleControl(effect_target, 1, Vector(part1_target, 0, 0))
    ParticleManager:SetParticleControl(effect_target, 2, Vector(part2_target, 0, 0))
    ParticleManager:ReleaseParticleIndex(effect_caster)
    ParticleManager:ReleaseParticleIndex(effect_target)
    if self:GetSpecialValueFor("heal") > 0 then
        if mC > 0 then
            local heal = self:GetSpecialValueFor("heal") * cost * mC * 0.01
            self:GetCaster():HealWithParams(heal, self, false, true, self:GetCaster(), false)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self:GetCaster(), heal, self:GetCaster():GetPlayerOwner())
        end
    end
    if mC == 0 and mT == 0 then
        return
    end
    if mC > 0 and mT > 0 then
        local reward_caster = cost * mC
        local reward_target = cost * mT
        caster:ModifyGold(reward_caster, false, 0)
        target:ModifyGold(reward_target, false, 0)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, caster, reward_caster, nil)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, target, reward_target, nil)
        EmitSoundOn( "Hero_OgreMagi.Fireblast.x1", caster )
        return
    end
    if (mC > 0 and mT == 0) or (mC == 0 and mT > 0) then
        local winner
        local loser
        local mW
        if mC > 0 then
            winner = caster
            loser = target
            mW = mC
        else
            winner = target
            loser = caster
            mW = mT
        end
        EmitSoundOn( "Hero_OgreMagi.Fireblast.x1", winner )
        local reward_winner = cost * mW
        local lost_money = cost * (mW - 1)
        local loserID = loser:GetPlayerID()
        if PlayerResource:GetGold(loserID) >= lost_money then
            winner:ModifyGold(reward_winner, false, 0)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, winner, reward_winner, nil)
            PlayerResource:SpendGold(loserID, lost_money, DOTA_ModifyGold_Unspecified)
        else
            local loser_balance = PlayerResource:GetGold(loserID)
            winner:ModifyGold(loser_balance, false, 0)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, winner, loser_balance, nil)
            PlayerResource:SpendGold(loserID, loser_balance, DOTA_ModifyGold_Unspecified)
            local debt = lost_money - loser_balance
            if loser:GetUnitName() == caster:GetUnitName() and self:GetSpecialValueFor("no_damage") == 0 then
                ApplyDamage({
                    victim = caster,
                    attacker = caster,
                    damage = debt,
                    damage_type = DAMAGE_TYPE_PURE,
                    ability = self
                })
            else
                local stacks
                if loser:HasModifier("modifier_stint_w_debt") then
                    local loserMod = loser:FindModifierByName("modifier_stint_w_debt")
                    local newstack = loserMod:GetStackCount() + debt
                    stacks = math.min(newstack, max_debt)
                    loserMod:SetStackCount(stacks)
                else
                    local debt_modifier = loser:AddNewModifier(caster, self, "modifier_stint_w_debt", {})
                    stacks = math.min(debt, max_debt)
                    debt_modifier:SetStackCount(stacks)
                end
            end
        end
    end
end

modifier_stint_w_debt = class({})

function modifier_stint_w_debt:IsHidden() return false end
function modifier_stint_w_debt:IsPurgable() return false end
function modifier_stint_w_debt:RemoveOnDeath() return false end

function modifier_stint_w_debt:OnCreated()
    if not IsServer() then return end
    self.debtor = self:GetParent()
    self.caster = self:GetCaster()
    self.debt = self:GetStackCount()
    self.interval = 1.0
    self:StartIntervalThink(self.interval)
end

function modifier_stint_w_debt:OnIntervalThink()
    if not IsServer() then return end
    if not self.caster:HasShard() then return end
    if math.abs(self.interval - 10.0) > 0.1 then
        self.interval = 10.0
        self:StartIntervalThink(self.interval)
    end
    local debt = self:GetStackCount()
    if debt <= 0 then self:Destroy() return end
    local current_balance = PlayerResource:GetGold(self.debtor:GetPlayerID())
    local actual = math.min(current_balance, debt)
    if actual > 0 then
        PlayerResource:SpendGold(self.debtor:GetPlayerID(), actual, DOTA_ModifyGold_Unspecified)
        self.caster:ModifyGold(actual, false, 0)
        debt = debt - actual
        self:SetStackCount(debt)
        local effect_cast_debtor = ParticleManager:CreateParticle("particles/stint_debt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.debtor)
        ParticleManager:ReleaseParticleIndex(effect_cast_debtor)
        local effect_cast_caster = ParticleManager:CreateParticle("particles/stint_debt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
        ParticleManager:ReleaseParticleIndex(effect_cast_caster)
        print(string.format("[Stint W Debt] %s paid %d to %s, remaining %d", self.debtor:GetName(), actual, self.caster:GetName(), debt))
    end
    if debt <= 0 then self:Destroy() end
end

function modifier_stint_w_debt:DeclareFunctions()
    return { MODIFIER_PROPERTY_TOOLTIP }
end

function modifier_stint_w_debt:OnTooltip()
    return self:GetStackCount()
end