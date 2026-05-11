modifier_chaos_meteor_thinker = class({})
modifier_chaos_meteor_burn = class({})

function modifier_chaos_meteor_thinker:IsHidden()
    return true
end

function modifier_chaos_meteor_thinker:IsPurgable()
    return false
end

function modifier_chaos_meteor_thinker:OnCreated(kv)
    if not IsServer() then return end

    local caster = self:GetCaster()
    local parent = self:GetParent()
    if not caster or caster:IsNull() or not parent or parent:IsNull() then
        self:Destroy()
        return
    end

    local dirX = tonumber(kv.dir_x) or 0
    local dirY = tonumber(kv.dir_y) or 0
    local dirZ = tonumber(kv.dir_z) or 0
    local startX = tonumber(kv.start_x) or parent:GetOrigin().x
    local startY = tonumber(kv.start_y) or parent:GetOrigin().y
    local startZ = tonumber(kv.start_z) or parent:GetOrigin().z

    self.direction = Vector(dirX, dirY, dirZ)
    self.direction.z = 0
    if self.direction:Length2D() < 0.01 then
        self.direction = RandomVector(1)
    else
        self.direction = self.direction:Normalized()
    end

    self.startOrigin = Vector(startX, startY, startZ)
    self.impactOrigin = parent:GetOrigin()
    self.travelled = 0
    self.fallen = false

    self.delay = tonumber(kv.land_time) or 1.3
    self.radius = tonumber(kv.radius) or 275
    self.distance = tonumber(kv.distance) or 700
    self.speed = tonumber(kv.speed) or 650
    self.vision = tonumber(kv.vision) or 200
    self.visionDuration = tonumber(kv.vision_duration) or 3
    self.interval = tonumber(kv.interval) or 0.5
    self.burnDuration = tonumber(kv.burn_duration) or 3
    self.impactDamagePct = tonumber(kv.impact_damage_pct) or 30
    self.burnDamagePct = tonumber(kv.burn_damage_pct) or 8

    parent:SetDayTimeVisionRange(self.vision)
    parent:SetNightTimeVisionRange(self.vision)

    self:StartIntervalThink(self.delay)
    self:PlayEffects1()
end

function modifier_chaos_meteor_thinker:OnDestroy()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    if caster and not caster:IsNull() then
        AddFOWViewer(caster:GetTeamNumber(), parent:GetOrigin(), self.vision or 200, self.visionDuration or 3, false)
        StopSoundOn("Hero_Invoker.ChaosMeteor.Loop", parent)
        EmitSoundOnLocationWithCaster(parent:GetOrigin(), "Hero_Invoker.ChaosMeteor.Destroy", caster)
    end
end

function modifier_chaos_meteor_thinker:OnIntervalThink()
    if not self.fallen then
        self.fallen = true
        self:StartIntervalThink(self.interval)
        self:Burn()
        self:PlayEffects2()
        return
    end

    self:MoveAndBurn()
end

function modifier_chaos_meteor_thinker:Burn()
    local caster = self:GetCaster()
    local parent = self:GetParent()
    if not caster or caster:IsNull() or not parent or parent:IsNull() then return end

    local units = FindUnitsInRadius(
        caster:GetTeamNumber(),
        parent:GetOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    local damage_table = {
        attacker = caster,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = nil,
    }
    local burn_kv = {
        duration = self.burnDuration,
        burn_damage_pct = self.burnDamagePct,
        tick_interval = 1,
    }

    for _, unit in ipairs(units) do
        if unit and not unit:IsNull() and not unit:IsInvulnerable() and not unit:IsOutOfGame() then
            damage_table.victim = unit
            damage_table.damage = self:GetDamageFromMaxHealth(unit, self.impactDamagePct)
            ApplyDamage(damage_table)

            unit:AddNewModifier(caster, nil, "modifier_chaos_meteor_burn", burn_kv)
        end
    end
end

function modifier_chaos_meteor_thinker:MoveAndBurn()
    local parent = self:GetParent()
    if not parent or parent:IsNull() then
        self:Destroy()
        return
    end

    local delta = self.direction * self.speed * self.interval
    parent:SetOrigin(parent:GetOrigin() + delta)
    self.travelled = self.travelled + delta:Length2D()

    self:Burn()

    if self.travelled >= self.distance then
        self:Destroy()
    end
end

function modifier_chaos_meteor_thinker:PlayEffects1()
    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local effect = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf",
        PATTACH_WORLDORIGIN,
        nil
    )
    ParticleManager:SetParticleControl(effect, 0, self.startOrigin + Vector(0, 0, 1000))
    ParticleManager:SetParticleControl(effect, 1, self.impactOrigin)
    ParticleManager:SetParticleControl(effect, 2, Vector(self.delay, 0, 0))
    ParticleManager:ReleaseParticleIndex(effect)

    EmitSoundOnLocationWithCaster(self.startOrigin, "Hero_Invoker.ChaosMeteor.Cast", caster)
end

function modifier_chaos_meteor_thinker:PlayEffects2()
    local caster = self:GetCaster()
    local parent = self:GetParent()
    if not caster or caster:IsNull() or not parent or parent:IsNull() then return end

    local effect = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf",
        PATTACH_WORLDORIGIN,
        nil
    )
    ParticleManager:SetParticleControl(effect, 0, self.impactOrigin)
    ParticleManager:SetParticleControlForward(effect, 0, self.direction)
    ParticleManager:SetParticleControl(effect, 1, self.direction * self.speed)

    self:AddParticle(effect, false, false, -1, false, false)

    EmitSoundOnLocationWithCaster(self.impactOrigin, "Hero_Invoker.ChaosMeteor.Impact", caster)
    EmitSoundOn("Hero_Invoker.ChaosMeteor.Loop", parent)
end

function modifier_chaos_meteor_thinker:GetDamageFromMaxHealth(unit, pct)
    if not unit or unit:IsNull() then
        return 0
    end

    local maxHealth = unit:GetMaxHealth() or 0
    if maxHealth <= 0 or pct <= 0 then
        return 0
    end

    return math.max(1, math.floor(maxHealth * pct * 0.01 + 0.5))
end

function modifier_chaos_meteor_burn:IsHidden()
    return false
end

function modifier_chaos_meteor_burn:IsDebuff()
    return true
end

function modifier_chaos_meteor_burn:IsPurgable()
    return true
end

function modifier_chaos_meteor_burn:GetTexture()
    return "invoker_chaos_meteor"
end

function modifier_chaos_meteor_burn:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_chaos_meteor_burn:OnCreated(kv)
    if not IsServer() then return end

    self.burnDamagePct = tonumber(kv.burn_damage_pct) or 10
    self.tickInterval = tonumber(kv.tick_interval) or 1

    self:StartIntervalThink(self.tickInterval)
end

function modifier_chaos_meteor_burn:OnIntervalThink()
    local parent = self:GetParent()
    local caster = self:GetCaster()
    if not parent or parent:IsNull() or not caster or caster:IsNull() then
        return
    end

    local maxHealth = parent:GetMaxHealth() or 0
    local damage = math.max(1, math.floor(maxHealth * self.burnDamagePct * 0.01 + 0.5))
    self.damageTable = self.damageTable or {
        attacker = caster,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = nil,
    }
    self.damageTable.victim = parent
    self.damageTable.attacker = caster
    self.damageTable.damage = damage
    ApplyDamage(self.damageTable)
    EmitSoundOn("Hero_Invoker.ChaosMeteor.Damage", self:GetParent())
end

function modifier_chaos_meteor_burn:GetEffectName()
    return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
end

function modifier_chaos_meteor_burn:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
