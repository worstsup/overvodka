minion_banana = class({})

LinkLuaModifier("modifier_minion_banana_debuff", "units/minion/minion_banana", LUA_MODIFIER_MOTION_NONE)

function minion_banana:OnSpellStart()
    local caster = self:GetCaster()
    local target_point = self:GetCursorPosition()
    local projectile_speed = self:GetSpecialValueFor("banana_speed")
    local radius = self:GetSpecialValueFor("banana_radius")

    local projectile = {
        Target = target_point,
        Source = caster,
        Ability = self,
        EffectName = "particles/units/heroes/hero_monkey_king/monkey_king_strike.vpcf",
        iMoveSpeed = projectile_speed,
        vSpawnOrigin = caster:GetAbsOrigin(),
        bDodgeable = false,
        bProvidesVision = true,
        iVisionRadius = 300,
        iVisionTeamNumber = caster:GetTeamNumber(),
        ExtraData = {radius = radius}
    }

    ProjectileManager:CreateLinearProjectile(projectile)
    caster:EmitSound("Hero_MonkeyKing.IllusoryOrb")  -- Use a banana-like sound
end

function minion_banana:OnProjectileHit_ExtraData(target, location, extraData)
    if not location then return end

    local caster = self:GetCaster()
    local radius = extraData.radius
    local root_duration = self:GetSpecialValueFor("root_duration")
    local slow_amount = self:GetSpecialValueFor("banana_slow")

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
        enemy:AddNewModifier(caster, self, "modifier_minion_banana_debuff", {duration = root_duration, slow = slow_amount})
    end

    EmitSoundOnLocationWithCaster(location, "Hero_MonkeyKing.Spring.Target", caster)
end


modifier_minion_banana_debuff = class({})

function modifier_minion_banana_debuff:IsDebuff() return true end
function modifier_minion_banana_debuff:IsPurgable() return true end
function modifier_minion_banana_debuff:GetEffectName()
    return "particles/generic_gameplay/generic_root.vpcf"
end

function modifier_minion_banana_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_minion_banana_debuff:OnCreated(kv)
    if not IsServer() then return end
    self.slow = kv.slow
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_rooted", {duration = self:GetDuration()})
end

function modifier_minion_banana_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_minion_banana_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -self.slow
end
