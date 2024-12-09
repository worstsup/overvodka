sasavot_e = class({})
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)

function sasavot_e:GetBehavior()
    if self:GetCaster() and self:GetSpecialValueFor("hasfacet") == 1 then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
    end
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function sasavot_e:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function sasavot_e:OnSpellStart()
    local caster = self:GetCaster()
    if self:GetSpecialValueFor("hasfacet") == 1 then
        self:TeleportAndStun()
    else
        self:StunAroundCaster()
    end
end

function sasavot_e:TeleportAndStun()
    local target_point = self:GetCursorPosition()
    local caster = self:GetCaster()
    FindClearSpaceForUnit(caster, target_point, true)
    local radius = self:GetSpecialValueFor("radius")
    local damage = self:GetSpecialValueFor("stomp_damage")
    local stun_duration = self:GetSpecialValueFor("stun_duration")
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
        damageTable.victim = enemy
        ApplyDamage(damageTable)
        enemy:AddNewModifier(caster, self, "modifier_generic_stunned_lua", { duration = stun_duration })
    end
    self:PlayEffects(target_point, radius)
end

function sasavot_e:StunAroundCaster()
    local caster = self:GetCaster()
    local radius = self:GetSpecialValueFor("radius")
    local damage = self:GetSpecialValueFor("stomp_damage")
    local stun_duration = self:GetSpecialValueFor("stun_duration")
    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetOrigin(),
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
        damageTable.victim = enemy
        ApplyDamage(damageTable)
        enemy:AddNewModifier(caster, self, "modifier_generic_stunned_lua", { duration = stun_duration })
    end
    self:PlayEffects(caster:GetOrigin(), radius)
end

function sasavot_e:PlayEffects(location, radius)
    local particle_cast = "particles/econ/items/elder_titan/elder_titan_ti7/elder_titan_echo_stomp_ti7_physical.vpcf"
    local sound_cast = "Hero_Centaur.HoofStomp"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(effect_cast, 0, location)
    ParticleManager:SetParticleControl(effect_cast, 1, Vector(radius, radius, radius))
    ParticleManager:ReleaseParticleIndex(effect_cast)
    EmitSoundOnLocationWithCaster(location, sound_cast, self:GetCaster())
    EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "sasavot_e", self:GetCaster() )
end
