LinkLuaModifier("modifier_mazellov_f_dot",               "heroes/mazellov/mazellov_f.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mazellov_f_slow",              "heroes/mazellov/mazellov_f.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mazellov_f_resist_reduction",  "heroes/mazellov/mazellov_f.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mazellov_f_miss_chance",       "heroes/mazellov/mazellov_f.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mazellov_f_passive",           "heroes/mazellov/mazellov_f.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mazellov_f_orb_unit",          "heroes/mazellov/mazellov_f.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mazellov_f_orb_ambient",       "heroes/mazellov/mazellov_f.lua", LUA_MODIFIER_MOTION_NONE)

for i = 1, 4 do
    LinkLuaModifier("modifier_mazellov_f_orb_hit_"..i, "heroes/mazellov/mazellov_f.lua", LUA_MODIFIER_MOTION_NONE)
end

local function IsValidEntitySafe(h)
    return h ~= nil and not h:IsNull()
end

local function NormalizeAngle(a)
    local two_pi = math.pi * 2
    if a == nil then return 0 end
    a = a % two_pi
    if a < 0 then a = a + two_pi end
    return a
end

mazellov_f = class({})

function mazellov_f:Precache(context)
    PrecacheResource("particle", "particles/mazellov_f_1.vpcf", context)
    PrecacheResource("particle", "particles/mazellov_f_2.vpcf", context)
    PrecacheResource("particle", "particles/mazellov_f_3.vpcf", context)
    PrecacheResource("particle", "particles/mazellov_f.vpcf",  context)
    PrecacheUnitByNameSync("npc_kirieshka", context)
    PrecacheResource("particle", "particles/units/heroes/hero_phoenix/phoenix_fire_spirit_burn.vpcf", context)
    PrecacheResource("particle", "particles/pugna_decrepify_b.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_antimage/antimage_manabreak_enemy_debuff.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_debuff.vpcf", context)
end

function mazellov_f:GetIntrinsicModifierName()
    return "modifier_mazellov_f_passive"
end

modifier_mazellov_f_passive = class({})
function modifier_mazellov_f_passive:IsHidden() return true end
function modifier_mazellov_f_passive:IsPurgable() return false end

function modifier_mazellov_f_passive:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.10)
end

function modifier_mazellov_f_passive:OnIntervalThink()
    if not IsServer() then return end

    local ability = self:GetAbility()
    if ability == nil or ability:IsNull() then return end

    local caster = self:GetParent()
    if caster == nil or caster:IsNull() then return end
    if not ability:IsCooldownReady() then return end
    if not caster:IsAlive() then return end
    if caster:IsIllusion() then return end
    if caster:PassivesDisabled() then return end

    ability:UseResources(false, false, false, true)

    caster.mazellov_f_units = caster.mazellov_f_units or {}
    caster.mazellov_f_orb_index = (caster.mazellov_f_orb_index or 0) + 1
    local index = ((caster.mazellov_f_orb_index - 1) % 4) + 1

    local slot = caster.mazellov_f_units[index]
    if IsValidEntitySafe(slot) then
        UTIL_Remove(slot)
        caster.mazellov_f_units[index] = nil
    end

    local duration       = ability:GetSpecialValueFor("duration")
    local radius         = ability:GetSpecialValueFor("radius")
    local rotation_speed = ability:GetSpecialValueFor("rotation_speed")

    local base = caster.mazellov_f_base_angle or 0
    base = NormalizeAngle(base)

    local angle = base + (index - 1) * (math.pi / 2)
    angle = NormalizeAngle(angle)

    local origin = caster:GetAbsOrigin()
    local pos = origin + Vector(math.cos(angle), math.sin(angle), 0) * radius
    pos.z = origin.z + 100

    local unit = CreateUnitByName(
        "npc_kirieshka",
        pos, true, caster, caster:GetOwner(), caster:GetTeamNumber()
    )
    if not IsValidEntitySafe(unit) then return end

    unit:AddNewModifier(caster, ability, "modifier_mazellov_f_orb_ambient", { orb_index = index })
    unit:AddNewModifier(caster, ability, "modifier_mazellov_f_orb_unit", {
        duration       = duration,
        orb_index      = index,
        angle          = angle,
        radius         = radius,
        rotation_speed = rotation_speed,
    })

    caster.mazellov_f_units[index] = unit

    if RandomInt(1,2) == 1 then
        EmitSoundOn("mazellov_f_"..RandomInt(1,3), caster)
    end
