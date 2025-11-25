LinkLuaModifier("modifier_overvodka_creep",              "modifiers/modifier_overvodka_creep",     LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_silvername_q_facet_2_murloc",  "heroes/silvername/silvername_q_facet_2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_silvername_q_facet_2_debuff",  "heroes/silvername/silvername_q_facet_2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_silvername_q_facet_2_buff",    "heroes/silvername/silvername_q_facet_2", LUA_MODIFIER_MOTION_NONE)

silvername_q_facet_2 = class({})

function silvername_q_facet_2:OnAbilityPhaseStart()
    EmitSoundOn("silvername_q_facet_2", self:GetCaster())
    return true
end

function silvername_q_facet_2:OnAbilityPhaseInterrupted()
    StopSoundOn("silvername_q_facet_2", self:GetCaster())
end

function silvername_q_facet_2:OnSpellStart()
    if not IsServer() then return end

    local caster   = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local count      = self:GetSpecialValueFor("count")
    local duration   = self:GetSpecialValueFor("duration")
    local base_damage= self:GetSpecialValueFor("base_dmg")
    local base_hp    = self:GetSpecialValueFor("base_hp")
    local gold       = self:GetSpecialValueFor("gold")
    local xp         = self:GetSpecialValueFor("xp")
    local bat        = self:GetSpecialValueFor("bat")

    local team       = caster:GetTeamNumber()
    local playerID   = caster:GetPlayerOwnerID()

    for i = 1, count do
        local spawn_pos = caster:GetAbsOrigin() + RandomVector(200)

        local murloc = CreateUnitByName(
            "npc_murloc",
            spawn_pos,
            true,
            caster,
            caster,
            team
        )

        if murloc and not murloc:IsNull() then
            murloc:SetControllableByPlayer(playerID, false)
            murloc:SetOwner(caster)

            murloc:SetBaseMaxHealth(base_hp)
            murloc:SetMaxHealth(base_hp)
            murloc:SetHealth(base_hp)
            murloc:SetBaseAttackTime(bat)
            murloc:SetBaseDamageMin(base_damage)
            murloc:SetBaseDamageMax(base_damage)
            murloc:SetMaximumGoldBounty(gold)
            murloc:SetMinimumGoldBounty(gold)
            murloc:SetDeathXP(xp)

            murloc:AddNewModifier(caster, self, "modifier_kill", { duration = duration })
            murloc:AddNewModifier(caster, self, "modifier_phased", {})
            murloc:AddNewModifier(caster, self, "modifier_overvodka_creep", {})
            murloc:AddNewModifier(caster, self, "modifier_silvername_q_facet_2_murloc", {
                second_life = 0,
            })

            local effect_cast = ParticleManager:CreateParticle(
                "particles/items_fx/necronomicon_spawn.vpcf",
                PATTACH_ABSORIGIN_FOLLOW,
                murloc
            )
            ParticleManager:SetParticleControl(effect_cast, 0, murloc:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(effect_cast)
        end
    end
end

modifier_silvername_q_facet_2_murloc = class({})

function modifier_silvername_q_facet_2_murloc:IsHidden()   return true end
function modifier_silvername_q_facet_2_murloc:IsPurgable() return false end

function modifier_silvername_q_facet_2_murloc:OnCreated(kv)
    self.parent  = self:GetParent()
    self.caster  = self:GetCaster()
    self.ability = self:GetAbility()

    self.can_reborn = not (kv and tonumber(kv.second_life or 0) == 1)

    if not IsServer() then return end
end

function modifier_silvername_q_facet_2_murloc:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_silvername_q_facet_2_murloc:OnDeath(event)
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end
    if event.unit ~= self.parent then return end
    if not self.can_reborn then return end
    if not self.ability or self.ability:IsNull() then return end
    if not self.caster or self.caster:IsNull() then return end

    self.can_reborn = false

    local caster   = self.caster
    local ability  = self.ability
    local team     = self.parent:GetTeamNumber()
    local playerID = caster:GetPlayerOwnerID()

    local base_damage = ability:GetSpecialValueFor("base_dmg")
    local base_hp     = ability:GetSpecialValueFor("base_hp")
    local gold        = ability:GetSpecialValueFor("gold")
    local xp          = ability:GetSpecialValueFor("xp")
    local bat         = ability:GetSpecialValueFor("bat")

    local default_duration = ability:GetSpecialValueFor("duration")
    local remaining = default_duration

    local kill_mod = self.parent:FindModifierByName("modifier_kill")
    if kill_mod then
        remaining = math.max(kill_mod:GetRemainingTime(), 0)
    end

    if remaining <= 0.03 then
        return
    end

    local death_pos = self.parent:GetAbsOrigin()
    self.parent:AddEffects(EF_NODRAW)

    local murloc2 = CreateUnitByName(
        "npc_murloc",
        death_pos,
        true,
        caster,
        caster,
        team
    )

    if murloc2 and not murloc2:IsNull() then
        murloc2:SetControllableByPlayer(playerID, false)
        murloc2:SetOwner(caster)

        murloc2:SetBaseMaxHealth(base_hp)
        murloc2:SetMaxHealth(base_hp)
        murloc2:SetHealth(base_hp)
        murloc2:SetBaseAttackTime(bat)
        murloc2:SetBaseDamageMin(base_damage)
        murloc2:SetBaseDamageMax(base_damage)
        murloc2:SetMaximumGoldBounty(gold)
        murloc2:SetMinimumGoldBounty(gold)
        murloc2:SetDeathXP(xp)

        murloc2:AddNewModifier(caster, ability, "modifier_kill", { duration = remaining })
        murloc2:AddNewModifier(caster, ability, "modifier_phased", {})
        murloc2:AddNewModifier(caster, ability, "modifier_overvodka_creep", {})
        murloc2:AddNewModifier(caster, ability, "modifier_silvername_q_facet_2_murloc", {
            second_life = 1,
        })

        local effect_cast = ParticleManager:CreateParticle(
            "particles/items_fx/necronomicon_spawn.vpcf",
            PATTACH_ABSORIGIN_FOLLOW,
            murloc2
        )
        ParticleManager:SetParticleControl(effect_cast, 0, murloc2:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end
end

function modifier_silvername_q_facet_2_murloc:OnAttackLanded(event)
    if not IsServer() then return end
    if event.attacker ~= self.parent then return end
    if not self.ability or self.ability:IsNull() then return end

    local target = event.target
    if not target or target:IsNull() then return end
    if target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
    if target:IsBuilding() then return end
    if target:IsMagicImmune() or target:IsDebuffImmune() then
        return
    end

    local debuff = target:AddNewModifier(
        self.caster,
        self.ability,
        "modifier_silvername_q_facet_2_debuff",
        { duration = self.ability:GetSpecialValueFor("debuff_duration") or 4.0 }
    )

    if debuff then
        local cur = debuff:GetStackCount()
        local max = 0

        if debuff.GetMaxStacks then
            max = debuff:GetMaxStacks()
        elseif self.ability and not self.ability:IsNull() then
            max = self.ability:GetSpecialValueFor("max_stacks") or 0
        end

        if max <= 0 then
            max = cur
        end

        if cur <= 0 then
            debuff:SetStackCount(1)
        elseif cur < max then
            debuff:SetStackCount(math.min(max, cur + 1))
        end
    end
end

modifier_silvername_q_facet_2_debuff = class({})

function modifier_silvername_q_facet_2_debuff:IsPurgable()   return true end
function modifier_silvername_q_facet_2_debuff:IsDebuff()     return true end
function modifier_silvername_q_facet_2_debuff:IsBuff()       return false end

function modifier_silvername_q_facet_2_debuff:OnCreated(kv)
    self.ability = self:GetAbility()
    self.caster  = self:GetCaster()

    self.as_reduction    = self.ability and self.ability:GetSpecialValueFor("as_reduction") or -10
    self.dmg_reduction   = self.ability and self.ability:GetSpecialValueFor("dmg_reduction") or -5
    self.armor_reduction = self.ability and self.ability:GetSpecialValueFor("armor_reduction") or -1.5

    if not IsServer() then return end

    if self:GetStackCount() < 0 then
        self:SetStackCount(0)
    end
end

function modifier_silvername_q_facet_2_debuff:UpdateCasterBuff(stack_diff)
    if not IsServer() then return end
    if stack_diff == 0 then return end

    local caster  = self.caster or self:GetCaster()
    local ability = self.ability or self:GetAbility()

    if not caster or caster:IsNull() then return end
    if not ability or ability:IsNull() then return end

    if not caster:HasTalent("special_bonus_unique_silvername_5") then
        return
    end

    local as_per_stack    = -(self.as_reduction or 0)
    local dmg_per_stack   = -(self.dmg_reduction or 0)
    local armor_per_stack = -(self.armor_reduction or 0)

    local as_delta    = as_per_stack    * stack_diff
    local dmg_delta   = dmg_per_stack   * stack_diff
    local armor_delta = armor_per_stack * stack_diff

    if as_delta == 0 and dmg_delta == 0 and armor_delta == 0 then
        return
    end

    local buff = caster:FindModifierByName("modifier_silvername_q_facet_2_buff")
    if not buff then
        buff = caster:AddNewModifier(caster, ability, "modifier_silvername_q_facet_2_buff", {})
    end

    if buff and buff.AddBonus then
        buff:AddBonus(as_delta, dmg_delta, armor_delta, stack_diff)
    end
end

function modifier_silvername_q_facet_2_debuff:OnStackCountChanged(iOldCount)
    if not IsServer() then return end

    if iOldCount == nil then iOldCount = 0 end
    if iOldCount < 0 then iOldCount = 0 end

    local newCount = self:GetStackCount() or 0
    if newCount < 0 then newCount = 0 end

    local diff = newCount - iOldCount
    if diff ~= 0 then
        self:UpdateCasterBuff(diff)
    end
end

function modifier_silvername_q_facet_2_debuff:OnDestroy()
    if not IsServer() then return end

    local stacks = self:GetStackCount() or 0
    if stacks > 0 then
        self:UpdateCasterBuff(-stacks)
    end
end

function modifier_silvername_q_facet_2_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end

function modifier_silvername_q_facet_2_debuff:GetModifierAttackSpeedBonus_Constant()
    return self.as_reduction * self:GetStackCount()
end

function modifier_silvername_q_facet_2_debuff:GetModifierPreAttack_BonusDamage()
    return self.dmg_reduction * self:GetStackCount()
end

function modifier_silvername_q_facet_2_debuff:GetModifierPhysicalArmorBonus()
    return self.armor_reduction * self:GetStackCount()
end

function modifier_silvername_q_facet_2_debuff:GetMaxStacks()
    if not self.ability or self.ability:IsNull() then return 0 end
    return self.ability:GetSpecialValueFor("max_stacks") or 0
end


modifier_silvername_q_facet_2_buff = class({})

function modifier_silvername_q_facet_2_buff:IsPurgable()     return true  end
function modifier_silvername_q_facet_2_buff:IsDebuff()       return false end
function modifier_silvername_q_facet_2_buff:IsBuff()         return true  end
function modifier_silvername_q_facet_2_buff:IsHidden()       return false end
function modifier_silvername_q_facet_2_buff:RemoveOnDeath()  return true  end

function modifier_silvername_q_facet_2_buff:OnCreated(kv)
    self.as_bonus       = self.as_bonus       or 0
    self.dmg_bonus      = self.dmg_bonus      or 0
    self.armor_bonus    = self.armor_bonus    or 0
    self.stack_internal = self.stack_internal or 0

    self.is_owner = (self:GetParent() == self:GetCaster())

    if IsServer() then
        self:SetHasCustomTransmitterData(true)

        if not self.is_owner then
            self:StartIntervalThink(0.2)
        end

        self:SendBuffRefreshToClients()
    end
end

function modifier_silvername_q_facet_2_buff:OnRefresh(kv)
    if IsServer() then
        self:SendBuffRefreshToClients()
    end
end

function modifier_silvername_q_facet_2_buff:IsAura()
    return self.is_owner
end

function modifier_silvername_q_facet_2_buff:GetAuraRadius()      return 900 end
function modifier_silvername_q_facet_2_buff:GetAuraSearchTeam()  return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_silvername_q_facet_2_buff:GetAuraSearchType()  return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_silvername_q_facet_2_buff:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_silvername_q_facet_2_buff:GetModifierAura()    return "modifier_silvername_q_facet_2_buff" end
function modifier_silvername_q_facet_2_buff:GetAuraDuration()    return 0.1 end

function modifier_silvername_q_facet_2_buff:GetAuraEntityReject(hEntity)
    if IsServer() then
        if hEntity == self:GetCaster() then
            return true
        end
    end
    return false
end

function modifier_silvername_q_facet_2_buff:OnIntervalThink()
    if not IsServer() then return end
    if self.is_owner then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then
        self.as_bonus       = 0
        self.dmg_bonus      = 0
        self.armor_bonus    = 0
        self.stack_internal = 0
        self:SetStackCount(0)
        self:SendBuffRefreshToClients()
        self:StartIntervalThink(-1)
        return
    end

    local ownerBuff = caster:FindModifierByName("modifier_silvername_q_facet_2_buff")
    if ownerBuff and not ownerBuff:IsNull() and ownerBuff ~= self then
        self.as_bonus       = ownerBuff.as_bonus       or 0
        self.dmg_bonus      = ownerBuff.dmg_bonus      or 0
        self.armor_bonus    = ownerBuff.armor_bonus    or 0
        self.stack_internal = ownerBuff.stack_internal or ownerBuff:GetStackCount() or 0
    else
        self.as_bonus       = 0
        self.dmg_bonus      = 0
        self.armor_bonus    = 0
        self.stack_internal = 0
    end

    self:SetStackCount(self.stack_internal or 0)
    self:SendBuffRefreshToClients()
end
function modifier_silvername_q_facet_2_buff:AddCustomTransmitterData()
    return {
        as_bonus       = self.as_bonus       or 0,
        dmg_bonus      = self.dmg_bonus      or 0,
        armor_bonus    = self.armor_bonus    or 0,
        stack_internal = self.stack_internal or self:GetStackCount() or 0,
    }
end

function modifier_silvername_q_facet_2_buff:HandleCustomTransmitterData(data)
    self.as_bonus       = data.as_bonus       or 0
    self.dmg_bonus      = data.dmg_bonus      or 0
    self.armor_bonus    = data.armor_bonus    or 0
    self.stack_internal = data.stack_internal or 0

    self:SetStackCount(self.stack_internal or 0)
end

function modifier_silvername_q_facet_2_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end

function modifier_silvername_q_facet_2_buff:GetModifierAttackSpeedBonus_Constant()
    return self.as_bonus or 0
end

function modifier_silvername_q_facet_2_buff:GetModifierPreAttack_BonusDamage()
    return self.dmg_bonus or 0
end

function modifier_silvername_q_facet_2_buff:GetModifierPhysicalArmorBonus()
    return self.armor_bonus or 0
end

function modifier_silvername_q_facet_2_buff:AddBonus(as_delta, dmg_delta, armor_delta, stack_delta)
    if not self.is_owner then
        return
    end

    self.as_bonus       = (self.as_bonus or 0)       + (as_delta    or 0)
    self.dmg_bonus      = (self.dmg_bonus or 0)      + (dmg_delta   or 0)
    self.armor_bonus    = (self.armor_bonus or 0)    + (armor_delta or 0)
    self.stack_internal = (self.stack_internal or 0) + (stack_delta or 0)

    if self.stack_internal < 0 then
        self.stack_internal = 0
    end

    self:SetStackCount(self.stack_internal or 0)

    if IsServer() then
        self:SendBuffRefreshToClients()

        if (not self.as_bonus or self.as_bonus == 0)
        and (not self.dmg_bonus or self.dmg_bonus == 0)
        and (not self.armor_bonus or self.armor_bonus == 0)
        and (not self.stack_internal or self.stack_internal == 0) then
            self:Destroy()
        end
    end
end