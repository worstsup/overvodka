LinkLuaModifier("modifier_flash_q_facet_2", "heroes/flash/flash_q_facet_2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_flash_q_facet_2_cooldown", "heroes/flash/flash_q_facet_2", LUA_MODIFIER_MOTION_NONE)

flash_q_facet_2 = class({})

function flash_q_facet_2:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_overvodka_store_skin_6") then
        return "flash_q_facet_2_immortal"
    end
    return "flash_q_facet_2"
end

function flash_q_facet_2:Precache(context)
    PrecacheResource("particle", "particles/econ/items/weaver/weaver_immortal_ti6/weaver_immortal_ti6_shukuchi_portal.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/weaver/weaver_immortal_ti6/weaver_immortal_ti6_shukuchi_damage.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/weaver/weaver_immortal_ti6/weaver_immortal_ti6_shukuchi.vpcf", context)
end

function flash_q_facet_2:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local mod = caster:FindModifierByName("modifier_flash_q_facet_2")
    if mod then mod:Destroy() end
    caster:AddNewModifier(caster, self, "modifier_flash_q_facet_2", {duration = self:GetSpecialValueFor("duration")})
    local particle = ParticleManager:CreateParticle("particles/econ/items/weaver/weaver_immortal_ti6/weaver_immortal_ti6_shukuchi_portal.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
    caster:EmitSound("flash_q_facet2")
end

modifier_flash_q_facet_2 = class({})

function modifier_flash_q_facet_2:IsHidden() return false end
function modifier_flash_q_facet_2:IsPurgable() return true end

function modifier_flash_q_facet_2:OnCreated()
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    self:StartIntervalThink(0.1)
end

function modifier_flash_q_facet_2:OnIntervalThink()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local caster_origin = caster:GetAbsOrigin()
    local radius = ability:GetSpecialValueFor("radius")
    local interval = ability:GetSpecialValueFor("interval")
    local damage = ability:GetSpecialValueFor("damage") + (ability:GetSpecialValueFor("damage_speed") * caster:GetMoveSpeedModifier(caster:GetBaseMoveSpeed(), true) * 0.01) + self.damage
    local damage_type = ability:GetAbilityDamageType()
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster_origin, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    local damage_table = {
        attacker = caster,
        damage = damage,
        damage_type = damage_type,
    }
    for _, enemy in pairs(enemies) do
        if enemy and not enemy:IsNull() and not enemy:HasModifier("modifier_flash_q_facet_2_cooldown") then
            enemy:AddNewModifier(caster, ability, "modifier_flash_q_facet_2_cooldown", {duration = interval})
            local particle = ParticleManager:CreateParticle("particles/econ/items/weaver/weaver_immortal_ti6/weaver_immortal_ti6_shukuchi_damage.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
            ParticleManager:SetParticleControl(particle, 0, enemy:GetAbsOrigin())
            ParticleManager:SetParticleControl(particle, 1, caster_origin)
            ParticleManager:ReleaseParticleIndex(particle)
            damage_table.victim = enemy
            ApplyDamage(damage_table)
        end
    end
end

function modifier_flash_q_facet_2:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_flash_q_facet_2:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_speed")
end

function modifier_flash_q_facet_2:CheckState()
    return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_flash_q_facet_2:GetEffectName()
    return "particles/econ/items/weaver/weaver_immortal_ti6/weaver_immortal_ti6_shukuchi.vpcf"
end

function modifier_flash_q_facet_2:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_flash_q_facet_2_cooldown = class({})
function modifier_flash_q_facet_2_cooldown:IsHidden() return true end
function modifier_flash_q_facet_2_cooldown:IsPurgable() return false end