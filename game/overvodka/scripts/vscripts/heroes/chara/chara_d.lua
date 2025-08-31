LinkLuaModifier("modifier_chara_d_exhaust", "heroes/chara/chara_d", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chara_d_double",  "heroes/chara/chara_d", LUA_MODIFIER_MOTION_NONE)

chara_d = class({})

function chara_d:Precache(ctx)
    PrecacheResource("particle", "particles/chara_d_knife.vpcf", ctx)
    PrecacheResource("particle", "particles/chara_d_knife_red.vpcf", ctx)
    PrecacheResource("particle", "particles/chara_break.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/chara_sounds.vsndevts", ctx)
end

function chara_d:FireKnives(caster)
    if not IsServer() then return end
    if not caster or caster:IsNull() then return end

    local origin       = caster:GetAbsOrigin()
    local count        = self:GetSpecialValueFor("knife_count")
    local distance     = self:GetSpecialValueFor("knife_distance")
    local width        = self:GetSpecialValueFor("knife_width")
    local speed        = self:GetSpecialValueFor("knife_speed")
    local shardChance  = self:GetSpecialValueFor("shard_chance")

    for i = 0, count - 1 do
        local angle = (2*math.pi) * i / count
        local dir   = Vector(math.cos(angle), math.sin(angle), 0):Normalized()

        local is_red = 0
        if caster:HasShard() and RollPercentage(shardChance) then
            is_red = 1
        end

        local info = {
            Source = caster,
            Ability = self,
            vSpawnOrigin = origin,

            iUnitTargetTeam  = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType  = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,

            EffectName  = (is_red == 1) and "particles/chara_d_knife_red.vpcf" or "particles/chara_d_knife.vpcf",
            fDistance   = distance,
            fStartRadius= width,
            fEndRadius  = width,
            vVelocity   = dir * speed,

            bProvidesVision = false,
            bDeleteOnHit    = true,
            iVisionRadius   = 0,
            iVisionTeamNumber = caster:GetTeamNumber(),

            ExtraData = { red = is_red }
        }
        ProjectileManager:CreateLinearProjectile(info)
    end
end

function chara_d:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    self:FireKnives(caster)
    EmitSoundOn("chara_d", caster)

    if self:GetSpecialValueFor("double") > 0 then
        local delay = math.max(0, self:GetSpecialValueFor("double_delay"))
        caster:AddNewModifier(caster, self, "modifier_chara_d_double", { duration = delay })
    end
end

function chara_d:OnProjectileHit_ExtraData(hTarget, vLocation, data)
    if not IsServer() then return true end
    if not hTarget then return true end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return true end

    local pct    = self:GetSpecialValueFor("damage")
    local base   = (hTarget:GetHealth() * pct) / 100 + self:GetSpecialValueFor("damage_base")
    local is_red = (data and tonumber(data.red) == 1)
    local mult   = self:GetSpecialValueFor("shard_bonus_damage") / 100 + 1

    local damage = is_red and (base * mult) or base

    ApplyDamage({
        victim      = hTarget,
        attacker    = caster,
        damage      = damage,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        ability     = self,
    })

    local dur = self:GetSpecialValueFor("exhaust_duration")
    hTarget:AddNewModifier(caster, self, "modifier_chara_d_exhaust", {
        duration = dur * (1 - hTarget:GetStatusResistance())
    })

    return true
end


modifier_chara_d_exhaust = class({})

function modifier_chara_d_exhaust:IsPurgable() return false end
function modifier_chara_d_exhaust:IsDebuff() return true end

function modifier_chara_d_exhaust:OnCreated()
    if not IsServer() then return end
    local p = ParticleManager:CreateParticle("particles/chara_break.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(p, false, false, -1, false, false)
end

function modifier_chara_d_exhaust:CheckState()
	return {
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
	}
end


modifier_chara_d_double = class({})

function modifier_chara_d_double:IsHidden() return true end
function modifier_chara_d_double:IsPurgable() return false end
function modifier_chara_d_double:RemoveOnDeath() return true end

function modifier_chara_d_double:OnDestroy()
    if not IsServer() then return end
    local ability = self:GetAbility()
    local caster  = self:GetParent()
    if not ability or ability:IsNull() then return end
    if not caster or caster:IsNull() or not caster:IsAlive() then return end
    ability:FireKnives(caster)
    EmitSoundOn("chara_d", caster)
end