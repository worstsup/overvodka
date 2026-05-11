LinkLuaModifier("modifier_epstein_e_active", "heroes/epstein/epstein_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_e_damage", "heroes/epstein/epstein_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_e_dance",  "heroes/epstein/epstein_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_e_enemy",  "heroes/epstein/epstein_e", LUA_MODIFIER_MOTION_NONE)

epstein_e = class({})

function epstein_e:Precache(ctx)
    PrecacheResource("particle", "particles/epstein_dance.vpcf", ctx)
    PrecacheResource("particle", "particles/econ/events/fall_2021/radiance_owner_fall_2021.vpcf", ctx)
    PrecacheResource("particle", "particles/econ/events/fall_2021/radiance_fall_2021.vpcf", ctx)
end

function epstein_e:GetManaCost(lvl)
    local m = self:GetCaster():GetMaxMana()
    local mc = self:GetSpecialValueFor("mana_cost_per_second") * 0.01
    return math.ceil(m * mc)
end

function epstein_e:OnToggle()
    local caster = self:GetCaster()
    local toggle = self:GetToggleState()

    if toggle then
        self.modifier = caster:AddNewModifier(caster, self, "modifier_epstein_e_active", {})
        self.dance = caster:AddNewModifier(caster, self, "modifier_epstein_e_dance", {})
        self:EndCooldown()
    else
        if self.modifier and not self.modifier:IsNull() then
            self.modifier:Destroy()
        end
        self.modifier = nil
        if self.dance and not self.dance:IsNull() then
            self.dance:Destroy()
        end
        self.dance = nil
        self:UseResources(false, false, false, true)
    end
end

modifier_epstein_e_dance = class({})

function modifier_epstein_e_dance:IsHidden() return true end
function modifier_epstein_e_dance:IsPurgable() return false end
function modifier_epstein_e_dance:GetPriority() return MODIFIER_PRIORITY_ULTRA end

function modifier_epstein_e_dance:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
end

function modifier_epstein_e_dance:GetOverrideAnimation()
    return ACT_DOTA_TAUNT
end

modifier_epstein_e_active = class({})

function modifier_epstein_e_active:IsHidden() return false end
function modifier_epstein_e_active:IsDebuff() return false end
function modifier_epstein_e_active:IsPurgable() return false end

