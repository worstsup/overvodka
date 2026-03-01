LinkLuaModifier("modifier_leon_w_illusion_ai",  "heroes/leon/leon_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_leon_w_uncontrolled", "heroes/leon/leon_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_leon_w_facet",        "heroes/leon/leon_w", LUA_MODIFIER_MOTION_NONE)

leon_w = class({})

function leon_w:GetIntrinsicModifierName()
    return "modifier_leon_w_facet"
end

modifier_leon_w_facet = class({})

function modifier_leon_w_facet:IsHidden() return true end
function modifier_leon_w_facet:IsPurgable() return false end
function modifier_leon_w_facet:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
    }
end

function modifier_leon_w_facet:OnAbilityExecuted(params)
    if not IsServer() then return end
    if self:GetAbility():GetSpecialValueFor("facet_enabled") == 0 then return end
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end
    if params.unit ~= parent then return end
    local ability = params.ability
    if not ability or ability:IsNull() then return end

    if ability:GetName() == "leon_r" then
        self:GetAbility():MakeClones(1)
    end
end

function leon_w:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end
    local count = 1
    if caster:HasTalent("special_bonus_unique_leon_6") then
        count = 2
    end

    self:MakeClones(count)
end

function leon_w:MakeClones(count)
    if not IsServer() then return end
    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end
    local duration      = self:GetSpecialValueFor("duration")
    local search_radius = self:GetSpecialValueFor("search_radius")
    local attack_range  = self:GetSpecialValueFor("attack_range")
    local order_iv      = self:GetSpecialValueFor("order_interval")
    local think_iv      = self:GetSpecialValueFor("think_interval")

    local incoming = self:GetSpecialValueFor("illusion_incoming_damage")
    local outgoing = self:GetSpecialValueFor("illusion_outgoing_damage")

    local chosen_targets = self:Leon_FindInitialTargets(caster, search_radius, count)

    local origin = caster:GetAbsOrigin()
    local illusions = OvervodkaCreateIllusions(caster, caster, {duration = duration, outgoing_damage = outgoing - 100, incoming_damage = incoming - 100}, count, 0, false, false)
    
    if not illusions then return end
    caster:EmitSound("Leon.Clones.Spawn")
    for i = 1, #illusions do
        local illu = illusions[i]
        if illu and not illu:IsNull() then
            illu:SetControllableByPlayer(caster:GetPlayerID(), false)
            illu:SetOwner(caster)
            FindClearSpaceForUnit(illu, origin + RandomVector(150), false)

            illu:AddNewModifier(caster, self, "modifier_leon_w_uncontrolled", { duration = duration })

            local tgt = chosen_targets[i]
            local tgt_eidx = (tgt and not tgt:IsNull()) and tgt:entindex() or -1

            illu:AddNewModifier(caster, self, "modifier_leon_w_illusion_ai", {
                duration      = duration,
                target_eidx   = tgt_eidx,
                search_radius = search_radius,
                attack_range  = attack_range,
                order_iv      = order_iv,
                think_iv      = think_iv,
            })
        end
    end
end

function leon_w:Leon_FindInitialTargets(caster, search_radius, count)
    if not caster or caster:IsNull() then return {} end

    local origin = caster:GetAbsOrigin()

    local heroes = FindUnitsInRadius(
        caster:GetTeamNumber(),
        origin,
        nil,
        search_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_CLOSEST,
        false
    )

    local result = {}

    if heroes and #heroes > 0 then
        result[1] = heroes[1]
        if count >= 2 then
            result[2] = heroes[2] or heroes[1]
        end
        return result
    end
    return result
end


modifier_leon_w_uncontrolled = class({})

function modifier_leon_w_uncontrolled:IsHidden() return true end
function modifier_leon_w_uncontrolled:IsPurgable() return false end

function modifier_leon_w_uncontrolled:CheckState()
    return {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
    }
end

modifier_leon_w_illusion_ai = class({})

function modifier_leon_w_illusion_ai:IsHidden() return true end
function modifier_leon_w_illusion_ai:IsPurgable() return false end

function modifier_leon_w_illusion_ai:OnCreated(kv)
    if not IsServer() then return end

    self.search_radius = tonumber(kv.search_radius) or 4000
    self.attack_range  = tonumber(kv.attack_range) or 300
    self.order_iv      = tonumber(kv.order_iv) or 0.25
    self.think_iv      = tonumber(kv.think_iv) or 0.10

    self.target_eidx = tonumber(kv.target_eidx) or -1

    self._nextOrderTime = 0
    self._lockUntil = 0
    self._castToken = 0
    self._lastMovePos = nil

    local parent = self:GetParent()
    if parent and not parent:IsNull() then
        self._q = parent:FindAbilityByName("leon_q")
        if self._q and not self._q:IsNull() and self._q:GetLevel() <= 0 then
            local caster = self:GetCaster()
            if caster and not caster:IsNull() then
                local cq = caster:FindAbilityByName("leon_q")
                if cq and not cq:IsNull() then
                    self._q:SetLevel(cq:GetLevel())
                end
            end
        end
    end

    self:StartIntervalThink(self.think_iv)
end

local function LeonW_IsValidTarget(t)
    return t ~= nil and not t:IsNull() and t:IsAlive()
end

local function LeonW_CanAttackVisible(attacker, target)
    if not attacker or attacker:IsNull() then return false end
    if not target or target:IsNull() then return false end

    if attacker.CanEntityBeSeenByMyTeam then
        local ok, seen = pcall(function()
            return attacker:CanEntityBeSeenByMyTeam(target)
        end)
        if ok then
            return seen == true
        end
    end

    return true
