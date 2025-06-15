LinkLuaModifier("modifier_mazellov_f_dot", "heroes/mazellov/mazellov_f.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mazellov_f_slow", "heroes/mazellov/mazellov_f.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mazellov_f_resist_reduction", "heroes/mazellov/mazellov_f.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mazellov_f_miss_chance", "heroes/mazellov/mazellov_f.lua", LUA_MODIFIER_MOTION_NONE)

for i = 1, 4 do
    LinkLuaModifier("modifier_mazellov_f_orb_"..i, "heroes/mazellov/mazellov_f.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_mazellov_f_orb_hit_"..i, "heroes/mazellov/mazellov_f.lua", LUA_MODIFIER_MOTION_NONE)
end

mazellov_f = class({})

function mazellov_f:Precache(context)
    PrecacheResource( "particle", "particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_projectile_hit.vpcf", context )
end

function mazellov_f:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")

    for i = 1, 4 do
        caster:RemoveModifierByName("modifier_mazellov_f_orb_"..i)
    end

    for i = 1, 4 do
        caster:AddNewModifier(caster, self, "modifier_mazellov_f_orb_"..i, {
            duration = duration,
            orb_index = i
        })
    end
end

local modifier_mazellov_f_orb = class({})

function modifier_mazellov_f_orb:IsHidden() return true end
function modifier_mazellov_f_orb:IsPurgable() return false end

