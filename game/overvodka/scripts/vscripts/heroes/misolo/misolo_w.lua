LinkLuaModifier("modifier_overvodka_creep", "modifiers/modifier_overvodka_creep", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_misolo_w_handler", "heroes/misolo/misolo_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_misolo_w_web", "heroes/misolo/misolo_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_misolo_w_buff", "heroes/misolo/misolo_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_misolo_web_spider", "heroes/misolo/misolo_w", LUA_MODIFIER_MOTION_NONE)

misolo_w = class({})
misolo_web_destroy = class({})

modifier_misolo_w_handler = class({})
modifier_misolo_w_web = class({})
modifier_misolo_w_buff = class({})
modifier_misolo_web_spider = class({})

function misolo_w:Precache(context)
    PrecacheUnitByNameSync("npc_dota_misolo_web", context)
    PrecacheUnitByNameSync("npc_dota_misolo_web_spider", context)
    PrecacheResource("particle", "particles/units/heroes/hero_broodmother/broodmother_web.vpcf", context)
    PrecacheResource("particle", "particles/items_fx/necronomicon_spawn.vpcf", context)
end

function misolo_w:GetAOERadius()
    return self:GetSpecialValueFor("web_radius")
end

function misolo_w:GetIntrinsicModifierName()
    return "modifier_misolo_w_handler"
end

function misolo_w:PruneWebs()
    local caster = self:GetCaster()
    if not IsValid(caster) then
        return {}
    end

    caster._misolo_webs = caster._misolo_webs or {}

    for i = #caster._misolo_webs, 1, -1 do
        local web = caster._misolo_webs[i]
        if not IsValid(web) or web._misolo_removed then
            table.remove(caster._misolo_webs, i)
        end
    end

    return caster._misolo_webs
end

function misolo_w:RemoveWeb(web, skip_list_update)
    if not IsServer() or not IsValid(web) or web._misolo_removed then
        return
    end

    web._misolo_removed = true

    local owner = web:GetOwner()
    if not skip_list_update and IsValid(owner) and owner._misolo_webs then
        for i = #owner._misolo_webs, 1, -1 do
            if owner._misolo_webs[i] == web or not IsValid(owner._misolo_webs[i]) or owner._misolo_webs[i]._misolo_removed then
                table.remove(owner._misolo_webs, i)
            end
        end
    end

    local modifier = web:FindModifierByName("modifier_misolo_w_web")
    if IsValid(modifier) then
        modifier:Destroy()
        return
    end

    UTIL_Remove(web)
end

function misolo_w:RemoveAllWebs()
    if not IsServer() then
        return
    end

    local caster = self:GetCaster()
    if not IsValid(caster) then
        return
    end

    local webs = self:PruneWebs()
    caster._misolo_webs = {}

    for _, web in ipairs(webs) do
        self:RemoveWeb(web, true)
    end
end

function misolo_w:IsMisoloSpider(target, owner)
    if not IsValid(target, owner) or target:GetOwner() ~= owner then
        return false
    end

    return target:GetUnitName() == "npc_dota_misolo_web_spider" or target:HasModifier("modifier_misolo_web_spider")
end

function misolo_w:OnSpellStart()
    if not IsServer() then
        return
    end

    local caster = self:GetCaster()
    if not IsValid(caster) then
        return
    end

    local point = GetGroundPosition(self:GetCursorPosition(), nil)
    local web = CreateUnitByName("npc_dota_misolo_web", point, true, caster, caster, caster:GetTeamNumber())
    if not IsValid(web) then
        return
    end

    caster._misolo_webs = caster._misolo_webs or {}
    caster._misolo_web_sequence = (caster._misolo_web_sequence or 0) + 1

    web:SetOwner(caster)
    web:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
    web:SetForwardVector(caster:GetForwardVector())
    web._misolo_creation_order = caster._misolo_web_sequence
    web.spawn_time = GameRules:GetDOTATime(false, false)

    FindClearSpaceForUnit(web, point, true)

    local destroy_ability = web:FindAbilityByName("misolo_web_destroy")
    if destroy_ability and not destroy_ability:IsTrained() then
        destroy_ability:SetLevel(1)
    end

    web:AddNewModifier(caster, self, "modifier_misolo_w_web", {})

    local particle = ParticleManager:CreateParticle("particles/items_fx/necronomicon_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, web)
    ParticleManager:SetParticleControl(particle, 0, web:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)

    EmitSoundOn("Hero_Broodmother.SpinWebCast", caster)

    local webs = self:PruneWebs()
    webs[#webs + 1] = web

    local max_webs = self:GetSpecialValueFor("max_webs")
    while #webs > max_webs do
        local oldest = table.remove(webs, 1)
        if IsValid(oldest) then
            self:RemoveWeb(oldest, true)
        end
    end
end

function misolo_w:OnUnStolen()
    if not IsServer() then
        return
    end

    self:RemoveAllWebs()
end

function misolo_web_destroy:Spawn()
    if not IsServer() then
        return
    end

    if self:IsTrained() then
        return
    end

    self:SetLevel(1)
end

function misolo_web_destroy:IsStealable() return false end
function misolo_web_destroy:ProcsMagicStick() return false end

function misolo_web_destroy:OnSpellStart()
    if not IsServer() then
        return
    end

    local web = self:GetCaster()
    if not IsValid(web) or web._misolo_removed then
        return
    end

    local owner = web:GetOwner()
    if IsValid(owner) then
        if owner._misolo_webs then
            for i = #owner._misolo_webs, 1, -1 do
                if owner._misolo_webs[i] == web or not IsValid(owner._misolo_webs[i]) or owner._misolo_webs[i]._misolo_removed then
                    table.remove(owner._misolo_webs, i)
                end
            end
        end

        local ability = owner:FindAbilityByName("misolo_w")
        if IsValid(ability) then
            ability:RemoveWeb(web, true)
            return
        end
    end

    web._misolo_removed = true
    UTIL_Remove(web)
end

function modifier_misolo_w_handler:IsHidden() return true end
function modifier_misolo_w_handler:IsPurgable() return false end
function modifier_misolo_w_handler:RemoveOnDeath() return false end

function modifier_misolo_w_handler:OnCreated()
    if not IsServer() then
        return
    end

    self:GetParent()._misolo_webs = self:GetParent()._misolo_webs or {}
end

function modifier_misolo_w_handler:OnDestroy()
    if not IsServer() then
        return
    end

    local parent = self:GetParent()
    if not IsValid(parent) or not parent._misolo_webs then
        return
    end

    local webs = parent._misolo_webs
    parent._misolo_webs = {}

    for _, web in ipairs(webs) do
        if IsValid(web) and not web._misolo_removed then
            web._misolo_removed = true

            local modifier = web:FindModifierByName("modifier_misolo_w_web")
            if IsValid(modifier) then
                modifier:Destroy()
            else
                UTIL_Remove(web)
            end
        end
    end
end

function modifier_misolo_w_web:IsHidden() return true end
function modifier_misolo_w_web:IsPurgable() return false end
function modifier_misolo_w_web:RemoveOnDeath() return false end
function modifier_misolo_w_web:IsAura() return true end

function modifier_misolo_w_web:OnCreated()
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.radius = 0

    if IsValid(self.ability) then
        self.radius = self.ability:GetSpecialValueFor("web_radius")
    end

    if not IsServer() then return end

    if not IsValid(self.parent, self.caster, self.ability) then
        self:Destroy()
        return
    end

    self.spawn_end_time = GameRules:GetGameTime() + self.ability:GetSpecialValueFor("web_spawn_duration")
    self.spawn_interval = self.ability:GetSpecialValueFor("web_spawn_interval")
    self.spider_count_per_tick = self.ability:GetSpecialValueFor("spider_count_per_tick")
    self.spider_lifetime = self.ability:GetSpecialValueFor("spider_lifetime")

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_web.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(particle, 0, self.parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, 1, 1))
    ParticleManager:SetParticleControl(particle, 2, self.parent:GetAbsOrigin())
    self:AddParticle(particle, false, false, -1, false, false)

    Timers:CreateTimer(function()
        if not IsValid(self.parent, self.caster, self.ability) or self.parent._misolo_removed then
            return nil
        end

        if GameRules:GetGameTime() > self.spawn_end_time then
            return nil
        end

        self:TrySpawnSpiders()
        return self.spawn_interval
    end)
end

function modifier_misolo_w_web:OnDestroy()
    if not IsServer() then
        return
    end

    if IsValid(self.caster) and self.caster._misolo_webs then
        for i = #self.caster._misolo_webs, 1, -1 do
            if self.caster._misolo_webs[i] == self.parent or not IsValid(self.caster._misolo_webs[i]) or self.caster._misolo_webs[i]._misolo_removed then
                table.remove(self.caster._misolo_webs, i)
            end
        end
    end

    if IsValid(self.parent) then
        self.parent._misolo_removed = true
        UTIL_Remove(self.parent)
    end
end

function modifier_misolo_w_web:TrySpawnSpiders()
    if not IsValid(self.parent, self.caster, self.ability) then
        return
    end

    local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    if #enemies < 1 then return end

    for _ = 1, self.spider_count_per_tick do
        local spawn_pos = GetGroundPosition(self.parent:GetAbsOrigin(), nil)

        for _ = 1, 12 do
            local test_pos = GetGroundPosition(self.parent:GetAbsOrigin() + RandomVector(RandomFloat(0, math.max(0, self.radius - 96))), nil)
            if GridNav:IsTraversable(test_pos) and not GridNav:IsBlocked(test_pos) then
                spawn_pos = test_pos
                break
            end
        end

        local spider = CreateUnitByName("npc_dota_misolo_web_spider", spawn_pos, true, self.caster, self.caster, self.caster:GetTeamNumber())
        if IsValid(spider) then
            spider:SetOwner(self.caster)
            spider:SetControllableByPlayer(self.caster:GetPlayerOwnerID(), true)
            FindClearSpaceForUnit(spider, spawn_pos, true)

            local health = self.ability:GetSpecialValueFor("spider_health")
            local damage = self.ability:GetSpecialValueFor("spider_damage")
            local gold = self.ability:GetSpecialValueFor("spider_bounty_gold")

            spider:SetBaseMaxHealth(health)
            spider:SetMaxHealth(health)
            spider:SetHealth(health)
            spider:SetBaseDamageMin(damage)
            spider:SetBaseDamageMax(damage)
            spider:SetBaseAttackTime(self.ability:GetSpecialValueFor("spider_bat"))
            spider:SetMinimumGoldBounty(gold)
            spider:SetMaximumGoldBounty(gold)
            spider:SetDeathXP(self.ability:GetSpecialValueFor("spider_bounty_xp"))

            if spider.SetBaseMoveSpeed then
                spider:SetBaseMoveSpeed(self.ability:GetSpecialValueFor("spider_movespeed"))
            end

            spider:AddNewModifier(self.caster, self.ability, "modifier_kill", { duration = self.spider_lifetime })
            spider:AddNewModifier(self.caster, self.ability, "modifier_phased", {})
            spider:AddNewModifier(self.caster, self.ability, "modifier_overvodka_creep", {})
            spider:AddNewModifier(self.caster, self.ability, "modifier_misolo_web_spider", {})

            local particle = ParticleManager:CreateParticle("particles/items_fx/necronomicon_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, spider)
            ParticleManager:SetParticleControl(particle, 0, spider:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle)

            local nearby_enemies = FindUnitsInRadius(
                self.caster:GetTeamNumber(),
                spider:GetAbsOrigin(),
                nil,
                1200,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_CLOSEST,
                false
            )

            for _, enemy in ipairs(nearby_enemies) do
                if enemy:IsRealHero() and not enemy:IsIllusion() then
                    ExecuteOrderFromTable({
                        UnitIndex = spider:entindex(),
                        OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                        TargetIndex = enemy:entindex(),
                    })
                    break
                end
            end
        end
    end
end

function modifier_misolo_w_web:GetModifierAura()
    return "modifier_misolo_w_buff"
end

function modifier_misolo_w_web:GetAuraRadius()
    return self.radius
end

function modifier_misolo_w_web:GetAuraDuration()
    if IsValid(self.ability) then
        return self.ability:GetSpecialValueFor("linger_duration")
    end

    return 0.15
end

function modifier_misolo_w_web:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_misolo_w_web:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_misolo_w_web:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED
end

function modifier_misolo_w_web:GetAuraEntityReject(target)
    if not IsValid(target, self.caster) then
        return true
    end

    if target == self.parent then
        return true
    end

    if target == self.caster then
        return false
    end

    if not IsValid(self.ability) then
        return true
    end

    return not self.ability:IsMisoloSpider(target, self.caster)
end

function modifier_misolo_w_web:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_misolo_w_buff:IsHidden() return false end
function modifier_misolo_w_buff:IsPurgable() return false end

function modifier_misolo_w_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
    }
end

function modifier_misolo_w_buff:GetModifierMoveSpeedBonus_Percentage()
    if not IsValid(self:GetAbility()) then
        return 0
    end

    return self:GetAbility():GetSpecialValueFor("move_speed_bonus_pct")
end

function modifier_misolo_w_buff:GetModifierConstantHealthRegen()
    if not IsValid(self:GetAbility()) then
        return 0
    end

    return self:GetAbility():GetSpecialValueFor("health_regen_bonus")
end

function modifier_misolo_w_buff:GetModifierTurnRate_Percentage()
    if not IsValid(self:GetAbility()) then
        return 0
    end

    return self:GetAbility():GetSpecialValueFor("turn_rate_bonus") * 100
end

function modifier_misolo_w_buff:CheckState()
    return {
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_misolo_w_buff:GetTexture()
    return "misolo_w"
end

function modifier_misolo_web_spider:IsHidden() return true end
function modifier_misolo_web_spider:IsPurgable() return false end
