LinkLuaModifier("modifier_stint_r_1", "heroes/stint/stint_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stint_r_1_debuff", "heroes/stint/stint_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stint_r_2", "heroes/stint/stint_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stint_r_3", "heroes/stint/stint_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stint_r_3_debuff", "heroes/stint/stint_r", LUA_MODIFIER_MOTION_NONE)

stint_r = class({})

function stint_r:Precache(context)
    PrecacheResource("particle", "particles/stint_r_1.vpcf", context)
    PrecacheResource("particle", "particles/stint_r_3.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_mars/mars_spear_impact_debuff_fire.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_grimstroke/grimstroke_ink_swell_aoe.vpcf", context)
    PrecacheResource("soundfile", "soundevents/stint_r.vsndevts", context)
end

function stint_r:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    if self:GetSpecialValueFor("all_effects") == 1 then
        caster:AddNewModifier(caster, self, "modifier_stint_r_1", {duration = self:GetSpecialValueFor("duration")})
        caster:AddNewModifier(caster, self, "modifier_stint_r_2", {duration = self:GetSpecialValueFor("duration")})
        caster:AddNewModifier(caster, self, "modifier_stint_r_3", {duration = self:GetSpecialValueFor("duration")})
        EmitSoundOn("stint_r_all", caster)
    else
        local random_modifier = RandomInt(1, 3)
        caster:AddNewModifier(caster, self, "modifier_stint_r_"..random_modifier, {duration = self:GetSpecialValueFor("duration")})
        EmitSoundOn("stint_r_"..random_modifier, caster)
    end
end

modifier_stint_r_1 = class({})

function modifier_stint_r_1:IsHidden() return false end
function modifier_stint_r_1:IsPurgable() return false end
function modifier_stint_r_1:IsDebuff()   return false end

function modifier_stint_r_1:OnCreated(kv)
    self.beam_radius    = self:GetAbility():GetSpecialValueFor("projector_radius")
    self.miss_chance    = self:GetAbility():GetSpecialValueFor("projector_miss")
    self.beam_width     = self:GetAbility():GetSpecialValueFor("projector_width")
    self.bonus_ms       = self:GetAbility():GetSpecialValueFor("bonus_ms")
    self.bonus_spell    = self:GetAbility():GetSpecialValueFor("bonus_spell")
    self.beam_count     = 3
    self.rotation_speed = 45
    self.particles = {}
    self.angles    = {}
    local origin = self:GetParent():GetAbsOrigin()
    for i = 1, self.beam_count do
        local angle_deg = (360 / self.beam_count) * (i - 1)
        table.insert(self.angles, angle_deg)

        local rad = math.rad(angle_deg)
        local pos = origin + Vector(math.cos(rad), math.sin(rad), 0) * self.beam_radius
        local fx = ParticleManager:CreateParticle(
            "particles/stint_r_1.vpcf",
            PATTACH_WORLDORIGIN,
            nil
        )
        ParticleManager:SetParticleControl(fx, 0, pos)
        ParticleManager:SetParticleControl(fx, 1, Vector(self.beam_radius, self.miss_chance, 0))
        table.insert(self.particles, fx)
    end
    self:StartIntervalThink(0.03)
end

function modifier_stint_r_1:OnDestroy()
    if self.particles then
        for _, fx in pairs(self.particles) do
            ParticleManager:DestroyParticle(fx, false)
            ParticleManager:ReleaseParticleIndex(fx)
        end
        self.particles = nil
        self.angles = nil
    end
end

function modifier_stint_r_1:OnIntervalThink()
    local parent = self:GetParent()
    local origin = parent:GetAbsOrigin()
    local dt = FrameTime()
    for i = 1, self.beam_count do
        self.angles[i] = (self.angles[i] + self.rotation_speed * dt) % 360
        local rad = math.rad(self.angles[i])
        local pos = origin + Vector(math.cos(rad), math.sin(rad), 0) * self.beam_radius
        if self.particles and self.particles[i] then
            ParticleManager:SetParticleControl(self.particles[i], 0, pos)
        end
        if IsServer() then
            local enemies = FindUnitsInRadius(
                parent:GetTeamNumber(),
                pos,
                nil,
                self.beam_width,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false
            )
            for _, enemy in pairs(enemies) do
                enemy:AddNewModifier(parent, self:GetAbility(), "modifier_stint_r_1_debuff", { duration = 0.1 })
            end
        end
    end
end

function modifier_stint_r_1:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }
end

function modifier_stint_r_1:GetModifierMoveSpeedBonus_Percentage()
    return self.bonus_ms
