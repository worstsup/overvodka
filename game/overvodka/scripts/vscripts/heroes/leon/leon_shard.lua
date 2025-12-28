LinkLuaModifier("modifier_leon_shard_passive", "heroes/leon/leon_shard", LUA_MODIFIER_MOTION_NONE)

leon_shard = class({})

function leon_shard:GetIntrinsicModifierName()
    return "modifier_leon_shard_passive"
end

function leon_shard:Precache(context)
    PrecacheResource( "particle", "particles/leon_heal.vpcf", context )
end

modifier_leon_shard_passive = class({})

function modifier_leon_shard_passive:IsHidden() return true end
function modifier_leon_shard_passive:IsPurgable() return false end
function modifier_leon_shard_passive:RemoveOnDeath() return false end

local function LeonShard_IsEligible(parent)
    if not parent or parent:IsNull() then return false end
    if not parent:IsAlive() then return false end
    if parent:PassivesDisabled() then return false end
    if parent:IsOutOfGame() then return false end

    return true
end

function modifier_leon_shard_passive:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_ATTACK,
    }
end

function modifier_leon_shard_passive:OnAttack(params)
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    if params.attacker ~= parent then return end
    local target = params.target
    if not target or target:IsNull() then return end

    if target:GetTeamNumber() == parent:GetTeamNumber() then return end

    self._safeTime = 0.0
    self._nextHealTime = 0.0
end

function modifier_leon_shard_passive:OnCreated()
    if not IsServer() then return end

    self.delay = 4.0
    self.heal_pct = 13.0
    self.tick = 0.10
    self.heal_interval = 1.0

    local ability = self:GetAbility()
    if ability and not ability:IsNull() then
        self.delay = math.max(0, ability:GetSpecialValueFor("no_damage_delay") or self.delay)
        self.heal_pct = ability:GetSpecialValueFor("heal_pct") or self.heal_pct
    end

    self._safeTime = 0.0
    self._nextHealTime = 0.0

    self:StartIntervalThink(self.tick)
end

function modifier_leon_shard_passive:OnRefresh()
    if not IsServer() then return end
    local ability = self:GetAbility()
    if ability and not ability:IsNull() then
        self.delay = math.max(0, ability:GetSpecialValueFor("no_damage_delay") or self.delay)
        self.heal_pct = ability:GetSpecialValueFor("heal_pct") or self.heal_pct
    end
end

function modifier_leon_shard_passive:OnTakeDamage(params)
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    if params.unit ~= parent then return end
    if (params.damage or 0) <= 0 then return end

    self._safeTime = 0.0
    self._nextHealTime = 0.0
end

function modifier_leon_shard_passive:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    if not LeonShard_IsEligible(parent) then
        return
    end

    local now = GameRules:GetGameTime()
    self._safeTime = (self._safeTime or 0.0) + self.tick
    if self._safeTime < self.delay then
        return
    end

    if (self._nextHealTime or 0.0) <= 0.0 then
        self._nextHealTime = now
    end

    if now < self._nextHealTime then
        return
    end

    local max_hp = parent:GetMaxHealth()
    local cur_hp = parent:GetHealth()
    if max_hp <= cur_hp then return end
    if max_hp <= 0 then return end

    local heal = max_hp * (self.heal_pct / 100.0)
    if heal > 0 then
        parent:HealWithParams(heal, self, false, true, parent, false)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, heal, parent:GetPlayerOwner())
        local particle = ParticleManager:CreateParticle("particles/leon_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:ReleaseParticleIndex(particle)
        parent:EmitSound("Leon.Heal")
    end
    self._nextHealTime = now + self.heal_interval
end
