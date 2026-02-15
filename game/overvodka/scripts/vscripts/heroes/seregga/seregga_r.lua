LinkLuaModifier("modifier_seregga_r_field", "heroes/seregga/seregga_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_seregga_r_debuff", "heroes/seregga/seregga_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_seregga_innate_proc", "heroes/seregga/seregga_innate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_seregga_r_ally_aura", "heroes/seregga/seregga_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_seregga_r_reveal", "heroes/seregga/seregga_r", LUA_MODIFIER_MOTION_NONE)

seregga_r = class({})

function seregga_r:Precache(ctx)
    PrecacheResource("particle", "particles/seregga_r.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/seregga_sounds.vsndevts", ctx)
end

function seregga_r:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function seregga_r:OnSpellStart()
    if not IsServer() then return end
    local caster  = self:GetCaster()
    local point   = self:GetCursorPosition()
    local dur     = self:GetSpecialValueFor("duration")
    local radius  = self:GetSpecialValueFor("radius")

    local thinker = CreateModifierThinker(
        caster, self, "modifier_seregga_r_field",
        {duration = dur}, point, caster:GetTeamNumber(), false
    )
end


modifier_seregga_r_field = class({})

function modifier_seregga_r_field:IsHidden() return true end
function modifier_seregga_r_field:IsPurgable() return false end
function modifier_seregga_r_field:IsAura() return true end

function modifier_seregga_r_field:GetAuraRadius()
    return self.radius or self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_seregga_r_field:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_seregga_r_field:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_seregga_r_field:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_seregga_r_field:GetModifierAura()
    return "modifier_seregga_r_debuff"
end

function modifier_seregga_r_field:OnCreated()
    if not IsServer() then return end
    self.ability   = self:GetAbility()
    self.parent    = self:GetParent()
    self.caster    = self:GetCaster()

    self.radius         = self.ability:GetSpecialValueFor("radius")
    self.slow_pct       = self.ability:GetSpecialValueFor("slow_pct")
    self.wall_width     = self.ability:GetSpecialValueFor("wall_width")
    self.min_edge_speed = self.ability:GetSpecialValueFor("min_edge_speed")
    self.max_edge_bonus = self.ability:GetSpecialValueFor("max_edge_bonus")

    self.origin = self.parent:GetAbsOrigin()

    self.pfx = ParticleManager:CreateParticle("particles/seregga_r.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.pfx, 0, self.origin)
    ParticleManager:SetParticleControl(self.pfx, 1, Vector(self.radius, 0, 0))
    if not global_sounds_muted then
        EmitSoundOnLocationWithCaster(self.origin, "seregga_r", self.caster)
    end
    if self.caster:HasTalent("special_bonus_unique_seregga_8") then
        self.parent:AddNewModifier(
            self.caster,
            self.ability,
            "modifier_seregga_r_ally_aura",
            { duration = self:GetRemainingTime() }
        )
    end
end

function modifier_seregga_r_field:OnDestroy()
    if not IsServer() then return end
    UTIL_Remove(self.parent)
    if self.pfx then
        ParticleManager:DestroyParticle(self.pfx, false)
        ParticleManager:ReleaseParticleIndex(self.pfx)
        self.pfx = nil
    end
end

modifier_seregga_r_debuff = class({})

function modifier_seregga_r_debuff:IsHidden() return false end
function modifier_seregga_r_debuff:IsPurgable() return false end
function modifier_seregga_r_debuff:IsDebuff() return true end

function modifier_seregga_r_debuff:OnCreated()
    self.parent  = self:GetParent()
    self.caster  = self:GetCaster()
    self.ability = self:GetAbility()

    self.slow_pct       = self.ability:GetSpecialValueFor("slow_pct")
    self.radius         = self.ability:GetSpecialValueFor("radius")
    self.wall_width     = self.ability:GetSpecialValueFor("wall_width")
    self.min_speed      = self.ability:GetSpecialValueFor("min_edge_speed")
    self.max_edge_bonus = self.ability:GetSpecialValueFor("max_edge_bonus")

    local thinker = self:GetAuraOwner()
    if thinker and not thinker:IsNull() then
        self.aura_origin = thinker:GetAbsOrigin()
    else
        self.aura_origin = self.parent:GetAbsOrigin()
    end

    self.max_min = self.max_edge_bonus
    self.inside = true
    self.last_pos = self.parent:GetAbsOrigin()

    self.timer = 0.3
    self:StartIntervalThink(FrameTime())
    self:OnIntervalThink()
end

function modifier_seregga_r_debuff:OnIntervalThink()
    if not IsServer() then return end
    local parent = self.parent
    if not parent or parent:IsNull() then return end

    local pos = parent:GetAbsOrigin()
    local last = self.last_pos or pos
    local moved = (pos - last):Length2D()

    if moved > 1000 then
        self:Destroy()
        return
    end

    self.timer = self.timer + FrameTime()
    if self.timer >= 0.3 then
        self.timer = 0.0
        parent:RemoveModifierByName("modifier_seregga_r_reveal")
        parent:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_seregga_r_reveal", { duration = 0.4 })
    end

    if parent:IsDebuffImmune() or parent:IsMagicImmune() or parent:IsInvulnerable() then
        self.last_pos = pos
        return
    end

    local v = pos - self.aura_origin
    local dist = v:Length2D()

    if dist > self.radius then
        local dir = v:Normalized()
        local back_pos = self.aura_origin + dir * (self.radius - 2)
        parent:InterruptMotionControllers(true)
        parent:RemoveModifierByName("modifier_knockback")
        parent:RemoveModifierByName("modifier_generic_knockback_lua")
        FindClearSpaceForUnit(parent, back_pos, true)
        ResolveNPCPositions(back_pos, 64)
    end

    self.last_pos = parent:GetAbsOrigin()
end

function modifier_seregga_r_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    }
end

