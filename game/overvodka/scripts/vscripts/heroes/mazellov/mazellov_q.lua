mazellov_q = class({})
LinkLuaModifier("modifier_factory", "heroes/mazellov/mazellov_q.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_worker_ai", "heroes/mazellov/mazellov_q.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_worker_disarmed", "heroes/mazellov/mazellov_q.lua", LUA_MODIFIER_MOTION_NONE)

function mazellov_q:OnAbilityPhaseStart()
    if not IsServer() then return true end

    local point = self:GetCursorPosition()
    local caster = self:GetCaster()

    self.precast_particle = ParticleManager:CreateParticle(
        "particles/techies_minefield_hammer_new.vpcf",
        PATTACH_WORLDORIGIN,
        nil
    )
    ParticleManager:SetParticleControl(self.precast_particle, 0, point)
    ParticleManager:SetParticleControl(self.precast_particle, 1, point)
    ParticleManager:SetParticleControl(self.precast_particle, 2, point)

    self.precast_point = point

    return true
end

function mazellov_q:OnAbilityPhaseInterrupted()
    if not IsServer() then return end

    if self.precast_particle then
        ParticleManager:DestroyParticle(self.precast_particle, false)
        ParticleManager:ReleaseParticleIndex(self.precast_particle)
        self.precast_particle = nil
    end
end

function mazellov_q:OnSpellStart()
    local point = self:GetCursorPosition()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("factory_lifetime")

    if self.precast_particle then
        ParticleManager:DestroyParticle(self.precast_particle, false)
        ParticleManager:ReleaseParticleIndex(self.precast_particle)
        self.precast_particle = nil
    end

    local factory = CreateUnitByName("npc_factory", point, true, caster, caster, caster:GetTeam())
    factory:SetControllableByPlayer(caster:GetPlayerID(), true)
    factory:SetOwner(caster)

    self:AttachParticlesToFactory(factory)

    factory:AddNewModifier(caster, self, "modifier_factory", {})
    factory:AddNewModifier(caster, nil, "modifier_kill", {duration = duration})
end

function mazellov_q:AttachParticlesToFactory(factory)
    local particle_name = "models/heroes/dawnbreaker/debut/particles/battlemaiden_debut_intro_burst_smoke_vertical.vpcf"
    
    local attachments = {
        "particle1",
        "particle2",
        "particle3"
    }
    
    for _, attach_point in pairs(attachments) do
        local attach_id = factory:ScriptLookupAttachment(attach_point)
        if attach_id ~= 0 then
            local particle = ParticleManager:CreateParticle(particle_name, PATTACH_POINT_FOLLOW, factory)
            ParticleManager:SetParticleControlEnt(particle, 0, factory, PATTACH_POINT_FOLLOW, attach_point, factory:GetAbsOrigin(), true)
            factory.particle_effects = factory.particle_effects or {}
            table.insert(factory.particle_effects, particle)
        end
    end
end


modifier_factory = class({})

function modifier_factory:IsHidden() return true end
function modifier_factory:IsPurgable() return false end

function modifier_factory:OnCreated()
    if not IsServer() then return end

    self.hits_to_destroy = self:GetAbility():GetSpecialValueFor("factory_hit_count")
    self.interval = self:GetAbility():GetSpecialValueFor("worker_spawn_interval")
    local gold = self:GetAbility():GetSpecialValueFor("gold_bounty")
    local xp = self:GetAbility():GetSpecialValueFor("xp_bounty")
    self.radius = 1200
    self:GetParent():SetMaxHealth(self.hits_to_destroy)
    self:GetParent():SetBaseMaxHealth(self.hits_to_destroy)
    self:GetParent():SetHealth(self.hits_to_destroy)
    self:GetParent():SetMaximumGoldBounty(gold)
    self:GetParent():SetMinimumGoldBounty(gold)
    self:GetParent():SetDeathXP(xp)
    self:StartIntervalThink(self.interval)

    EmitSoundOn("mazellov_q_start", self:GetParent())
