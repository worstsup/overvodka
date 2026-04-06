LinkLuaModifier("modifier_misolo_shard", "heroes/misolo/misolo_shard", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_misolo_shard_debuff", "heroes/misolo/misolo_shard", LUA_MODIFIER_MOTION_NONE)

misolo_shard = class({})

modifier_misolo_shard = class({})
modifier_misolo_shard_debuff = class({})

function misolo_shard:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_broodmother/broodmother_incapacitatingbite_debuff.vpcf", context)
end

function misolo_shard:GetIntrinsicModifierName()
    return "modifier_misolo_shard"
end

function modifier_misolo_shard:IsHidden() return true end
function modifier_misolo_shard:IsPurgable() return false end
function modifier_misolo_shard:RemoveOnDeath() return false end

function modifier_misolo_shard:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_misolo_shard:OnAttackLanded(params)
    if not IsServer() then
        return
    end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    local attacker = params.attacker
    local target = params.target
    if not IsValid(parent, ability, attacker, target) or not parent:HasShard() or parent:PassivesDisabled() then
        return
    end

    if target:GetTeamNumber() == parent:GetTeamNumber() or target:IsBuilding() or target:IsWard() or target:IsOther() then
        return
    end

    local slow = 0
    local miss = 0
    if attacker == parent then
        slow = ability:GetSpecialValueFor("hero_slow_per_hit")
        miss = ability:GetSpecialValueFor("hero_miss_per_hit")
    else
        local attacker_name = attacker:GetUnitName() or ""
        if attacker:GetOwner() ~= parent or (not attacker:HasModifier("modifier_misolo_web_spider") and string.find(attacker_name, "spider", 1, true) == nil) then
            return
        end

        slow = ability:GetSpecialValueFor("spider_slow_per_hit")
        miss = ability:GetSpecialValueFor("spider_miss_per_hit")
    end

    if slow <= 0 and miss <= 0 then
        return
    end

    target:AddNewModifier(parent, ability, "modifier_misolo_shard_debuff", {
        duration = ability:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance()),
        slow = slow,
        miss = miss,
    })
end

function modifier_misolo_shard_debuff:IsHidden() return false end
function modifier_misolo_shard_debuff:IsDebuff() return true end
function modifier_misolo_shard_debuff:IsPurgable() return true end

function modifier_misolo_shard_debuff:OnCreated(kv)
    local ability = self:GetAbility()

    self._txData = self._txData or {}
    self.max_slow = 30
    self.max_miss = 60
    self.miss = 0

    if IsValid(ability) then
        self.max_slow = ability:GetSpecialValueFor("max_slow")
        self.max_miss = ability:GetSpecialValueFor("max_miss")
    end

    if not IsServer() then
        return
    end

    self:SetHasCustomTransmitterData(true)
    self:SetStackCount(math.min(self.max_slow, tonumber(kv.slow) or 0))
    self.miss = math.min(self.max_miss, tonumber(kv.miss) or 0)
    self:SendBuffRefreshToClients()
end

function modifier_misolo_shard_debuff:OnRefresh(kv)
    local ability = self:GetAbility()

    self._txData = self._txData or {}
    self.max_slow = 30
    self.max_miss = 60

    if IsValid(ability) then
        self.max_slow = ability:GetSpecialValueFor("max_slow")
        self.max_miss = ability:GetSpecialValueFor("max_miss")
    end

    if not IsServer() then
        return
    end

    self:SetStackCount(math.min(self.max_slow, self:GetStackCount() + (tonumber(kv.slow) or 0)))
    self.miss = math.min(self.max_miss, (self.miss or 0) + (tonumber(kv.miss) or 0))
    self:SendBuffRefreshToClients()
end

function modifier_misolo_shard_debuff:AddCustomTransmitterData()
    self._txData.miss = self.miss
    return self._txData
end

function modifier_misolo_shard_debuff:HandleCustomTransmitterData(data)
    if data.miss ~= nil then
        self.miss = tonumber(data.miss) or 0
    end
end

function modifier_misolo_shard_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MISS_PERCENTAGE,
    }
end

function modifier_misolo_shard_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -math.min(self.max_slow, self:GetStackCount())
end

function modifier_misolo_shard_debuff:GetModifierMiss_Percentage()
    return math.min(self.max_miss, self.miss or 0)
end

function modifier_misolo_shard_debuff:GetEffectName()
    return "particles/units/heroes/hero_broodmother/broodmother_incapacitatingbite_debuff.vpcf"
end

function modifier_misolo_shard_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_misolo_shard_debuff:GetTexture()
    return "broodmother_incapacitating_bite"
end
