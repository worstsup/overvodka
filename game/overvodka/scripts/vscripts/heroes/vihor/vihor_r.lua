LinkLuaModifier("modifier_vihor_r", "heroes/vihor/vihor_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_vihor_r_debuff", "heroes/vihor/vihor_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )

vihor_ultimate = class({})
function vihor_ultimate:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_gyrocopter/gyro_death_explosion.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/techies/techies_arcana/techies_suicide_arcana.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_marci/marci_bodyguard_radius_glow.vpcf", context)
    PrecacheResource("particle", "particles/vihor_r_start.vpcf", context)
    PrecacheResource("particle", "particles/vihor_r.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/arc_warden/arc_warden_frostivus_2023/arc_warden_magnetic_frostivus_start.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/antimage/antimage_ti7/antimage_blink_start_ti7_flame.vpcf", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_shredder.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/vihor_r_start.vsndevts", context )
	PrecacheResource("soundfile", "soundevents/vihor_r.vsndevts", context )
end

function vihor_ultimate:OnAbilityPhaseStart()
    local particle_2 = ParticleManager:CreateParticle("particles/econ/items/arc_warden/arc_warden_frostivus_2023/arc_warden_magnetic_frostivus_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    local particle_3 = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_ti7/antimage_blink_start_ti7_flame.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    EmitSoundOn("vihor_r_start", self:GetCaster())
end

function vihor_ultimate:OnAbilityPhaseInterrupted()
    StopSoundOn("vihor_r_start", self:GetCaster())
end

function vihor_ultimate:OnSpellStart()
    if not IsServer() then return end
    local duration_to_explosion = self:GetSpecialValueFor("duration_to_explosion")
    AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), self:GetSpecialValueFor("radius"), duration_to_explosion, false)
    if not global_sounds_muted then
        EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), "vihor_r", self:GetCaster())
    end
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
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_marci/marci_bodyguard_radius_glow.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius + 50, self.radius + 50, self.radius + 50))
    self:AddParticle(particle, false, false, -1, false, false)
    self:StartIntervalThink(0.1)
end

function modifier_vihor_r:OnIntervalThink()
    if not IsServer() then return end
    local units = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false )
    for _, unit in pairs(units) do
        if not unit:HasModifier("modifier_vihor_r_debuff") and not unit:HasModifier("modifier_black_king_bar_immune") and not unit:HasModifier("modifier_macan_r") and not unit:IsDebuffImmune() then
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
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false )
    local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
    for _, unit in pairs(units) do
        unit:RemoveModifierByName("modifier_vihor_r_debuff")
        ApplyDamage({ victim = unit, attacker = self:GetCaster(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() })
        if unit and not unit:IsNull() then
            unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_generic_stunned_lua", {duration = stun_duration})
        end
    end
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
    self.bonus_attack_range = 1000
    self.min_health = 1
    self.target = self:GetCaster():GetAbsOrigin() + RandomVector(100)
    self.tick_damage = self:GetAbility():GetSpecialValueFor("tick_damage")
    self.interval = 0.2
    self.next_order_time = 0.0
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self:GetParent():Stop()
    self:GetParent():Interrupt()
    self:GetParent():SetIdleAcquire(false)
    self:GetParent():SetAcquisitionRange(0)
    self:GetParent():SetForceAttackTarget(nil)
    self:IssueAttackOrder()
    self:StartIntervalThink(self.interval)
end

local function IsValidDebuffedEnemy(u)
    return u and not u:IsNull() and u:IsAlive()
        and u:HasModifier("modifier_vihor_r_debuff")
        and not u:IsDebuffImmune()
        and not u:HasModifier("modifier_black_king_bar_immune")
end

function modifier_vihor_r_debuff:IssueAttackOrder()
    if not IsServer() then return end
    local parent = self:GetParent()
    local caster = self:GetCaster()

    local pool = FindUnitsInRadius(
        caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false
    )

    local target, bestDist = nil, 1e18
    local myPos = parent:GetAbsOrigin()
    for _,u in ipairs(pool) do
        if u ~= parent and IsValidDebuffedEnemy(u) then
            local d = (u:GetAbsOrigin() - myPos):Length2D()
            if d < bestDist then
                bestDist = d
                target = u
            end
        end
    end

    if target then
        parent:SetForceAttackTarget(target)
        parent:MoveToTargetToAttack(target)
    else
        parent:SetForceAttackTarget(nil)
        parent:MoveToPosition(caster:GetAbsOrigin())
    end

    self.next_order_time = GameRules:GetGameTime() + 1.25
end

function modifier_vihor_r_debuff:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()
    local caster = self:GetCaster()

    if not parent or parent:IsNull() then self:Destroy(); return end
    if not caster or caster:IsNull() then self:Destroy(); return end
    if not caster:HasModifier("modifier_vihor_r") then self:Destroy(); return end

    local r = self.radius or (self:GetAbility() and self:GetAbility():GetSpecialValueFor("radius")) or 0
    local dist = (parent:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
    if dist > r then self:Destroy(); return end

    local dps = self.tick_damage * parent:GetMaxHealth() * 0.01
    local dmg = dps * self.interval
    if GetMapName() == "overvodka_5x5" then
        dmg = dmg + self:GetAbility():GetSpecialValueFor("dota_damage") * self.interval
    end
    if parent:GetHealthPercent() <= 3 then
        self.min_health = 0
        parent:Kill(self:GetAbility(), caster)
        return
    end
    ApplyDamage({
        victim = parent, attacker = caster, damage = dmg,
        damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self:GetAbility()
    })

    AddFOWViewer(parent:GetTeamNumber(), caster:GetAbsOrigin(), self.radius, self.interval, false)
    if not parent:IsMoving() then
        parent:MoveToPosition(caster:GetAbsOrigin())
    end

    local now = GameRules:GetGameTime()
    if now >= (self.next_order_time or 0) then
        self:IssueAttackOrder()
    end
end

function modifier_vihor_r_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
        MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_EVENT_ON_ATTACK_START,
    }
end

function modifier_vihor_r_debuff:GetMinHealth()
    return self.min_health
end

function modifier_vihor_r_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end

function modifier_vihor_r_debuff:GetModifierAttackRangeBonus()
    return self.bonus_attack_range
end

function modifier_vihor_r_debuff:GetModifierFixedAttackRate()
    return 0.3
end

function modifier_vihor_r_debuff:OnAttackStart(params)
    if not IsServer() then return end
    if params.attacker ~= self.parent then return end
    local tgt = params.target
    if not IsValidDebuffedEnemy(tgt) then
        self.parent:Interrupt()
        self.parent:Stop()
        self:IssueAttackOrder()
    end
end

function modifier_vihor_r_debuff:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    if not parent:IsNull() then
        parent:SetForceAttackTarget(nil)
        parent:Stop()
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