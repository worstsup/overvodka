LinkLuaModifier("modifier_stray_r", "heroes/stray/stray_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stray_r_shard", "heroes/stray/stray_r", LUA_MODIFIER_MOTION_NONE)

stray_r = class({})

function stray_r:Precache(context)
    PrecacheResource("model", "models/stray/tiger_h1.vmdl", context)
    PrecacheResource("soundfile", "soundevents/stray_r.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/stray_r_shoot.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/stray_r_tank.vsndevts", context)
    PrecacheResource("particle", "particles/units/heroes/hero_techies/techies_base_attack.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf", context)
    PrecacheResource("particle", "particles/dire_fx/bad_ancient002_destroy_smoke_upper.vpcf", context)
end

function stray_r:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level)
end

function stray_r:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function stray_r:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("stray_r")
    StopGlobalSound("stray_scepter")
    local duration = self:GetSpecialValueFor('duration')
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_stray_r", {duration = duration})
    if self:GetCaster():HasShard() then
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_stray_r_shard", {duration = duration})
    end
end

modifier_stray_r = class({}) 

function modifier_stray_r:IsPurgable() return false end
function modifier_stray_r:OnCreated()
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/dire_fx/bad_ancient002_destroy_smoke_upper.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    self.free = false
    if self:GetAbility():GetSpecialValueFor("free") == 1 then
        self.free = true
    end
    EmitSoundOn("stray_r_tank", self:GetParent())
    self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
    if self:GetParent():GetUnitName() == "npc_dota_hero_rubick" then
        self:GetParent():SetModelScale(1.8)
    end
end

function modifier_stray_r:OnDestroy()
    if not IsServer() then return end
    StopSoundOn("stray_r_tank", self:GetParent())
    if self:GetParent():GetUnitName() ~= "npc_dota_hero_rubick" then
        self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
    else
        self:GetParent():SetModelScale(0.75)
    end
end

function modifier_stray_r:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_PROJECTILE_NAME,
        MODIFIER_PROPERTY_PROJECTILE_SPEED,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
    }
    return decFuncs
end

function modifier_stray_r:CheckState()
    return 
    {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_DEBUFF_IMMUNE] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = self.free
    }
end

function modifier_stray_r:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor('mv')
end

function modifier_stray_r:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor('armor')
end

function modifier_stray_r:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor('magic_resist')
end

function modifier_stray_r:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor('dmg')
end

function modifier_stray_r:GetModifierFixedAttackRate()
    return self:GetAbility():GetSpecialValueFor('bat')
end

function modifier_stray_r:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor('range')
end

function modifier_stray_r:GetModifierModelChange()
    return "models/stray/tiger_h1.vmdl"
end

function modifier_stray_r:GetModifierProjectileName()
    return "particles/units/heroes/hero_techies/techies_base_attack.vpcf"
end

function modifier_stray_r:GetAttackSound()
    return "stray_r_shoot"
end

function modifier_stray_r:GetModifierProjectileSpeed()
    return 1400
end

modifier_stray_r_shard = class({})
function modifier_stray_r_shard:IsPurgable() return false end
function modifier_stray_r_shard:IsHidden() return true end
function modifier_stray_r_shard:OnCreated(params)
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.damage = self:GetAbility():GetSpecialValueFor("taran_damage")
    self:StartIntervalThink(0.15)
end

function modifier_stray_r_shard:OnDestroy()
    if not IsServer() then return end
end

function modifier_stray_r_shard:OnIntervalThink()
    if not IsServer() then return end
    GridNav:DestroyTreesAroundPoint(self:GetCaster():GetAbsOrigin(), self.radius, true)
    local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _, unit in pairs(units) do
        if not unit:IsDebuffImmune() and not unit:IsMagicImmune() then
            local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf", PATTACH_POINT_FOLLOW, unit )
            ParticleManager:SetParticleControlEnt( particle, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
            ParticleManager:ReleaseParticleIndex( particle )
            ApplyDamage({ victim = unit, attacker = self:GetCaster(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NONE, ability = self:GetAbility() })
            if unit and not unit:IsNull() then
                local direction = (unit:GetAbsOrigin() - self:GetParent():GetAbsOrigin())
                direction.z = 0
                direction = direction:Normalized()
                unit:AddNewModifier(
                    self:GetCaster(),
                    self,
                    "modifier_knockback",
                    {
                        center_x = self:GetParent():GetAbsOrigin().x,
                        center_y = self:GetParent():GetAbsOrigin().y,
                        center_z = self:GetParent():GetAbsOrigin().z,
                        duration = 0.2,
                        knockback_duration = 0.2,
                        knockback_distance = 300,
                        knockback_height = 50
                    }
                )
            end
        end
    end
end