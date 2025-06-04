LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)

Ashab_rocket = class({})

function Ashab_rocket:Precache(context)
    PrecacheResource("soundfile", "soundevents/rocket.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/rocket_hit.vsndevts", context)
    PrecacheResource("particle", "particles/clockwerk_para_rocket_flare_mew.vpcf", context)
end

function Ashab_rocket:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    EmitSoundOn("rocket", caster)
    local info = {Source = caster, Ability = self, EffectName = "particles/clockwerk_para_rocket_flare_mew.vpcf", iMoveSpeed = 600, bDodgeable = true, bProvidesVision = false}
    for _, enemy in pairs(enemies) do
        info.Target = enemy
        ProjectileManager:CreateTrackingProjectile(info)
    end
end

function Ashab_rocket:OnProjectileHit(target, location)
    if not target or target:IsNull() then return end
    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor("damage")
    local stun_duration = self:GetSpecialValueFor("stun_duration")
    local gold = self:GetSpecialValueFor("gold")
    EmitSoundOn("rocket_hit", target)
    target:AddNewModifier(caster, self, "modifier_generic_stunned_lua", {duration = stun_duration})
    local damageTable = {victim = target, attacker = caster, damage = damage, damage_type = self:GetAbilityDamageType(), ability = self}
    ApplyDamage(damageTable)
    if not target:IsIllusion() and gold > 0 then
        caster:ModifyGold(gold, false, 0)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, caster, gold, nil)
    end
end