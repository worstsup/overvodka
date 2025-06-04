t2x2_q = class({})
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t2x2_q_shard", "heroes/t2x2/t2x2_q", LUA_MODIFIER_MOTION_NONE)
function t2x2_q:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function t2x2_q:Precache(context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_centaur.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/t2x2_sounds.vsndevts", context)
    PrecacheResource("particle", "particles/econ/items/elder_titan/elder_titan_ti7/elder_titan_echo_stomp_ti7_physical.vpcf", context)
end

function t2x2_q:OnSpellStart()
    if not IsServer() then return end
    local target_point = self:GetCursorPosition()
    local caster = self:GetCaster()
    local radius = self:GetSpecialValueFor("radius")
    GridNav:DestroyTreesAroundPoint( target_point, radius, false )
    FindClearSpaceForUnit(caster, target_point, true)
    local damage = self:GetSpecialValueFor("stomp_damage")
    local stun_duration = self:GetSpecialValueFor("stun_duration")
    local heroes = 0
    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        target_point,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    local damageTable = {
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self,
    }
    for _, enemy in pairs(enemies) do
        if caster:HasShard() and enemy:IsRealHero() and not enemy:IsIllusion() then
            heroes = heroes + 1
        end
        damageTable.victim = enemy
        enemy:AddNewModifier(caster, self, "modifier_generic_stunned_lua", { duration = stun_duration })
        ApplyDamage(damageTable)
    end
    if caster:HasShard() and heroes > 0 then
        local mod = caster:AddNewModifier(caster, self, "modifier_t2x2_q_shard", {duration = self:GetSpecialValueFor("shard_duration")})
        mod:SetStackCount(heroes)
        caster:CalculateStatBonus(true)
    end
    self:PlayEffects(target_point, radius)
end

function t2x2_q:PlayEffects(location, radius)
    local particle_cast = "particles/econ/items/elder_titan/elder_titan_ti7/elder_titan_echo_stomp_ti7_physical.vpcf"
    local sound_cast = "Hero_Centaur.HoofStomp"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(effect_cast, 0, location)
    ParticleManager:SetParticleControl(effect_cast, 1, Vector(radius, radius, radius))
    ParticleManager:ReleaseParticleIndex(effect_cast)
    EmitSoundOnLocationWithCaster(location, sound_cast, self:GetCaster())
    EmitSoundOn("t2x2_q_"..RandomInt(1,4), self:GetCaster())
end

modifier_t2x2_q_shard = class({})
function modifier_t2x2_q_shard:IsHidden() return false end
function modifier_t2x2_q_shard:IsPurgable() return false end

function modifier_t2x2_q_shard:OnCreated()
    if not IsServer() then return end
end

function modifier_t2x2_q_shard:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
    }
end

function modifier_t2x2_q_shard:GetModifierBonusStats_Strength()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("strength_per_hero")
end