end

modifier_mazellov_f_orb_ambient = class({})
function modifier_mazellov_f_orb_ambient:IsHidden() return true end
function modifier_mazellov_f_orb_ambient:IsPurgable() return false end
function modifier_mazellov_f_orb_ambient:OnCreated(kv)
    if not IsServer() then return end
    self.orb_index = tonumber(kv.orb_index) or 1

    local particle_names = {
        "particles/mazellov_f_1.vpcf",
        "particles/mazellov_f_3.vpcf",
        "particles/mazellov_f.vpcf",
        "particles/mazellov_f_2.vpcf",
    }
    local p = ParticleManager:CreateParticle(particle_names[self.orb_index], PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(p, false, false, -1, false, false)
end
function modifier_mazellov_f_orb_ambient:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_UNTARGETABLE] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
    }
end

modifier_mazellov_f_orb_unit = class({})
function modifier_mazellov_f_orb_unit:IsHidden() return false end
function modifier_mazellov_f_orb_unit:IsPurgable() return false end

function modifier_mazellov_f_orb_unit:OnCreated(kv)
    if not IsServer() then return end

    self.caster  = self:GetCaster()
    self.ability = self:GetAbility()
    self.unit    = self:GetParent()
    if not IsValidEntitySafe(self.caster) or self.ability == nil or self.ability:IsNull() or not IsValidEntitySafe(self.unit) then
        self:Destroy()
        return
    end

    self.orb_index = tonumber(kv.orb_index) or 1
    self.angle     = tonumber(kv.angle) or 0
    self.radius    = tonumber(kv.radius) or 250
    self.rot_deg   = tonumber(kv.rotation_speed) or 360
    self.rot_rad   = self.rot_deg * math.pi/180

    self.interval   = 0.03
    self.hit_radius = 100

    self.damage        = self.ability:GetSpecialValueFor("damage")
    self.dot_damage    = self.ability:GetSpecialValueFor("dot_damage")
    self.dot_interval  = self.ability:GetSpecialValueFor("dot_interval")
    self.effect_dur    = self.ability:GetSpecialValueFor("effect_duration")
    self.slow_pct      = self.ability:GetSpecialValueFor("slow_pct")
    self.mr_reduction  = self.ability:GetSpecialValueFor("magic_resist_reduction")
    self.miss_chance   = self.ability:GetSpecialValueFor("miss_chance")

    self.caster.mazellov_f_base_angle = NormalizeAngle(self.angle - (self.orb_index - 1) * (math.pi/2))

    self:StartIntervalThink(self.interval)
end

function modifier_mazellov_f_orb_unit:OnIntervalThink()
    if not IsServer() then return end

    if not IsValidEntitySafe(self.caster) then
        if IsValidEntitySafe(self.unit) then UTIL_Remove(self.unit) end
        self:Destroy()
        return
    end
    if not IsValidEntitySafe(self.unit) then
        self:Destroy()
        return
    end

    if not self.caster:IsAlive() then
        UTIL_Remove(self.unit)
        self:Destroy()
        return
    end

    self.angle = self.angle + self.rot_rad * self.interval
    self.caster.mazellov_f_base_angle = NormalizeAngle(self.angle - (self.orb_index - 1) * (math.pi/2))
    if self.angle > math.pi*2 then self.angle = self.angle - math.pi*2 end

    local origin = self.caster:GetAbsOrigin()
    local pos = origin + Vector(math.cos(self.angle), math.sin(self.angle), 0) * self.radius
    pos.z = origin.z + 100

    if IsValidEntitySafe(self.unit) then
        self.unit:SetAbsOrigin(pos)
        self.unit:SetForwardVector((pos - origin):Normalized())
    else
        self:Destroy()
        return
    end
    local enemies = FindUnitsInRadius(
        self.caster:GetTeamNumber(), pos, nil, self.hit_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false
    )

    if #enemies == 0 then return end

    local target = enemies[1]
    if not IsValidEntitySafe(target) then return end

    if target:HasModifier("modifier_mazellov_f_orb_hit_"..self.orb_index) then return end

    if self.damage and self.damage > 0 then
        ApplyDamage({
            victim = target, attacker = self.caster,
            damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self.ability
        })
    end

    if self.orb_index == 1 then
        target:AddNewModifier(self.caster, self.ability, "modifier_mazellov_f_dot", { duration = self.effect_dur })
    elseif self.orb_index == 2 then
        target:AddNewModifier(self.caster, self.ability, "modifier_mazellov_f_slow", { duration = self.effect_dur })
    elseif self.orb_index == 3 then
        target:AddNewModifier(self.caster, self.ability, "modifier_mazellov_f_resist_reduction", { duration = self.effect_dur })
    else
        target:AddNewModifier(self.caster, self.ability, "modifier_mazellov_f_miss_chance", { duration = self.effect_dur })
    end

    target:AddNewModifier(self.caster, self.ability, "modifier_mazellov_f_orb_hit_"..self.orb_index, { duration = 1.0 })

    self.hit = true
    self:Destroy()
