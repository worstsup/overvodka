LinkLuaModifier("modifier_visitor_q_grabbed",     "heroes/pale_visitor/visitor_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_visitor_q_debuff",      "heroes/pale_visitor/visitor_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_visitor_q_caster_lock", "heroes/pale_visitor/visitor_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_visitor_q_counter",     "heroes/pale_visitor/visitor_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_visitor_q_shard",       "heroes/pale_visitor/visitor_q", LUA_MODIFIER_MOTION_NONE)

visitor_q = class({})

function visitor_q:Precache(ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_treant/treant_leech_seed_damage_pulse.vpcf", ctx)
    PrecacheResource("particle", "particles/visitor_q_root.vpcf", ctx)
    PrecacheResource("particle", "particles/visitor_q_base.vpcf", ctx)
    PrecacheResource("particle", "particles/econ/items/undying/undying_manyone/undying_pale_tombstone.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/visitor_sounds.vsndevts", ctx)
end

function visitor_q:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level)
end

function visitor_q:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function visitor_q:GetIntrinsicModifierName()
    return "modifier_visitor_q_counter"
end

function visitor_q:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if not target or target:IsNull() then return end
    if not target:IsAlive() then return end
    if target:TriggerSpellAbsorb(self) then return end
    if target:HasModifier("modifier_item_lotus_orb_active") then return end
    if not caster:HasAbility("visitor_q") then return end
    local grab_dur   = self:GetSpecialValueFor("grab_duration")

    caster:EmitSound("visitor_q")
    caster:StartGestureWithPlaybackRate(ACT_DOTA_OVERRIDE_ABILITY_1, 1.0)

    caster:AddNewModifier(caster, self, "modifier_visitor_q_caster_lock", { duration = grab_dur })

    target:AddNewModifier(caster, self, "modifier_visitor_q_grabbed", {
        duration = grab_dur,
    })

    local p = ParticleManager:CreateParticle("particles/econ/items/undying/undying_manyone/undying_pale_tombstone.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(p, 0, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(p)
end


modifier_visitor_q_counter = class({})
function modifier_visitor_q_counter:IsHidden() return self:GetStackCount() == 0 end
function modifier_visitor_q_counter:IsPurgable() return false end
function modifier_visitor_q_counter:RemoveOnDeath() return false end

function modifier_visitor_q_counter:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
    }
end

function modifier_visitor_q_counter:GetModifierPercentageManacostStacking()
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("manacost_stack")
end

function modifier_visitor_q_counter:GetModifierOverrideAbilitySpecial(params)
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return 0 end

    local ability_d = parent:FindAbilityByName("visitor_d")
    if not ability_d or ability_d:IsNull() then return 0 end
    if params.ability ~= ability_d then return 0 end

    if params.ability_special_value == "max_stacks_per_enemy" then
        return 1
    end

    return 0
end

function modifier_visitor_q_counter:GetModifierOverrideAbilitySpecialValue(params)
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    local ability_d = parent:FindAbilityByName("visitor_d")
    if not ability_d or ability_d:IsNull() then return end
    if params.ability ~= ability_d then return end
    if params.ability_special_value ~= "max_stacks_per_enemy" then return end

    local base = ability_d:GetLevelSpecialValueNoOverride("max_stacks_per_enemy", params.ability_special_level)
    local bonus_per_kill = ability_d:GetSpecialValueFor("max_stacks_kill_bonus") or 0

    return base + (self:GetStackCount() * bonus_per_kill)
end

function modifier_visitor_q_counter:OnDeath(params)

    local parent  = self:GetParent()
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return end
    if not parent or parent:IsNull() then return end
    if params.attacker ~= parent then return end

    local victim = params.unit
    if not victim or victim:IsNull() then return end
    if not victim:IsRealHero() or victim:IsIllusion() then return end

    local inflictor = params.inflictor

    local valid = false
    if inflictor == ability then
        valid = true
    else
        if victim:HasModifier("modifier_visitor_q_grabbed") then
            valid = true
        end
    end

    if not valid then return end

    self:IncrementStackCount()

    if parent:HasShard() then
        parent:AddNewModifier(parent, ability, "modifier_visitor_q_shard", {
            target = victim:entindex()
        })
    end
end

modifier_visitor_q_grabbed = class({})

function modifier_visitor_q_grabbed:IsPurgable() return false end
function modifier_visitor_q_grabbed:IsDebuff() return true end
function modifier_visitor_q_grabbed:GetEffectName() return "particles/visitor_q_root.vpcf" end
function modifier_visitor_q_grabbed:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_visitor_q_grabbed:IsStunDebuff() return true end

function modifier_visitor_q_grabbed:GetPriority()
    return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH
end

