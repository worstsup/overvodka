LinkLuaModifier("modifier_dave_scepter", "heroes/dave/dave_scepter", LUA_MODIFIER_MOTION_NONE)

dave_scepter = class({})

function dave_scepter:Precache(context)
    PrecacheResource("particle", "particles/dave_missile.vpcf", context)
    PrecacheResource("soundfile", "soundevents/dave_scepter.vsndevts", context)
end

function dave_scepter:GetIntrinsicModifierName()
    return "modifier_dave_scepter"
end

modifier_dave_scepter = class({})

function modifier_dave_scepter:IsHidden() return true end
function modifier_dave_scepter:IsPurgable() return false end
function modifier_dave_scepter:RemoveOnDeath() return false end

function modifier_dave_scepter:DeclareFunctions()
    return { MODIFIER_EVENT_ON_DEATH }
end

function modifier_dave_scepter:OnDeath(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    EmitSoundOn("dave_scepter", parent)
    if params.unit ~= parent then return end
    local killer = params.attacker
    if not killer or not killer:IsHero() then return end
    local projectile_info = {
        Target = killer,
        Source = parent,
        Ability = self:GetAbility(),
        EffectName = "particles/dave_missile.vpcf",
        iMoveSpeed = 600,
        vSourceLoc = parent:GetAbsOrigin(),
        bDodgeable = true,
        bProvidesVision = false,
    }

    ProjectileManager:CreateTrackingProjectile(projectile_info)
end

function dave_scepter:OnProjectileHit(target, location)
    if not target then return end

    local max_hp = target:GetMaxHealth()
    local damage = max_hp * 0.25
    ApplyDamage({
        victim = target,
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = DAMAGE_TYPE_PURE,
        ability = self,
    })
end
