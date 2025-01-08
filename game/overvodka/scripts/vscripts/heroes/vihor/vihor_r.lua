LinkLuaModifier("modifier_vihor_r", "heroes/vihor/vihor_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_vihor_r_debuff", "heroes/vihor/vihor_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )

vihor_r = class({})

function vihor_r:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_gyrocopter/gyro_death_explosion.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/techies/techies_arcana/techies_suicide_arcana.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_marci/marci_bodyguard_radius.vpcf", context)
    PrecacheResource("particle", "particles/vihor_r_start.vpcf", context)
    PrecacheResource("particle", "particles/vihor_r.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/arc_warden/arc_warden_frostivus_2023/arc_warden_magnetic_frostivus_start.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/antimage/antimage_ti7/antimage_blink_start_ti7_flame.vpcf", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_shredder.vsndevts", context)
end

function vihor_r:OnAbilityPhaseStart()
    local particle_2 = ParticleManager:CreateParticle("particles/econ/items/arc_warden/arc_warden_frostivus_2023/arc_warden_magnetic_frostivus_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    local particle_3 = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_ti7/antimage_blink_start_ti7_flame.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    EmitSoundOn("vihor_r_start", self:GetCaster())
end

function vihor_r:OnAbilityPhaseInterrupted()
    StopSoundOn("vihor_r_start", self:GetCaster())
end

function vihor_r:OnSpellStart()
    if not IsServer() then return end
    local duration_to_explosion = self:GetSpecialValueFor("duration_to_explosion")
    AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), self:GetSpecialValueFor("radius"), duration_to_explosion, false)
    EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), "vihor_r", self:GetCaster())
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_vihor_r", {duration = duration_to_explosion})
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_5)
end

modifier_vihor_r = class({})
function modifier_vihor_r:IsPurgable() return false end
function modifier_vihor_r:IsPurgeException() return false end
function modifier_vihor_r:RemoveOnDeath() return false end
function modifier_vihor_r:OnCreated()
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    if not IsServer() then return end
    local particle_1 = ParticleManager:CreateParticle("particles/vihor_r_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_marci/marci_bodyguard_radius.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, self.radius, self.radius))
    self:AddParticle(particle, false, false, -1, false, false)
    self:StartIntervalThink(0.1)
end

function modifier_vihor_r:OnIntervalThink()
    if not IsServer() then return end
    local units = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
    for _, unit in pairs(units) do
        if not unit:HasModifier("modifier_vihor_r_debuff") then
            unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_vihor_r_debuff", {duration = self:GetRemainingTime()})
        end
    end
end
function modifier_vihor_r:GetEffectName()
    return "particles/vihor_r.vpcf"
end
function modifier_vihor_r:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_vihor_r:OnDestroy()
    if not IsServer() then return end
    self:GetParent():EmitSound("Hero_Shredder.Bomb")

    local particle_death = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_death_explosion.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_death, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_death)

    local particle_radius = ParticleManager:CreateParticle("particles/econ/items/techies/techies_arcana/techies_suicide_arcana.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_radius, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_radius)
end

function modifier_vihor_r:CheckState()
    return
    {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
    }
end

modifier_vihor_r_debuff = class({})

function modifier_vihor_r_debuff:OnCreated(kv)
    if not IsServer() then return end
    self.slow = self:GetAbility():GetSpecialValueFor("slow")
    self.bonus_attack_range = 2000
    self.target = self:GetCaster():GetAbsOrigin() + RandomVector(100)
    self.tick_damage = self:GetAbility():GetSpecialValueFor("tick_damage")
    self:StartIntervalThink(0.2)
end

function modifier_vihor_r_debuff:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()
    local caster = self:GetCaster()
    self.dmg = self.tick_damage * self:GetParent():GetMaxHealth() * 0.01 * 0.2
    ApplyDamage({ victim = parent, attacker = caster, damage = self.dmg, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NONE, ability = self:GetAbility() })
    AddFOWViewer(parent:GetTeamNumber(), self:GetCaster():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("radius"), 0.2, false)
    if not parent:IsMoving() then
        parent:MoveToPosition(self.target)
    end

    if GameRules:GetGameTime() % 1.2 < 0.2 then
        local debuff_radius = self:GetAbility():GetSpecialValueFor("radius")
        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(),
            parent:GetAbsOrigin(),
            nil,
            debuff_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )

        for _, attacker in ipairs(enemies) do
            if attacker:IsAlive() and attacker:HasModifier("modifier_vihor_r_debuff") then
                local target = nil
                for _, potential_target in ipairs(enemies) do
                    if potential_target:IsAlive() and potential_target:HasModifier("modifier_vihor_r_debuff") and potential_target ~= attacker then
                        target = potential_target
                        break
                    end
                end

                if target then
                    attacker:SetForceAttackTarget(target)
                    attacker:MoveToTargetToAttack(target)
                    Timers:CreateTimer(1.0, function()
                        if not attacker:IsNull() then
                            attacker:SetForceAttackTarget(nil)
                        end
                    end)
                end
            end
        end
    end
end

function modifier_vihor_r_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
        MODIFIER_PROPERTY_MIN_HEALTH,
    }
    return funcs
end
function modifier_vihor_r_debuff:GetMinHealth()
    return 1
end
function modifier_vihor_r_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end

function modifier_vihor_r_debuff:GetModifierAttackRangeBonus()
    return self.bonus_attack_range
end

function modifier_vihor_r_debuff:GetModifierAttackSpeedBonus_Constant()
    return 1000
end

function modifier_vihor_r_debuff:GetModifierBaseAttackTimeConstant()
    return 0.9
end
function modifier_vihor_r_debuff:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    if not parent:IsNull() then
        parent:SetForceAttackTarget(nil)
    end
    local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
    local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
    for _, unit in pairs(units) do
        ApplyDamage({ victim = unit, attacker = self:GetCaster(), damage = self:GetAbility():GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() })
        unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_generic_stunned_lua", {duration = stun_duration * (1 - unit:GetStatusResistance())})
    end
    self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_5)
end

function modifier_vihor_r_debuff:CheckState()
    return {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_TAUNTED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end