LinkLuaModifier("modifier_silvername_garr", "heroes/silvername/silvername_scepter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_silvername_garr_aura_buff", "heroes/silvername/silvername_scepter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_silvername_scepter_autolevel", "heroes/silvername/silvername_scepter", LUA_MODIFIER_MOTION_NONE)

silvername_scepter = class({})

function silvername_scepter:GetIntrinsicModifierName()
    return "modifier_silvername_scepter_autolevel"
end

modifier_silvername_scepter_autolevel = class({})

function modifier_silvername_scepter_autolevel:IsHidden()      return true end
function modifier_silvername_scepter_autolevel:IsPurgable()    return false end
function modifier_silvername_scepter_autolevel:RemoveOnDeath() return false end
function modifier_silvername_scepter_autolevel:IsDebuff()      return false end
function modifier_silvername_scepter_autolevel:IsBuff()        return true end

function modifier_silvername_scepter_autolevel:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
    self:OnIntervalThink()
end

function modifier_silvername_scepter_autolevel:OnIntervalThink()
    if not IsServer() then return end

    local parent  = self:GetParent()
    if not parent or parent:IsNull() then
        self:Destroy()
        return
    end

    local ability = self:GetAbility()
    if not ability or ability:IsNull() then
        self:Destroy()
        return
    end

    ability:SyncLevelWithHero()
end


function silvername_scepter:SyncLevelWithHero()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local hero_level = caster:GetLevel()
    local new_level = 1

    if hero_level >= 20 then
        new_level = 4
    elseif hero_level >= 15 then
        new_level = 3
    elseif hero_level >= 10 then
        new_level = 2
    elseif hero_level >= 5 then
        new_level = 1
    else
        new_level = 1
    end

    if self:GetLevel() ~= new_level then
        self:SetLevel(new_level)
    end
end

function silvername_scepter:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end
    self:SyncLevelWithHero()

    if self.summoned_garr and IsValidEntity(self.summoned_garr) then
        if self.summoned_garr:IsAlive() then
            self.summoned_garr:ForceKill(false)
        end
        self.summoned_garr = nil
    end

    local spawn_distance = 100
    local spawn_pos = caster:GetAbsOrigin() + caster:GetForwardVector() * spawn_distance

    local team = caster:GetTeamNumber()
    local owner = caster
    local playerID = caster:GetPlayerOwnerID()

    local garr = CreateUnitByName("npc_silvername_garr", spawn_pos, true, owner, owner, team)

    if not garr or garr:IsNull() then
        return
    end

    garr:SetControllableByPlayer(playerID, true)
    garr:SetOwner(owner)

    self.summoned_garr = garr

    garr:AddNewModifier(caster, self, "modifier_silvername_garr", {})

    self:SetupGarrStats(garr, caster)
end

function silvername_scepter:SetupGarrStats(garr, caster)
    if not IsServer() then return end
    if not garr or garr:IsNull() then return end
    if not caster or caster:IsNull() then return end

    local hp = self:GetSpecialValueFor("health") or 1100
    local movespeed = self:GetSpecialValueFor("movespeed") or 400
    local bat = self:GetSpecialValueFor("bat") or 1.1
    local range = self:GetSpecialValueFor("range") or 300
    local gold = self:GetSpecialValueFor("gold") or 200
    local xp = self:GetSpecialValueFor("xp") or 200

    garr:SetBaseMaxHealth(hp)
    garr:SetMaxHealth(hp)
    garr:SetHealth(hp)

    local base_min = caster:GetBaseDamageMin()
    local base_max = caster:GetBaseDamageMax()
    garr:SetBaseDamageMin(base_min)
    garr:SetBaseDamageMax(base_max)

    garr:SetBaseMoveSpeed(movespeed)
    garr:SetBaseAttackTime(bat)

    garr:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
    garr:SetAttackRange(range)

    garr:SetMaximumGoldBounty(gold)
    garr:SetMinimumGoldBounty(gold)
    garr:SetDeathXP(xp)
end


modifier_silvername_garr = class({})

function modifier_silvername_garr:IsHidden()      return true end
function modifier_silvername_garr:IsPurgable()    return false end
function modifier_silvername_garr:IsDebuff()      return false end
function modifier_silvername_garr:IsBuff()        return true end

