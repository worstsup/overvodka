minion_banana = class({})

LinkLuaModifier("modifier_minion_banana_root_debuff", "units/minion/minion_banana", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_minion_banana_movespeed_debuff", "units/minion/minion_banana", LUA_MODIFIER_MOTION_NONE)

function minion_banana:GetAOERadius()
    return self:GetSpecialValueFor("banana_radius")
end

function minion_banana:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target_point = self:GetCursorPosition()
    local projectile_speed = self:GetSpecialValueFor("banana_speed")
    local radius = self:GetSpecialValueFor("banana_radius")

    local direction = (target_point - caster:GetAbsOrigin()):Normalized()
    local distance = (target_point - caster:GetAbsOrigin()):Length2D()
    local projectile = {
        Ability = self,
        EffectName = "particles/minion_banana.vpcf",
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = distance,
        fStartRadius = 100,
        fEndRadius = 120,
        Source = caster,
        vVelocity = direction * projectile_speed,
        bDodgeable = false,
        bProvidesVision = true,
        iVisionRadius = 300,
        iVisionTeamNumber = caster:GetTeamNumber(),
        ExtraData = {radius = radius}
    }

    ProjectileManager:CreateLinearProjectile(projectile)
    EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "minion_banana", caster)
    EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "minion_banana_hello", caster)
end


function minion_banana:OnProjectileHit_ExtraData(target, location, extraData)
    if not location then return end

    local caster = self:GetCaster()
    local radius = extraData.radius
    local root_duration = self:GetSpecialValueFor("root_duration")
    local banana_slow = self:GetSpecialValueFor("banana_slow")
    local slow_duration = self:GetSpecialValueFor("slow_duration")

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        location,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in ipairs(enemies) do
        enemy:AddNewModifier(caster, self, "modifier_minion_banana_root_debuff", {duration = root_duration})
        enemy:AddNewModifier(caster, self, "modifier_minion_banana_movespeed_debuff", {duration = slow_duration})
    end

    EmitSoundOnLocationWithCaster(location, "Hero_MonkeyKing.Spring.Target", caster)
end


modifier_minion_banana_root_debuff = class({})

function modifier_minion_banana_root_debuff:IsDebuff() return true end
function modifier_minion_banana_root_debuff:IsPurgable() return true end

function modifier_minion_banana_root_debuff:GetEffectName()
    return "particles/minion_banana_root.vpcf"
end

function modifier_minion_banana_root_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_minion_banana_root_debuff:OnCreated(kv)
    if not IsServer() then return end
end

function modifier_minion_banana_root_debuff:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true
    }
end


modifier_minion_banana_movespeed_debuff = class({})

function modifier_minion_banana_movespeed_debuff:IsDebuff() return true end
function modifier_minion_banana_movespeed_debuff:IsPurgable() return true end

function modifier_minion_banana_movespeed_debuff:OnCreated(kv)
    if not IsServer() then return end
end

function modifier_minion_banana_movespeed_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_minion_banana_movespeed_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("banana_slow")
end


