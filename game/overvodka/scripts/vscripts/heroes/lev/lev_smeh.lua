LinkLuaModifier("modifier_lev_smeh_debuff", "heroes/lev/lev_smeh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lev_smeh_debuff_2", "heroes/lev/lev_smeh", LUA_MODIFIER_MOTION_NONE)

lev_smeh = class({})

function lev_smeh:Precache(context)
    PrecacheResource("soundfile", "soundevents/smeh.vsndevts", context)
    PrecacheResource("particle", "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_ti6.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_ti6_knockback_debuff.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_ti6_debuff_feet.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_disarm_ti6_debuff.vpcf", context)
end

function lev_smeh:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local cursor = self:GetCursorPosition()
    local origin = caster:GetAbsOrigin()
    local direction = cursor - origin
    direction.z = 0

    if direction:Length2D() < 1 then
        direction = caster:GetForwardVector()
        direction.z = 0
    end

    direction = direction:Normalized()

    local spawn_origin = origin
    local attach_hitloc = caster:ScriptLookupAttachment("attach_hitloc")
    if attach_hitloc ~= 0 then
        spawn_origin = caster:GetAttachmentOrigin(attach_hitloc)
    end

    ProjectileManager:CreateLinearProjectile({
        Ability = self,
        EffectName = "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_ti6.vpcf",
        vSpawnOrigin = spawn_origin,
        fDistance = self:GetSpecialValueFor("distance"),
        fStartRadius = 175,
        fEndRadius = 225,
        Source = caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        bDeleteOnHit = false,
        vVelocity = direction * 900,
        bProvidesVision = true,
        iVisionRadius = 400,
        iVisionTeamNumber = caster:GetTeamNumber(),
    })

    EmitSoundOn("smeh", caster)
end

function lev_smeh:OnProjectileHit(target, location)
    if not IsServer() then return end
    if not target or target:IsNull() then
        return false
    end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then
        return false
    end

    local caster_pos = caster:GetAbsOrigin()
    local target_pos = target:GetAbsOrigin()
    local knockback_distance = math.max(self:GetSpecialValueFor("distance") - (target_pos - caster_pos):Length2D(), 100)

    target:AddNewModifier(caster, self, "modifier_knockback", {
        center_x = caster_pos.x,
        center_y = caster_pos.y,
        center_z = caster_pos.z,
        duration = 1.25,
        knockback_duration = 1.25,
        knockback_distance = knockback_distance,
        knockback_height = 0,
        should_stun = 0,
    })

    target:AddNewModifier(caster, self, "modifier_lev_smeh_debuff", {
        duration = 1.25,
    })

    return false
end

modifier_lev_smeh_debuff = class({})

function modifier_lev_smeh_debuff:IsHidden() return true end
function modifier_lev_smeh_debuff:IsPurgable() return false end
function modifier_lev_smeh_debuff:IsDebuff() return true end

function modifier_lev_smeh_debuff:OnCreated()
    if not IsServer() then return end

    local ability = self:GetAbility()
    if not ability then
        self:Destroy()
        return
    end

    local caster = self:GetCaster()
    local parent = self:GetParent()

    ApplyDamage({
        victim = parent,
        attacker = caster,
        damage = ability:GetSpecialValueFor("damage"),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = ability,
    })

    local particle = ParticleManager:CreateParticle(
        "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_ti6_knockback_debuff.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        parent
    )
    self:AddParticle(particle, false, false, -1, false, false)

    particle = ParticleManager:CreateParticle(
        "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_ti6_debuff_feet.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        parent
    )
    self:AddParticle(particle, false, false, -1, false, false)

    self:StartIntervalThink(0.03)
end

function modifier_lev_smeh_debuff:OnIntervalThink()
    if not IsServer() then return end
    GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 100, false)
end

function modifier_lev_smeh_debuff:OnDestroy()
    if not IsServer() then return end

    local ability = self:GetAbility()
    local parent = self:GetParent()
    if not ability or not parent or parent:IsNull() or not parent:IsAlive() then
        return
    end

    parent:AddNewModifier(self:GetCaster(), ability, "modifier_lev_smeh_debuff_2", {
        duration = ability:GetSpecialValueFor("duration"),
    })
end

modifier_lev_smeh_debuff_2 = class({})

function modifier_lev_smeh_debuff_2:IsHidden() return false end
function modifier_lev_smeh_debuff_2:IsPurgable() return true end
function modifier_lev_smeh_debuff_2:IsDebuff() return true end

function modifier_lev_smeh_debuff_2:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_lev_smeh_debuff_2:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow_pct")
end

function modifier_lev_smeh_debuff_2:CheckState()
    return {
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }
end

function modifier_lev_smeh_debuff_2:GetEffectName()
    return "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_disarm_ti6_debuff.vpcf"
end

function modifier_lev_smeh_debuff_2:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