function modifier_silvername_garr:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION]             = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
    }
end

function modifier_silvername_garr:OnCreated()
    self.parent  = self:GetParent()
    self.caster  = self:GetCaster()
    self.ability = self:GetAbility()

    if not IsServer() then return end

    if self.ability and not self.ability:IsNull() then
        self.ability.summoned_garr = self.parent
    end
end

function modifier_silvername_garr:OnDestroy()
    if not IsServer() then return end

    if self.ability and not self.ability:IsNull() then
        if self.ability.summoned_garr == self:GetParent() then
            self.ability.summoned_garr = nil
        end
    end
end

function modifier_silvername_garr:IsAura()
    return true
end

function modifier_silvername_garr:GetAuraRadius()
    if not self.ability or self.ability:IsNull() then return 0 end
    return self.ability:GetSpecialValueFor("aura_radius")
end

function modifier_silvername_garr:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_silvername_garr:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_silvername_garr:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED
end

function modifier_silvername_garr:GetModifierAura()
    return "modifier_silvername_garr_aura_buff"
end

function modifier_silvername_garr:IsAuraActiveOnDeath()
    return false
end

function modifier_silvername_garr:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_silvername_garr:OnAttackLanded(params)
    if not IsServer() then return end

    local parent  = self:GetParent()
    local ability = self:GetAbility()

    if not ability or ability:IsNull() then return end
    if params.attacker ~= parent then return end

    local target = params.target
    if not target or target:IsNull() then return end

    if target:IsMagicImmune() or target:IsInvulnerable() then
        return
    end

    local pull_distance = ability:GetSpecialValueFor("pull_distance")
    if pull_distance <= 0 then return end

    local parent_pos = parent:GetAbsOrigin()
    local target_pos = target:GetAbsOrigin()

    local center = target_pos * 2 - parent_pos

    local knockback = {
        knockback_duration = 0.25,
        duration           = 0.25,
        knockback_distance = pull_distance,
        knockback_height   = 0,
        center_x = center.x,
        center_y = center.y,
        center_z = center.z,
    }

    target:RemoveModifierByName("modifier_knockback")
    target:AddNewModifier(parent, ability, "modifier_knockback", knockback)
end

modifier_silvername_garr_aura_buff = class({})

function modifier_silvername_garr_aura_buff:IsHidden()   return false end
function modifier_silvername_garr_aura_buff:IsPurgable() return false end
function modifier_silvername_garr_aura_buff:IsDebuff()   return false end
function modifier_silvername_garr_aura_buff:IsBuff()     return true end

function modifier_silvername_garr_aura_buff:OnCreated()
    self.parent  = self:GetParent()
    self.caster  = self:GetCaster()
    self.ability = self:GetAbility()

    if not IsServer() then return end

    self:StartIntervalThink(0.3)
end

function modifier_silvername_garr_aura_buff:OnIntervalThink()
    if not IsServer() then return end

    if not self.ability or self.ability:IsNull() then return end

    local garr = self.ability.summoned_garr
    if not garr or garr:IsNull() then
        self:SetStackCount(0)
        return
    end

    local radius = self.ability:GetSpecialValueFor("aura_radius")
    if radius <= 0 then
        self:SetStackCount(0)
        return
    end

    local team   = garr:GetTeamNumber()
    local origin = garr:GetAbsOrigin()

    local allies = FindUnitsInRadius(
        team,
        origin,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED,
        FIND_ANY_ORDER,
        false
    )

    local summoned_count = 0
    for _,unit in ipairs(allies) do
        if unit
            and not unit:IsNull()
            and not unit:IsIllusion()
            and unit:IsSummoned()
        then
            summoned_count = summoned_count + 1
        end
    end

    self:SetStackCount(summoned_count)
end


function modifier_silvername_garr_aura_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_BONUS,
    }
end

function modifier_silvername_garr_aura_buff:GetModifierHealthBonus()
    if not self.ability or self.ability:IsNull() then return 0 end

    local hp_per_summon = self.ability:GetSpecialValueFor("hp_per_summon") or 0
    local count = self:GetStackCount() or 0

    return hp_per_summon * count
end
