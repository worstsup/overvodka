serega_sven = class({})
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_serega_sven",        "heroes/pirat/serega_sven",     LUA_MODIFIER_MOTION_NONE)

local function Rotate2D(vec, degrees)
    local rad = math.rad(degrees)
    local c, s = math.cos(rad), math.sin(rad)
    return Vector(vec.x * c - vec.y * s, vec.x * s + vec.y * c, 0)
end

function serega_sven:Precache(ctx)
	PrecacheResource("particle", "particles/econ/items/nyx_assassin/nyx_assassin_ti6/nyx_assassin_impale_ti6.vpcf", ctx)
	PrecacheResource("particle", "particles/econ/items/nyx_assassin/nyx_assassin_ti6/nyx_assassin_impale_hit_ti6.vpcf", ctx)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_lion.vsndevts", ctx)
	PrecacheResource("soundfile", "soundevents/serega_sven.vsndevts", ctx)
	PrecacheResource("model", "litvin/models/heroes/lit/sven_new.vmdl", ctx)
end

function serega_sven:OnSpellStart()
	if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if target and not target:IsNull() and target:TriggerSpellAbsorb(self) then
        return
    end
    self._hitUnits = {}
    local origin = caster:GetAbsOrigin()
    local aimPos = target:GetAbsOrigin()
    local dir = aimPos - origin
    dir.z = 0
    if dir:Length2D() < 1 then
        dir = caster:GetForwardVector()
        dir.z = 0
    end
    dir = dir:Normalized()

    local distance = (aimPos - origin):Length2D()
    local radius   = self:GetSpecialValueFor("width")
    local speed    = self:GetSpecialValueFor("speed")
    local stun     = self:GetSpecialValueFor("duration")
    if target and not target:IsNull() and target:IsRealHero() then
        local travel = distance / math.max(speed, 1)
        target:AddNewModifier(caster, self, "modifier_serega_sven", { duration = travel + stun })
    end

    local projectile_name = "particles/econ/items/nyx_assassin/nyx_assassin_ti6/nyx_assassin_impale_ti6.vpcf"

    local function Fire(dir2d)
        local info = {
            Source = caster,
            Ability = self,
            vSpawnOrigin = origin,
            bDeleteOnHit = false,

            iUnitTargetTeam  = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType  = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,

            EffectName  = projectile_name,
            fDistance   = distance,
            fStartRadius= radius,
            fEndRadius  = radius,
            vVelocity   = dir2d * speed,
        }
        ProjectileManager:CreateLinearProjectile(info)
    end

    Fire(dir)
    Fire(Rotate2D(dir,  30))
    Fire(Rotate2D(dir, -30))

    EmitSoundOn("serega_sven", caster)
end

function serega_sven:OnProjectileHit(target, location)
	if not IsServer() then return end
    if not target or target:IsNull() then return end
    local eid = target:entindex()
    if self._hitUnits and self._hitUnits[eid] then
        return
    end
    self._hitUnits = self._hitUnits or {}
    self._hitUnits[eid] = true

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local stun   = self:GetSpecialValueFor("duration")
    local damage = self:GetAbilityDamage()

    target:AddNewModifier(caster, self, "modifier_generic_stunned_lua", { duration = stun })

    target:AddNewModifier(caster, self, "modifier_knockback", {
        center_x = 0, center_y = 0, center_z = 0,
        duration = 0.5,
        knockback_duration = 0.5,
        knockback_distance = 0,
        knockback_height   = 350,
    })

    if target:IsRealHero() and not target:HasModifier("modifier_serega_sven") then
        target:AddNewModifier(caster, self, "modifier_serega_sven", { duration = stun })
    end

    EmitSoundOn("Hero_Lion.ImpaleTargetLand", target)
    self:PlayEffects(target)
	ApplyDamage({
        victim      = target,
        attacker    = caster,
        damage      = damage,
        damage_type = self:GetAbilityDamageType(),
        ability     = self,
    })
end

function serega_sven:PlayEffects(target)
    local fx = ParticleManager:CreateParticle(
        "particles/econ/items/nyx_assassin/nyx_assassin_ti6/nyx_assassin_impale_hit_ti6.vpcf",
        PATTACH_ABSORIGIN_FOLLOW, target
    )
    ParticleManager:ReleaseParticleIndex(fx)
    EmitSoundOn("Hero_Lion.ImpaleHitTarget", target)
end

modifier_serega_sven = class({})

function modifier_serega_sven:IsPurgable() return false end
function modifier_serega_sven:IsHidden()   return true  end

function modifier_serega_sven:OnCreated()
    if not IsServer() then return end
    if self:GetParent():GetModelName() == "models/bratishkin/knight/base.vmdl" then
        self:Destroy()
    end
end

function modifier_serega_sven:DeclareFunctions()
    return { MODIFIER_PROPERTY_MODEL_CHANGE }
end

function modifier_serega_sven:GetModifierModelChange()
    return "litvin/models/heroes/lit/sven_new.vmdl"
end