function modifier_visitor_q_grabbed:OnCreated()
    self.caster = self:GetCaster()
    self.parent = self:GetParent()

    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return end

    self.silence_dur = ability:GetSpecialValueFor("silence_duration")
    self.slow_dur    = ability:GetSpecialValueFor("slow_duration")
    self.damage      = ability:GetSpecialValueFor("damage")
    self.kill_thr    = ability:GetSpecialValueFor("kill_threshold")

    self.damage_interval = ability:GetSpecialValueFor("damage_interval")
    if self.damage_interval <= 0 then
        self.damage_interval = 0.25
    end

    self.grab_duration = ability:GetSpecialValueFor("grab_duration")
    if self.grab_duration <= 0 then
        self.grab_duration = self:GetDuration() or 1.0
    end

    self.damage_per_second = self.damage / math.max(self.grab_duration, 0.01)
    self.damage_timer = 0

    if not IsServer() then return end

    self.attach_fx = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_treant/treant_leech_seed_damage_pulse.vpcf",
        PATTACH_POINT_FOLLOW,
        self.caster
    )
    ParticleManager:SetParticleControlEnt(self.attach_fx, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true)
    ParticleManager:SetParticleControlEnt(self.attach_fx, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc",  Vector(0,0,0), true)

    self:StartIntervalThink(FrameTime())
end


function modifier_visitor_q_grabbed:OnIntervalThink()
    if not IsServer() then return end

    if not self.caster or self.caster:IsNull() or not self.caster:IsAlive() then
        self:Destroy()
        return
    end

    if not self.parent or self.parent:IsNull() or not self.parent:IsAlive() then
        self:Destroy()
        return
    end

    local dt = FrameTime()
    self.damage_timer = (self.damage_timer or 0) + dt

    while self.damage_timer >= self.damage_interval do
        self.damage_timer = self.damage_timer - self.damage_interval

        if self.parent and not self.parent:IsNull() and self.parent:IsAlive() then
            ApplyDamage({
                victim      = self.parent,
                attacker    = self.caster,
                damage      = self.damage_per_second * self.damage_interval,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                ability     = self:GetAbility()
            })
        else
            break
        end
    end

    if self.parent and not self.parent:IsNull() and self.parent:IsAlive() then
        local hp_pct = (self.parent:GetHealth() / self.parent:GetMaxHealth()) * 100
        if hp_pct <= self.kill_thr then
            self.parent:Kill(self:GetAbility(), self.caster)
            return
        end
    else
        self:Destroy()
        return
    end

    local attach = self.caster:ScriptLookupAttachment("attach_attack1")
    local pos
    if attach ~= 0 then
        pos = self.caster:GetAttachmentOrigin(attach) + self.caster:GetForwardVector() * 120
    else
        pos = self.caster:GetAbsOrigin() + self.caster:GetForwardVector() * 250
    end

    local cur = self.parent:GetAbsOrigin()
    self.parent:SetAbsOrigin(Vector(pos.x, pos.y, cur.z))
end


function modifier_visitor_q_grabbed:OnDestroy()
    if not IsServer() then return end

    if self.attach_fx then
        ParticleManager:DestroyParticle(self.attach_fx, false)
        ParticleManager:ReleaseParticleIndex(self.attach_fx)
    end

    if not self.parent or self.parent:IsNull() then return end

    local p = ParticleManager:CreateParticle("particles/visitor_q_base.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(p, 0, self.parent:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(p)

    if not self.parent:IsAlive() then return end

    if self.caster and not self.caster:IsNull() and self.caster:HasTalent("special_bonus_unique_visitor_3") then
        self.caster:PerformAttack(self.parent, true, true, false, true, false, false, true)
    end

    if not self.parent or self.parent:IsNull() then return end
    if not self.parent:IsAlive() then return end

    self.parent:AddNewModifier(self.caster, self:GetAbility(), "modifier_visitor_q_debuff", {
        duration = self.slow_dur * (1 - self.parent:GetStatusResistance()),
    })
end


function modifier_visitor_q_grabbed:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_PROVIDES_VISION] = true,
    }
end

modifier_visitor_q_shard = class({})

function modifier_visitor_q_shard:IsHidden() return false end
function modifier_visitor_q_shard:IsPurgable() return false end
function modifier_visitor_q_shard:RemoveOnDeath() return false end

function modifier_visitor_q_shard:OnCreated(kv)
    if not IsServer() then return end
    self.target = EntIndexToHScript(kv.target)
    self.caster = self:GetParent()
    if not self.target or self.target:IsNull() then
        self:Destroy()
        return
    end
    self.scale = math.floor((self.target:GetModelScale() / self.caster:GetModelScale() - 1) * 100)
    self.model = self.target:GetModelName()
    self.caster:SetRenderColor(120, 255, 160)
    self:StartIntervalThink(0.1)
end

function modifier_visitor_q_shard:OnIntervalThink()
    if not IsServer() then return end
    if not self.target or self.target:IsNull() then
        self:Destroy()
        return
    end
    if self.target:IsAlive() then
        self:Destroy()
        return
    end
end

function modifier_visitor_q_shard:OnDestroy()
    if not IsServer() then return end
    if not self.caster or self.caster:IsNull() then return end
    self.caster:SetRenderColor(255, 255, 255)
end

function modifier_visitor_q_shard:DeclareFunctions()
    return {MODIFIER_PROPERTY_MODEL_CHANGE, MODIFIER_PROPERTY_MODEL_SCALE}
end

function modifier_visitor_q_shard:GetModifierModelChange()
	return self.model
end

function modifier_visitor_q_shard:GetModifierModelScale()
    return self.scale
end

modifier_visitor_q_debuff = class({})

function modifier_visitor_q_debuff:IsDebuff() return true end
function modifier_visitor_q_debuff:IsPurgable() return true end

function modifier_visitor_q_debuff:OnCreated()
    self.slow = self:GetAbility():GetSpecialValueFor("slow_pct")
end

function modifier_visitor_q_debuff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_visitor_q_debuff:CheckState()
    return {
        [MODIFIER_STATE_SILENCED] = true,
    }
end

function modifier_visitor_q_debuff:GetEffectName()
	return "particles/generic_gameplay/generic_silenced.vpcf"
end

function modifier_visitor_q_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_visitor_q_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -self.slow
end

modifier_visitor_q_caster_lock = class({})

function modifier_visitor_q_caster_lock:IsPurgable() return false end
function modifier_visitor_q_caster_lock:IsHidden()   return true end

function modifier_visitor_q_caster_lock:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
    }
end