end


function modifier_factory:OnIntervalThink()
    local parent = self:GetParent()
    local caster = self:GetCaster()
    local ability = self:GetAbility()

    local attachment_index = parent:ScriptLookupAttachment("spawn_worker")
    local spawn_pos = parent:GetAttachmentOrigin(attachment_index)

    local worker = CreateUnitByName("npc_worker", spawn_pos, true, caster, nil, caster:GetTeamNumber())
    worker:AddNewModifier(caster, ability, "modifier_worker_ai", {})
    worker:AddNewModifier(caster, ability, "modifier_worker_disarmed", {})
    worker:AddNewModifier(caster, ability, "modifier_kill", {duration = 20})

    local hp = ability:GetSpecialValueFor("worker_hp")
    local armor = ability:GetSpecialValueFor("worker_armor")
    local magres = ability:GetSpecialValueFor("worker_magres")
    local movespeed = ability:GetSpecialValueFor("worker_movespeed")

    worker:SetMaxHealth(hp)
    worker:SetBaseMaxHealth(hp)
    worker:SetHealth(hp)
    worker:SetPhysicalArmorBaseValue(armor)
    worker:SetBaseMagicalResistanceValue(magres)
    worker:SetBaseMoveSpeed(movespeed)
end


function modifier_factory:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_DISABLE_HEALING,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS, 
    }
end

function modifier_factory:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end

function modifier_factory:OnAttackLanded(keys)
    if not IsServer() then return end
    if keys.target == self:GetParent() then
        if keys.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() then
            if self:GetParent():GetHealthPercent() > 50 then
                self:GetParent():SetHealth(self:GetParent():GetHealth() - 10)
            else 
                self:GetParent():Kill(nil, keys.attacker)
            end
            return
        end
        local new_health = self:GetParent():GetHealth() - 1
        new_health = math.floor(new_health)
        if new_health <= 0 then
            self:GetParent():Kill(nil, keys.attacker)
        else
            self:GetParent():SetHealth(new_health)
        end
    end
end

function modifier_factory:GetModifierHealthBarPips(params)
    return self:GetParent():GetMaxHealth()
end

function modifier_factory:GetDisableHealing()
    return 1
end

function modifier_factory:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_factory:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_factory:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_factory:OnDestroy()
    if not IsServer() then return end

    StopSoundOn("mazellov_q_start", self:GetParent())

    local factory = self:GetParent()
    if factory.particle_effects then
        for _, particle in pairs(factory.particle_effects) do
            ParticleManager:DestroyParticle(particle, false)
            ParticleManager:ReleaseParticleIndex(particle)
        end
    end
end

modifier_worker_ai = class({})

function modifier_worker_ai:IsHidden() return true end
function modifier_worker_ai:IsPurgable() return false end

function modifier_worker_ai:OnCreated(params)
    if not IsServer() then return end

    local ability = self:GetAbility()
    
    self.explode_radius = params.explode_radius or ability:GetSpecialValueFor("explode_radius")
    self.explode_damage = params.explode_damage or ability:GetSpecialValueFor("explode_damage")
    self.explode_delay = ability:GetSpecialValueFor("explode_delay")
    self.is_respawned = params.is_respawned or false
    
    self:StartIntervalThink(0.03)
end

function modifier_worker_ai:OnDestroy()
    if not IsServer() then return end

    local unit = self:GetParent()
    if not unit:IsNull() and not unit:IsAlive() and not self.exploding then
        self:Explode(nil)
    end
end

function modifier_worker_ai:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_worker_ai:OnTakeDamage(params)
    if not IsServer() then return end

    local unit = self:GetParent()
    if params.unit ~= unit then return end

    if unit:GetHealth() <= 0 and not self.exploding then
        self:Explode(params.attacker)
    end
end