end

function modifier_leon_w_illusion_ai:FindBestTarget()
    local parent = self:GetParent()
    local caster = self:GetCaster()
    if not parent or parent:IsNull() then return nil end
    if not caster or caster:IsNull() then return nil end

    local origin = parent:GetAbsOrigin()

    local heroes = FindUnitsInRadius(
        caster:GetTeamNumber(),
        origin,
        nil,
        self.search_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_CLOSEST,
        false
    )
    if heroes and #heroes > 0 then
        return heroes[1]
    end

    local creeps = FindUnitsInRadius(
        caster:GetTeamNumber(),
        origin,
        nil,
        self.search_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_OTHER,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_CLOSEST,
        false
    )
    if creeps and #creeps > 0 then
        return creeps[1]
    end

    return nil
end

function modifier_leon_w_illusion_ai:GetCurrentTarget()
    if not self.target_eidx or self.target_eidx <= 0 then return nil end
    local t = EntIndexToHScript(self.target_eidx)
    if not LeonW_IsValidTarget(t) then return nil end
    return t
end

function modifier_leon_w_illusion_ai:SetCurrentTarget(t)
    if t and not t:IsNull() then
        self.target_eidx = t:entindex()
    else
        self.target_eidx = -1
    end
end

function modifier_leon_w_illusion_ai:IssueOrder_MoveTo(pos)
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    if self._lastMovePos then
        local d = (Vector(pos.x, pos.y, 0) - self._lastMovePos):Length2D()
        if d < 60 then
            return
        end
    end

    self._lastMovePos = Vector(pos.x, pos.y, 0)
    parent:MoveToPosition(pos)
end

function modifier_leon_w_illusion_ai:_CanCastQ(parent, q)
    if not parent or parent:IsNull() then return false end
    if not q or q:IsNull() then return false end
    if q:GetLevel() <= 0 then return false end
    if q:IsHidden() or (not q:IsActivated()) then return false end

    if parent:IsStunned() or parent:IsHexed() or parent:IsSilenced() then
        return false
    end

    if q.GetCurrentAbilityCharges and q:GetCurrentAbilityCharges() <= 0 then
        return false
    end

    if not q:IsCooldownReady() then
        return false
    end

    return true
end

function modifier_leon_w_illusion_ai:_StartCastQ(target)
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return false end
    if not LeonW_IsValidTarget(target) then return false end

    local q = self._q
    if not q or q:IsNull() then
        q = parent:FindAbilityByName("leon_q")
        self._q = q
    end
    if not q or q:IsNull() then return false end
    if not self:_CanCastQ(parent, q) then return false end

    local pos = target:GetAbsOrigin()
    pos.z = 0

    local cast_point = 0.05
    if q.GetCastPoint then
        local cp = q:GetCastPoint()
        if cp and cp > 0 then cast_point = cp end
    end

    local now = GameRules:GetGameTime()

    self._lockUntil = now + cast_point + 0.03
    self._nextOrderTime = self._lockUntil

    self._castToken = (self._castToken or 0) + 1
    local token = self._castToken

    parent:Stop()
    parent:FaceTowards(pos)

    parent:StartGesture(ACT_DOTA_ATTACK)

    Timers:CreateTimer(cast_point, function()
        if not self or self:IsNull() then return end
        if token ~= self._castToken then return end
        if not parent or parent:IsNull() or (not parent:IsAlive()) then return end

        local t = target
        if not LeonW_IsValidTarget(t) then return end

        local myPos = parent:GetAbsOrigin()
        local tPos  = t:GetAbsOrigin()
        local dist = (tPos - myPos):Length2D()

        if dist > (self.attack_range + 120) then return end

        if not LeonW_CanAttackVisible(parent, t) then return end
        if not self:_CanCastQ(parent, q) then return end

        if q.FireAttack then
            q:FireAttack(tPos, true)
        else
            parent:CastAbilityOnPosition(tPos, q, -1)
        end
    end)

    return true
end

function modifier_leon_w_illusion_ai:IssueOrder_Attack(target)
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end
    parent:SetForceAttackTarget(target)
end


function modifier_leon_w_illusion_ai:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end
    if not parent:IsAlive() then
        self:Destroy()
        return
    end

    local now = GameRules:GetGameTime()

    if now < (self._lockUntil or 0) then
        return
    end

    if now < (self._nextOrderTime or 0) then return end
    self._nextOrderTime = now + self.order_iv

    local target = self:GetCurrentTarget()
    if not LeonW_IsValidTarget(target) then
        target = self:FindBestTarget()
        self:SetCurrentTarget(target)
    end

    if not LeonW_IsValidTarget(target) then
        parent:Stop()
        return
    end

    local myPos = parent:GetAbsOrigin()
    local tPos  = target:GetAbsOrigin()
    local dist = (tPos - myPos):Length2D()

    if dist <= self.attack_range and LeonW_CanAttackVisible(parent, target) then
        if parent:GetUnitName() ~= "npc_dota_hero_hoodwink" then
            parent:MoveToTargetToAttack(target)
        else
            if self:_StartCastQ(target) then
                return
            end
            self:IssueOrder_MoveTo(tPos)
        end
    else
        self:IssueOrder_MoveTo(tPos)
    end
end

function modifier_leon_w_illusion_ai:OnDestroy()
    if not IsServer() then return end
    self._castToken = (self._castToken or 0) + 1

    local parent = self:GetParent()
    if parent and not parent:IsNull() then
        parent:FadeGesture(ACT_DOTA_ATTACK)
    end
end