function modifier_seregga_r_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -math.abs(self.slow_pct or 0)
end

function modifier_seregga_r_debuff:GetModifierMoveSpeed_Limit(params)
    if not IsServer() then return 0 end

    local parent = self.parent or self:GetParent()
    if not parent or parent:IsNull() then return 0 end

    local parent_vector  = parent:GetAbsOrigin() - self.aura_origin
    local dist           = parent_vector:Length2D()
    if dist < 0.01 then return 0 end

    local dir_from_center = parent_vector:Normalized()
    local wall_distance   = dist - self.radius
    local over_walls      = false

    if self.inside ~= (wall_distance < 0) then
        if math.abs(wall_distance) > self.wall_width then
            self.inside = not self.inside
        else
            over_walls = true
        end
    end

    local distance_abs = math.abs(wall_distance)

    if distance_abs > self.wall_width then
        return 0
    end

    local parent_angle
    if self.inside then
        parent_angle = VectorToAngles(dir_from_center).y
    else
        parent_angle = VectorToAngles(-dir_from_center).y
    end
    local unit_angle = parent:GetAnglesAsVector().y
    local wall_angle = math.abs( AngleDiff(parent_angle, unit_angle) )

    if wall_angle <= 90 then
        local limit
        if over_walls then
            limit = self.min_speed
        else
            local t = distance_abs / self.wall_width
            limit = self.min_speed + t * self.max_min
        end
        return math.max(self.min_speed, limit)
    end

    return 0
end

function modifier_seregga_r_debuff:CheckState()
    return {
        [MODIFIER_STATE_TETHERED] = true,
        [MODIFIER_STATE_PROVIDES_VISION] = true,
    }
end

function modifier_seregga_r_debuff:OnDestroy()
    if not IsServer() then return end
end

modifier_seregga_r_ally_aura = class({})

function modifier_seregga_r_ally_aura:IsHidden() return true end
function modifier_seregga_r_ally_aura:IsPurgable() return false end
function modifier_seregga_r_ally_aura:IsAura() return true end

function modifier_seregga_r_ally_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_seregga_r_ally_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_seregga_r_ally_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_seregga_r_ally_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_seregga_r_ally_aura:GetModifierAura()
    return "modifier_seregga_innate_proc"
end

function modifier_seregga_r_ally_aura:GetAuraDuration()
    return 0.3
end

modifier_seregga_r_reveal = class({})

function modifier_seregga_r_reveal:IsHidden() return true end
function modifier_seregga_r_reveal:IsPurgable() return false end
function modifier_seregga_r_reveal:GetPriority() return MODIFIER_PRIORITY_HIGH end

function modifier_seregga_r_reveal:CheckState()
    return {
        [MODIFIER_STATE_INVISIBLE] = false,
    }
end
