mazellov_q = class({})
LinkLuaModifier("modifier_factory", "heroes/mazellov/mazellov_q.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_worker_ai", "heroes/mazellov/mazellov_q.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_worker_disarmed", "heroes/mazellov/mazellov_q.lua", LUA_MODIFIER_MOTION_NONE)

function mazellov_q:OnAbilityPhaseStart()
    if not IsServer() then return true end

    local point = self:GetCursorPosition()
    local caster = self:GetCaster()

    -- Создаем партикл
    self.precast_particle = ParticleManager:CreateParticle(
        "particles/techies_minefield_hammer_new.vpcf",
        PATTACH_WORLDORIGIN,
        nil
    )
    ParticleManager:SetParticleControl(self.precast_particle, 0, point)
    ParticleManager:SetParticleControl(self.precast_particle, 1, point)
    ParticleManager:SetParticleControl(self.precast_particle, 2, point)

    self.precast_point = point -- сохраняем позицию, если пригодится

    return true
end

--------------------------------------------------------------------------------
-- Если каст был прерван
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

    -- Удаляем предварительный партикл, если он ещё остался
    if self.precast_particle then
        ParticleManager:DestroyParticle(self.precast_particle, false)
        ParticleManager:ReleaseParticleIndex(self.precast_particle)
        self.precast_particle = nil
    end

    local factory = CreateUnitByName("npc_factory", point, true, caster, caster, caster:GetTeam())
    factory:SetControllableByPlayer(caster:GetPlayerID(), true)
    factory:SetOwner(caster)

    -- Добавляем партиклы на аттачменты
    self:AttachParticlesToFactory(factory)

    factory:AddNewModifier(caster, self, "modifier_factory", {})
    factory:AddNewModifier(caster, nil, "modifier_kill", {duration = duration})
end

-- Новая функция для добавления партиклов
function mazellov_q:AttachParticlesToFactory(factory)
    local particle_name = "models/heroes/dawnbreaker/debut/particles/battlemaiden_debut_intro_burst_smoke_vertical.vpcf"
    
    -- Список аттачментов
    local attachments = {
        "particle1",
        "particle2",
        "particle3"
    }
    
    -- Создаем партиклы на каждом аттачменте
    for _, attach_point in pairs(attachments) do
        local attach_id = factory:ScriptLookupAttachment(attach_point)
        if attach_id ~= 0 then  -- Проверяем, что аттачмент существует
            local particle = ParticleManager:CreateParticle(particle_name, PATTACH_POINT_FOLLOW, factory)
            ParticleManager:SetParticleControlEnt(particle, 0, factory, PATTACH_POINT_FOLLOW, attach_point, factory:GetAbsOrigin(), true)
            factory.particle_effects = factory.particle_effects or {}
            table.insert(factory.particle_effects, particle)
        end
    end
end

---------------------------------------------------------------------------------------------------

modifier_factory = class({})

function modifier_factory:IsHidden() return true end
function modifier_factory:IsPurgable() return false end

function modifier_factory:OnCreated()
    if not IsServer() then return end

    self.hits_to_destroy = self:GetAbility():GetSpecialValueFor("factory_hit_count")
    self.interval = self:GetAbility():GetSpecialValueFor("worker_spawn_interval")
    self.radius = 1200

    self:SetStackCount(self.hits_to_destroy)
    self:StartIntervalThink(self.interval)

    -- Звук появления завода
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

    -- Параметры из KV
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
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_AVOID_DAMAGE,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS, -- добавляем поддержку пипсов
    }
end

function modifier_factory:GetModifierHealthBarPips(params)
    return self:GetStackCount() -- количество пипсов = оставшиеся удары
end

function modifier_factory:GetModifierIncomingDamage_Percentage()
    return -100
end

function modifier_factory:GetModifierAvoidDamage(params)
    if not IsServer() then return 0 end

    local new_count = self:GetStackCount() - 1
    self:SetStackCount(new_count)

    if new_count <= 0 then
        self:GetParent():Kill(nil, params.attacker or self:GetCaster())
    end

    return 1 -- полностью избегаем урон, но считаем как удар
end

function modifier_factory:OnDestroy()
    if not IsServer() then return end

    StopSoundOn("mazellov_q_start", self:GetParent())
    
    -- Уничтожаем все партиклы при удалении завода
    local factory = self:GetParent()
    if factory.particle_effects then
        for _, particle in pairs(factory.particle_effects) do
            ParticleManager:DestroyParticle(particle, false)
            ParticleManager:ReleaseParticleIndex(particle)
        end
    end
end

---------------------------------------------------------------------------------------------------

modifier_worker_ai = class({})

function modifier_worker_ai:IsHidden() return true end
function modifier_worker_ai:IsPurgable() return false end

function modifier_worker_ai:OnCreated()
    if not IsServer() then return end

    local ability = self:GetAbility()
    self.explode_radius = ability:GetSpecialValueFor("explode_radius")
    self.explode_damage = ability:GetSpecialValueFor("explode_damage")
    self.explode_delay = ability:GetSpecialValueFor("explode_delay")
    self:StartIntervalThink(0.2)
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
            self:StartIntervalThink(-1)  -- остановка периодического поиска

            -- не останавливаем юнита, он продолжает двигаться к цели

            Timers:CreateTimer(self.explode_delay, function()
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
    local damage = self.explode_damage

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
        ApplyDamage({
            victim = enemy,
            attacker = unit,
            ability = ability,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL
        })
    end

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_suicide_base.vpcf", PATTACH_ABSORIGIN, unit)
    ParticleManager:ReleaseParticleIndex(particle)

    EmitSoundOn("Hero_Techies.Suicide", unit)

    unit:AddNoDraw()
    unit:RemoveSelf()
end


function modifier_worker_ai:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_worker_ai:OnDeath(params)
    if not IsServer() then return end

    local unit = self:GetParent()

    if params.unit == unit and not self.exploding then
        self.exploding = true  -- флаг, чтобы не взрывался дважды
        self:Explode(nil)
    end
end


modifier_worker_disarmed = class({})

function modifier_worker_disarmed:IsHidden() return true end
function modifier_worker_disarmed:IsPurgable() return false end

function modifier_worker_disarmed:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true,
    }
end