function modifier_epstein_e_active:OnCreated()
    local ability = self:GetAbility()
    if not ability then
        self:Destroy()
        return
    end

    self.move_speed_bonus_pct = ability:GetSpecialValueFor("move_speed_bonus_pct")
    self.damage_per_sec       = ability:GetSpecialValueFor("damage_per_sec")
    self.max_bonus_damage     = ability:GetSpecialValueFor("max_bonus_damage")
    self.hold_duration        = ability:GetSpecialValueFor("hold_duration")
    self.regen_pct            = ability:GetSpecialValueFor("regen_pct")
    self.manacost             = ability:GetSpecialValueFor("mana_cost_per_second")

    self.shard_radius   = ability:GetSpecialValueFor("shard_radius")
    self.shard_dps_base = ability:GetSpecialValueFor("shard_dps_base")
    self.shard_dps_gain = ability:GetSpecialValueFor("shard_dps_gain")
    self.shard_dps_decay= ability:GetSpecialValueFor("shard_dps_decay")
    self.shard_dps_cap  = ability:GetSpecialValueFor("shard_dps_cap")

    if not IsServer() then return end
    self:SetStackCount(0)
    self._acc_bonus = 1
    self._heat = 0
    self._tick = 0.33
    self:StartIntervalThink(self._tick)
    self:OnIntervalThink()

    if not self:GetParent():HasModifier("modifier_epstein_island_caster_buff") and not global_sounds_muted then
        self:GetParent():EmitSound("epstein_dance")
    end

    local p2 = ParticleManager:CreateParticle("particles/epstein_dance.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(p2, false, false, -1, false, false)

    if self:GetParent():HasShard() then
        local p = ParticleManager:CreateParticle("particles/econ/events/fall_2021/radiance_owner_fall_2021.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        self:AddParticle(p, false, false, -1, false, false)
    end
end

function modifier_epstein_e_active:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not parent or parent:IsNull() or not IsValidEntity(parent) then self:Destroy(); return end
    if not ability then self:Destroy(); return end

    local add = self.damage_per_sec or 0
    local cap = self.max_bonus_damage or 0
    local spend = self.manacost * self._tick * parent:GetMaxMana() * 0.01

    if add > 0 and cap > 0 then
        self._acc_bonus = (self._acc_bonus or 0) + self._tick
        local mana = parent:GetMana()
        if mana < spend then
            if ability:GetToggleState() then
                ability:ToggleAbility()
            end
            return
        end
        parent:SpendMana(spend, ability)
        if self._acc_bonus >= 1.0 then
            local ticks = math.floor(self._acc_bonus)
            self._acc_bonus = self._acc_bonus - ticks

            local new = (self:GetStackCount() or 0) + add * ticks
            if new > cap then new = cap end
            self:SetStackCount(new)
        end
    end

    if not parent:HasShard() then
        self._heat = 0
        return
    end

    if (self.shard_radius or 0) <= 0 then
        self._heat = 0
        return
    end

    local enemies = FindUnitsInRadius(
        parent:GetTeamNumber(), parent:GetAbsOrigin(),
        nil, self.shard_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0, FIND_ANY_ORDER, false
    )

    local has_enemy = enemies and (#enemies > 0)

    local heat = self._heat or 0
    if has_enemy then
        heat = heat + (self.shard_dps_gain or 0) * self._tick
        local heat_cap = self.shard_dps_cap or 0
        if heat_cap > 0 and heat > heat_cap then heat = heat_cap end
    else
        heat = heat - (self.shard_dps_decay or 0) * self._tick
        if heat < 0 then heat = 0 end
    end
    self._heat = heat

    if not has_enemy then return end

    local dps = (self.shard_dps_base or 0) + heat
    if dps <= 0 then return end

    local damage = dps * self._tick
    local modifier_kv = {duration = 0.4}
    local damage_table = {
        attacker = parent,
        ability = ability,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL
    }
    for _, enemy in pairs(enemies) do
        if enemy and (not enemy:IsNull()) and IsValidEntity(enemy) and enemy:IsAlive() and (not enemy:IsOutOfGame()) then
            enemy:AddNewModifier(parent, ability, "modifier_epstein_e_enemy", modifier_kv)
            damage_table.victim = enemy
            ApplyDamage(damage_table)
        end
    end
end

function modifier_epstein_e_active:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
    }
end

function modifier_epstein_e_active:GetModifierMoveSpeedBonus_Percentage()
    return self.move_speed_bonus_pct or 0
end

function modifier_epstein_e_active:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount()
end

function modifier_epstein_e_active:GetModifierHealthRegenPercentage()
    return self.regen_pct or 0
end

function modifier_epstein_e_active:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true,
    }
end

function modifier_epstein_e_active:OnDestroy()
    if not IsServer() then return end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not parent or parent:IsNull() or not IsValidEntity(parent) then return end
    if not ability then return end
    --parent:RemoveGesture(ACT_DOTA_TAUNT)
    parent:StopSound("epstein_dance")

    if not parent:IsAlive() then return end

    local stacks = self:GetStackCount()
    if stacks <= 0 then return end

    local buff = parent:AddNewModifier(parent, ability, "modifier_epstein_e_damage", { duration = self.hold_duration })
    if buff and not buff:IsNull() then
        buff:SetStackCount(stacks)
    end
end

modifier_epstein_e_damage = class({})

function modifier_epstein_e_damage:IsHidden() return false end
function modifier_epstein_e_damage:IsDebuff() return false end
function modifier_epstein_e_damage:IsPurgable() return false end

function modifier_epstein_e_damage:OnCreated()
    if not IsServer() then return end
    local p2 = ParticleManager:CreateParticle("particles/epstein_dance.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(p2, false, false, -1, false, false)
end

function modifier_epstein_e_damage:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_epstein_e_damage:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_epstein_e_damage:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount()
end

modifier_epstein_e_enemy = class({})

function modifier_epstein_e_enemy:IsHidden() return true end
function modifier_epstein_e_enemy:IsPurgable() return false end

function modifier_epstein_e_enemy:OnCreated()
    if not IsServer() then return end
    self.p = ParticleManager:CreateParticle("particles/econ/events/fall_2021/radiance_fall_2021.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.p, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
    self:AddParticle(self.p, false, false, -1, false, false)
end