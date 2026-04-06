LinkLuaModifier("modifier_overvodka_creep", "modifiers/modifier_overvodka_creep", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_misolo_web_spider", "heroes/misolo/misolo_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_misolo_innate", "heroes/misolo/misolo_innate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_misolo_innate_buff", "heroes/misolo/misolo_innate", LUA_MODIFIER_MOTION_NONE)

misolo_innate = class({})

modifier_misolo_innate = class({})
modifier_misolo_innate_buff = class({})

function misolo_innate:Precache(context)
    PrecacheUnitByNameSync("npc_dota_misolo_web_spider", context)
    PrecacheResource("particle", "particles/generic_gameplay/generic_lifesteal.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_broodmother/broodmother_spiderlings_spawn.vpcf", context)
end

function misolo_innate:GetIntrinsicModifierName()
    return "modifier_misolo_innate"
end

function misolo_innate:IsMisoloSpider(unit, owner)
    if not IsValid(unit, owner) or unit:GetOwner() ~= owner then
        return false
    end

    return unit:GetUnitName() == "npc_dota_misolo_web_spider" or unit:HasModifier("modifier_misolo_web_spider")
end

function misolo_innate:GetCurrentLifestealPct()
    return self:GetSpecialValueFor("lifesteal_pct")
end

function misolo_innate:SpawnSpider(position)
    local caster = self:GetCaster()
    if not IsValid(caster) then
        return
    end

    local spider = CreateUnitByName("npc_dota_misolo_web_spider", position, true, caster, caster, caster:GetTeamNumber())
    if not IsValid(spider) then
        return
    end

    spider:SetOwner(caster)
    spider:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
    FindClearSpaceForUnit(spider, position, true)

    local web_ability = caster:FindAbilityByName("misolo_w")
    local spider_health = 80
    local spider_damage = 10
    local spider_movespeed = 350
    local spider_bat = 1.5
    local spider_bounty_gold = 8
    local spider_bounty_xp = 8
    local spider_lifetime = 25

    if IsValid(web_ability) then
        local web_level = math.max(web_ability:GetLevel() - 1, 0)
        spider_health = web_ability:GetLevelSpecialValueNoOverride("spider_health", web_level)
        spider_damage = web_ability:GetLevelSpecialValueNoOverride("spider_damage", web_level)
        spider_movespeed = web_ability:GetLevelSpecialValueNoOverride("spider_movespeed", web_level)
        spider_bat = web_ability:GetLevelSpecialValueNoOverride("spider_bat", web_level)
        spider_bounty_gold = web_ability:GetLevelSpecialValueNoOverride("spider_bounty_gold", web_level)
        spider_bounty_xp = web_ability:GetLevelSpecialValueNoOverride("spider_bounty_xp", web_level)
        spider_lifetime = web_ability:GetLevelSpecialValueNoOverride("spider_lifetime", web_level)
    end

    spider:SetBaseMaxHealth(spider_health)
    spider:SetMaxHealth(spider_health)
    spider:SetHealth(spider_health)
    spider:SetBaseDamageMin(spider_damage)
    spider:SetBaseDamageMax(spider_damage)
    spider:SetBaseAttackTime(spider_bat)
    spider:SetMinimumGoldBounty(spider_bounty_gold)
    spider:SetMaximumGoldBounty(spider_bounty_gold)
    spider:SetDeathXP(spider_bounty_xp)

    if spider.SetBaseMoveSpeed then
        spider:SetBaseMoveSpeed(spider_movespeed)
    end

    spider:AddNewModifier(caster, self, "modifier_kill", { duration = spider_lifetime })
    spider:AddNewModifier(caster, self, "modifier_phased", { duration = 0.1 })
    spider:AddNewModifier(caster, self, "modifier_overvodka_creep", {})
    spider:AddNewModifier(caster, self, "modifier_misolo_web_spider", {})

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_spiderlings_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, spider)
    ParticleManager:SetParticleControl(particle, 0, spider:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        spider:GetAbsOrigin(),
        nil,
        1200,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )

    for _, enemy in ipairs(enemies) do
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

function misolo_innate:SpawnSpiders(position, count)
    for _ = 1, count do
        self:SpawnSpider(GetGroundPosition(position + RandomVector(RandomFloat(0, 80)), nil))
    end
end

function modifier_misolo_innate:IsHidden() return true end
function modifier_misolo_innate:IsPurgable() return false end
function modifier_misolo_innate:RemoveOnDeath() return false end
function modifier_misolo_innate:IsAura() return true end
function modifier_misolo_innate:IsAuraActiveOnDeath() return false end

function modifier_misolo_innate:GetAuraRadius()
    if self:GetParent():PassivesDisabled() then
        return 0
    end

    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_misolo_innate:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_misolo_innate:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_misolo_innate:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED
end

function modifier_misolo_innate:GetAuraDuration()
    return 0.2
end

function modifier_misolo_innate:GetModifierAura()
    return "modifier_misolo_innate_buff"
end

function modifier_misolo_innate:GetAuraEntityReject(target)
    local parent = self:GetParent()
    local ability = self:GetAbility()

    if not IsValid(target, parent, ability) then
        return true
    end

    if target == parent then
        return false
    end

    return not ability:IsMisoloSpider(target, parent)
end

function modifier_misolo_innate:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_misolo_innate:OnDeath(params)
    if not IsServer() then
        return
    end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    local victim = params.unit
    local attacker = params.attacker

    if not IsValid(parent, ability, victim, attacker) or parent:PassivesDisabled() then
        return
    end

    if victim:GetTeamNumber() == parent:GetTeamNumber() then
        return
    end

    if victim:IsBuilding() or victim:IsOther() or victim:IsWard() then
        return
    end

    if attacker ~= parent and not ability:IsMisoloSpider(attacker, parent) then
        return
    end

    if victim:IsRealHero() and not victim:IsIllusion() then
        ability:SpawnSpiders(victim:GetAbsOrigin(), ability:GetSpecialValueFor("hero_spawn_count"))
        return
    end

    if victim:IsCreep() then
        ability:SpawnSpiders(victim:GetAbsOrigin(), ability:GetSpecialValueFor("creep_spawn_count"))
    end
end

function modifier_misolo_innate_buff:IsHidden() return false end
function modifier_misolo_innate_buff:IsPurgable() return false end

function modifier_misolo_innate_buff:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_misolo_innate_buff:OnTakeDamage(params)
    if not IsServer() then return end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    local caster = self:GetCaster()
    if not IsValid(parent, ability, caster) or caster:PassivesDisabled() then return end
    if parent ~= params.attacker or parent == params.unit then return end

    local victim = params.unit
    if not IsValid(victim) or victim:IsBuilding() or victim:IsWard() or victim:IsOther() or params.inflictor ~= nil then return end

    local damage_flags = params.damage_flags or 0
    if bit.band(damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then return end

    local heal = params.damage * ability:GetCurrentLifestealPct() * 0.01
    if heal <= 0 then return end

    if params.unit:IsCreep() then
		heal = heal * 0.6
	end

    parent:HealWithParams(heal, ability, true, true, parent, false)

    if parent == caster then
        local effect = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:ReleaseParticleIndex(effect)
    end
end

function modifier_misolo_innate_buff:OnTooltip()
    if not IsValid(self:GetAbility()) then
        return 0
    end

    return self:GetAbility():GetCurrentLifestealPct()
end

function modifier_misolo_innate_buff:GetTexture()
    return "misolo_innate"
end
