LinkLuaModifier( "modifier_chara_w", "heroes/chara/chara_w", LUA_MODIFIER_MOTION_NONE )

chara_w = class({})

function chara_w:Precache(ctx)
    PrecacheResource( "soundfile", "soundevents/chara_sounds.vsndevts", ctx )
    PrecacheResource( "particle", "particles/chara_w.vpcf", ctx )
end

function chara_w:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local point  = self:GetCursorPosition()
    local dir = point - caster:GetAbsOrigin(); dir.z = 0
    if dir:Length2D() < 1 then dir = caster:GetForwardVector() end
    dir = dir:Normalized()

    local width    = self:GetSpecialValueFor("radius")
    local distance = self:GetSpecialValueFor("range")
    local speed    = 999

    self._cur_cast_id = (self._cur_cast_id or 0) + 1
    self._cur_hits    = {}
    local cast = self._cur_cast_id

    local function fire(vdir)
        ProjectileManager:CreateLinearProjectile({
            Source = caster,
            Ability = self,
            vSpawnOrigin = caster:GetAbsOrigin(),

            iUnitTargetTeam  = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType  = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,

            EffectName   = "particles/chara_w.vpcf",
            fDistance    = distance,
            fStartRadius = width,
            fEndRadius   = width,
            vVelocity    = vdir * speed,
            bProvidesVision   = true,
            iVisionRadius     = width,
            iVisionTeamNumber = caster:GetTeamNumber(),
            bDeleteOnHit = false,

            ExtraData = { cast = cast }
        })
    end

    fire(dir)

    if self:GetSpecialValueFor("more_waves") > 0 then
        local left  = RotatePosition(Vector(0,0,0), QAngle(0,  45, 0), dir)
        local right = RotatePosition(Vector(0,0,0), QAngle(0, -45, 0), dir)
        fire(left); fire(right)
    end

    self:GetCaster():EmitSound("chara_w")
end


function chara_w:OnProjectileHit_ExtraData(target, pos, data)
    if not IsServer() or not target then return end

    local cur_cast = self._cur_cast_id or -1
    local cast     = tonumber(data and data.cast or -1)

    if cast == cur_cast then
        self._cur_hits = self._cur_hits or {}
        local eid = target:entindex()
        if self._cur_hits[eid] then
            return
        end
        self._cur_hits[eid] = true
    end

    local duration = self:GetSpecialValueFor("duration")
    target:AddNewModifier(self:GetCaster(), self, "modifier_chara_w",
        { duration = duration * (1 - target:GetStatusResistance()) })
    local damage = self:GetSpecialValueFor("damage") + self:GetSpecialValueFor("damage_pct") * target:GetMaxHealth() * 0.01
    ApplyDamage({
        victim = target,
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = self:GetAbilityDamageType(),
        ability = self,
    })
end


modifier_chara_w = class({})

function modifier_chara_w:IsHidden() return false end
function modifier_chara_w:IsPurgable() return true end

function modifier_chara_w:DeclareFunctions()
    return { MODIFIER_PROPERTY_MISS_PERCENTAGE }
end

function modifier_chara_w:GetModifierMiss_Percentage()
    return self:GetAbility():GetSpecialValueFor("miss_chance")
end