end

function modifier_stint_r_1:GetModifierSpellAmplify_Percentage()
    return self.bonus_spell
end

modifier_stint_r_1_debuff = class({})

function modifier_stint_r_1_debuff:IsHidden() return false end
function modifier_stint_r_1_debuff:IsPurgable() return false end
function modifier_stint_r_1_debuff:IsDebuff()   return true end

function modifier_stint_r_1_debuff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MISS_PERCENTAGE }
end

function modifier_stint_r_1_debuff:GetModifierMiss_Percentage()
    return self:GetAbility():GetSpecialValueFor("projector_miss")
end

modifier_stint_r_2 = class({})

function modifier_stint_r_2:IsHidden() return false end
function modifier_stint_r_2:IsPurgable() return false end
function modifier_stint_r_2:IsDebuff()   return false end

function modifier_stint_r_2:OnCreated()
    if not IsServer() then return end
    GameRules:SetTimeOfDay(0)
    self.interval = self:GetAbility():GetSpecialValueFor("armageddon_interval")
    self.radius = self:GetAbility():GetSpecialValueFor("armageddon_radius")
    self:StartIntervalThink(self.interval)
    self:OnIntervalThink()
end

function modifier_stint_r_2:OnIntervalThink()
    local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_ink_swell_aoe.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(effect_cast, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 1, Vector(self.radius, self.radius, self.radius))
    ParticleManager:SetParticleControl(effect_cast, 4, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
    local base_damage = self:GetAbility():GetSpecialValueFor("armageddon_damage_base")
    local pct_damage = self:GetAbility():GetSpecialValueFor("armageddon_damage_pct")
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
    for _,enemy in pairs(enemies) do
        local damage = base_damage + pct_damage * enemy:GetHealth() * 0.01
        ApplyDamage({ attacker = self:GetCaster(), victim = enemy, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() })
    end
end

function modifier_stint_r_2:OnDestroy()
    if not IsServer() then return end
    GameRules:SetTimeOfDay(0.5)
end

modifier_stint_r_3 = class({})

function modifier_stint_r_3:IsHidden() return false end
function modifier_stint_r_3:IsPurgable() return false end
function modifier_stint_r_3:IsDebuff()   return false end

function modifier_stint_r_3:OnCreated(kv)
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("fire_radius")
    self.dps = self:GetAbility():GetSpecialValueFor("fire_dps")
    self.debuff_dur = self:GetAbility():GetSpecialValueFor("fire_duration")
    self.interval = self:GetAbility():GetSpecialValueFor("fire_interval")
    self.parent = self:GetParent()
    local effect_cast = ParticleManager:CreateParticle( "particles/stint_r_3.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl(effect_cast, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 2, Vector(300,1,1))
    ParticleManager:SetParticleControl(effect_cast, 20, self:GetParent():GetAbsOrigin())
    self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
    self.ability = self:GetAbility()
    self:StartIntervalThink(self.interval)
end

function modifier_stint_r_3:OnIntervalThink()
    local enemies = FindUnitsInRadius(
        self.parent:GetTeamNumber(),
        self.parent:GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    for _, enemy in pairs(enemies) do
        ApplyDamage({
            victim = enemy,
            attacker = self.parent,
            damage = self.dps * self.interval,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self.ability,
        })
        local mod = enemy:FindModifierByName("modifier_stint_r_3_debuff")
        if mod then
            mod:IncrementStackCount()
            mod:SetDuration(self.debuff_dur, true)
        else
            mod = enemy:AddNewModifier(self.parent, self.ability, "modifier_stint_r_3_debuff", { duration = self.debuff_dur })
            if mod then mod:SetStackCount(1) end
        end
    end
end

modifier_stint_r_3_debuff = class({})

function modifier_stint_r_3_debuff:IsHidden() return false end
function modifier_stint_r_3_debuff:IsPurgable() return true end
function modifier_stint_r_3_debuff:IsDebuff()   return true end
function modifier_stint_r_3_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_stint_r_3_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
    }
end

function modifier_stint_r_3_debuff:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("fire_decrease") * self:GetStackCount()
end

function modifier_stint_r_3_debuff:GetModifierStatusResistanceStacking()
    return self:GetAbility():GetSpecialValueFor("fire_decrease") * self:GetStackCount()
end

function modifier_stint_r_3_debuff:GetEffectName()
    return "particles/units/heroes/hero_mars/mars_spear_impact_debuff_fire.vpcf"
end

function modifier_stint_r_3_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end