function modifier_mazellov_f_orb:OnCreated(kv)
    if not IsServer() then return end

    self.orb_index = kv.orb_index or 1
    self.radius = self:GetAbility():GetSpecialValueFor("radius") or 250
    self.speed = self:GetAbility():GetSpecialValueFor("rotation_speed") or 360
    self.damage = self:GetAbility():GetSpecialValueFor("damage") or 50
    self.interval = 0.03

    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.angle = 90 * (self.orb_index - 1)

    -- Разные партиклы для каждого орба
    local particle_names = {
        "particles/mazellov_f_1.vpcf",          -- 1-й орб (DOT)
        "particles/mazellov_f_3.vpcf",  -- 2-й орб (Slow)
        "particles/units/heroes/hero_wisp/wisp_guardian.vpcf",                         -- 3-й орб (Resist Reduction)
        "particles/mazellov_f_2.vpcf"                  -- 4-й орб (Miss Chance)
    }

    self.particle = ParticleManager:CreateParticle(particle_names[self.orb_index], PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(self.particle, 0, self.parent:GetAbsOrigin() + Vector(0, 0, 100))
    
    self:AddParticle(self.particle, false, false, -1, false, false)

    self:StartIntervalThink(self.interval)
end

function modifier_mazellov_f_orb:OnIntervalThink()
    if not IsServer() then return end

    self.angle = self.angle + self.speed * self.interval
    local radians = math.rad(self.angle)
    local offset = Vector(math.cos(radians), math.sin(radians), 0) * self.radius
    local orb_position = self.parent:GetAbsOrigin() + offset + Vector(0, 0, 100)

    ParticleManager:SetParticleControl(self.particle, 0, orb_position)

    local enemies = FindUnitsInRadius(
        self.parent:GetTeamNumber(),
        orb_position,
        nil,
        100,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in pairs(enemies) do
        if not enemy:IsAttackImmune() and not enemy:HasModifier("modifier_mazellov_f_orb_hit_"..self.orb_index) then
            ApplyDamage({
                victim = enemy,
                attacker = self.parent,
                damage = self.damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = self.ability,
            })

            local modifier_name = ""
            if self.orb_index == 1 then
                modifier_name = "modifier_mazellov_f_dot"
            elseif self.orb_index == 2 then
                modifier_name = "modifier_mazellov_f_slow"
            elseif self.orb_index == 3 then
                modifier_name = "modifier_mazellov_f_resist_reduction"
            elseif self.orb_index == 4 then
                modifier_name = "modifier_mazellov_f_miss_chance"
            end

            enemy:AddNewModifier(self.parent, self.ability, modifier_name, {
                duration = self:GetAbility():GetSpecialValueFor("effect_duration")
            })

            enemy:AddNewModifier(self.parent, self.ability, "modifier_mazellov_f_orb_hit_"..self.orb_index, {duration = 1.0})
            self:Destroy()
            return
        end
    end
end

function modifier_mazellov_f_orb:OnDestroy()
    if not IsServer() then return end
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end
end

for i = 1, 4 do
    _G["modifier_mazellov_f_orb_"..i] = class(modifier_mazellov_f_orb)
end

modifier_mazellov_f_orb_hit_1 = class({})
function modifier_mazellov_f_orb_hit_1:IsHidden() return true end
function modifier_mazellov_f_orb_hit_1:IsPurgable() return false end
function modifier_mazellov_f_orb_hit_1:IsDebuff() return false end
modifier_mazellov_f_orb_hit_2 = class({})
function modifier_mazellov_f_orb_hit_2:IsHidden() return true end
function modifier_mazellov_f_orb_hit_2:IsPurgable() return false end
function modifier_mazellov_f_orb_hit_2:IsDebuff() return false end
modifier_mazellov_f_orb_hit_3 = class({})
function modifier_mazellov_f_orb_hit_3:IsHidden() return true end
function modifier_mazellov_f_orb_hit_3:IsPurgable() return false end
function modifier_mazellov_f_orb_hit_3:IsDebuff() return false end
modifier_mazellov_f_orb_hit_4 = class({})
function modifier_mazellov_f_orb_hit_4:IsHidden() return true end
function modifier_mazellov_f_orb_hit_4:IsPurgable() return false end
function modifier_mazellov_f_orb_hit_4:IsDebuff() return false end

modifier_mazellov_f_dot = class({})

function modifier_mazellov_f_dot:IsDebuff() return true end
function modifier_mazellov_f_dot:IsPurgable() return true end
function modifier_mazellov_f_dot:OnCreated()
    if not IsServer() then return end
    self.damage = self:GetAbility():GetSpecialValueFor("dot_damage")
    self.interval = self:GetAbility():GetSpecialValueFor("dot_interval")
    self:StartIntervalThink(self.interval)
    
    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_burn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(self.particle, false, false, -1, false, false)
end
function modifier_mazellov_f_dot:OnIntervalThink()
    ApplyDamage({
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
    })
end
function modifier_mazellov_f_dot:GetEffectName()
    return "particles/units/heroes/hero_phoenix/phoenix_fire_spirit_burn.vpcf"
end
function modifier_mazellov_f_dot:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_mazellov_f_slow = class({})
function modifier_mazellov_f_slow:IsDebuff() return true end
function modifier_mazellov_f_slow:IsPurgable() return true end
function modifier_mazellov_f_slow:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end
function modifier_mazellov_f_slow:GetModifierMoveSpeedBonus_Percentage()
    return -self:GetAbility():GetSpecialValueFor("slow_pct")
end
function modifier_mazellov_f_slow:GetEffectName()
    return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
end
function modifier_mazellov_f_slow:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_mazellov_f_resist_reduction = class({})
function modifier_mazellov_f_resist_reduction:IsDebuff() return true end
function modifier_mazellov_f_resist_reduction:IsPurgable() return true end
function modifier_mazellov_f_resist_reduction:DeclareFunctions()
    return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS }
end
function modifier_mazellov_f_resist_reduction:GetModifierMagicalResistanceBonus()
    return -self:GetAbility():GetSpecialValueFor("magic_resist_reduction")
end
function modifier_mazellov_f_resist_reduction:GetEffectName()
    return "particles/units/heroes/hero_antimage/antimage_manabreak_enemy_debuff.vpcf"
end
function modifier_mazellov_f_resist_reduction:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_mazellov_f_miss_chance = class({})
function modifier_mazellov_f_miss_chance:IsDebuff() return true end
function modifier_mazellov_f_miss_chance:IsPurgable() return true end
function modifier_mazellov_f_miss_chance:DeclareFunctions()
    return { MODIFIER_PROPERTY_MISS_PERCENTAGE }
end
function modifier_mazellov_f_miss_chance:GetModifierMiss_Percentage()
    return self:GetAbility():GetSpecialValueFor("miss_chance")
end
function modifier_mazellov_f_miss_chance:GetEffectName()
    return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_debuff.vpcf"
end
function modifier_mazellov_f_miss_chance:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end