function modifier_worker_ai:OnDeath(params)
    if not IsServer() then return end

    local unit = self:GetParent()
    if unit:IsNull() or params.unit ~= unit then return end

    if self.explode_timer then
        Timers:RemoveTimer(self.explode_timer)
        self.explode_timer = nil
    end

    if self.exploding then return end

    local respawn_enabled = self:GetAbility():GetSpecialValueFor("worker_respawn_enabled") == 1
    local killer = params.attacker or unit:GetKiller()

    if respawn_enabled and killer and killer ~= unit and not self.is_respawned then
        self:RespawnWeakenedWorker(unit, killer)
    else
        self:Explode(nil)
    end
end

function modifier_worker_ai:OnIntervalThink()
    local unit = self:GetParent()

    if self.exploding then return end

    local enemies = FindUnitsInRadius(
        unit:GetTeamNumber(),
        unit:GetAbsOrigin(),
        nil,
        3000,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NO_INVIS,
        FIND_CLOSEST,
        false
    )

    if enemies[1] then
        unit:MoveToTargetToAttack(enemies[1])

        if (unit:GetAbsOrigin() - enemies[1]:GetAbsOrigin()):Length2D() <= self.explode_radius then
            self.exploding = true
            self:StartIntervalThink(-1)

            self.explode_timer = Timers:CreateTimer(self.explode_delay, function()
                if not unit:IsNull() and unit:IsAlive() then
                    self:Explode(enemies[1])
                end
            end)
        end
    end
end

function modifier_worker_ai:Explode(target)
    local unit = self:GetParent()
    local ability = self:GetAbility()
    local caster = self:GetCaster()
    local damage = self.explode_damage

    local has_talent = caster:HasTalent("special_bonus_unique_mazellov_5")
    local health_pct_damage = has_talent and 0.02 or 0

    local enemies = FindUnitsInRadius(
        unit:GetTeamNumber(),
        unit:GetAbsOrigin(),
        nil,
        self.explode_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in pairs(enemies) do
        local total_damage = damage
        if has_talent then
            total_damage = total_damage + (enemy:GetMaxHealth() * health_pct_damage)
        end

        ApplyDamage({
            victim = enemy,
            attacker = caster,
            ability = ability,
            damage = total_damage,
            damage_type = DAMAGE_TYPE_MAGICAL
        })
    end

    ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_suicide_base.vpcf", PATTACH_ABSORIGIN, unit)
    EmitSoundOn("Hero_Techies.Suicide", unit)

    unit:AddNoDraw()
    unit:RemoveSelf()
end

function modifier_worker_ai:RespawnWeakenedWorker(unit, killer)
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local spawn_pos = unit:GetAbsOrigin()
    
    local weakened_worker = CreateUnitByName("npc_worker", spawn_pos, true, caster, nil, caster:GetTeamNumber())
    
    weakened_worker:SetMaxHealth(ability:GetSpecialValueFor("worker_hp") * 0.5)
    weakened_worker:SetPhysicalArmorBaseValue(ability:GetSpecialValueFor("worker_armor") * 0.5)
    weakened_worker:SetBaseMagicalResistanceValue(ability:GetSpecialValueFor("worker_magres") * 0.5)
    weakened_worker:SetBaseMoveSpeed(ability:GetSpecialValueFor("worker_movespeed") * 0.5)
    
    weakened_worker:AddNewModifier(caster, ability, "modifier_worker_ai", {
        explode_damage = ability:GetSpecialValueFor("explode_damage") * 0.5,
        explode_radius = ability:GetSpecialValueFor("explode_radius") * 0.5,
        is_respawned = true
    })
    weakened_worker:AddNewModifier(caster, ability, "modifier_worker_disarmed", {})
    
    ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_ABSORIGIN, weakened_worker)
    
    unit:AddNoDraw()
    unit:RemoveSelf()
end

modifier_worker_disarmed = class({})

function modifier_worker_disarmed:IsHidden() return true end
function modifier_worker_disarmed:IsPurgable() return false end

function modifier_worker_disarmed:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true,
    }
end