end

function modifier_mazellov_f_orb_unit:OnDestroy()
    if not IsServer() then return end
    if IsValidEntitySafe(self.unit) then
        UTIL_Remove(self.unit)
    end

    local caster = self.caster
    if not IsValidEntitySafe(caster) then return end
    local anyAlive = false
    if caster.mazellov_f_units then
        for i = 1,4 do
            local u = caster.mazellov_f_units[i]
            if IsValidEntitySafe(u) and u:IsAlive() then
                anyAlive = true
                break
            end
        end
    end

    if not self.hit and not anyAlive then
        caster.mazellov_f_orb_index = 1
    end
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
    self.damage   = self:GetAbility():GetSpecialValueFor("dot_damage")
    self.interval = self:GetAbility():GetSpecialValueFor("dot_interval")
    self:StartIntervalThink(self.interval)

    local p = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_burn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(p, false, false, -1, false, false)
end
function modifier_mazellov_f_dot:OnIntervalThink()
    ApplyDamage({
        victim = self:GetParent(), attacker = self:GetCaster(),
        damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()
    })
end

modifier_mazellov_f_slow = class({})
function modifier_mazellov_f_slow:IsDebuff() return true end
function modifier_mazellov_f_slow:IsPurgable() return true end
function modifier_mazellov_f_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_mazellov_f_slow:GetModifierMoveSpeedBonus_Percentage()
    return -self:GetAbility():GetSpecialValueFor("slow_pct")
end
function modifier_mazellov_f_slow:GetEffectName() return "particles/pugna_decrepify_b.vpcf" end
function modifier_mazellov_f_slow:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

modifier_mazellov_f_resist_reduction = class({})
function modifier_mazellov_f_resist_reduction:IsDebuff() return true end
function modifier_mazellov_f_resist_reduction:IsPurgable() return true end
function modifier_mazellov_f_resist_reduction:DeclareFunctions() return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS } end
function modifier_mazellov_f_resist_reduction:GetModifierMagicalResistanceBonus()
    return -self:GetAbility():GetSpecialValueFor("magic_resist_reduction")
end
function modifier_mazellov_f_resist_reduction:GetEffectName()
    return "particles/units/heroes/hero_antimage/antimage_manabreak_enemy_debuff.vpcf"
end
function modifier_mazellov_f_resist_reduction:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

modifier_mazellov_f_miss_chance = class({})
function modifier_mazellov_f_miss_chance:IsDebuff() return true end
function modifier_mazellov_f_miss_chance:IsPurgable() return true end
function modifier_mazellov_f_miss_chance:DeclareFunctions() return { MODIFIER_PROPERTY_MISS_PERCENTAGE } end
function modifier_mazellov_f_miss_chance:GetModifierMiss_Percentage()
    return self:GetAbility():GetSpecialValueFor("miss_chance")
end
function modifier_mazellov_f_miss_chance:GetEffectName()
    return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_debuff.vpcf"
end
function modifier_mazellov_f_miss_chance:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
