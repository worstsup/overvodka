LinkLuaModifier( "modifier_mellstroy_scepter", "heroes/mellstroy/mellstroy_scepter", LUA_MODIFIER_MOTION_NONE )

mellstroy_scepter = class({})

function mellstroy_scepter:Precache( context )
	PrecacheResource( "soundfile", "soundevents/mellstroy_scepter.vsndevts", context )
    PrecacheResource("particle", "particles/mellstroy_scepter.vpcf", context)
end

function mellstroy_scepter:GetAbilityTextureName()
    if self:GetCaster():HasMellstroyArcanaSkin() then
        return "mellstroy_scepter_arcana"
    end
    return "mellstroy_scepter"
end

function mellstroy_scepter:GetGoldCost(iLevel)
    local base = self:GetSpecialValueFor("gold_cost")

    local low = tonumber(self:GetCaster()._low_gold) or 0
    if low == 1 then
        return math.floor(base * 0.75 + 0.5)
    end

    return base
end

function mellstroy_scepter:OnSpellStart()
	if not IsServer() then return end
    local caster = self:GetCaster()
    caster:AddNewModifier( caster, self, "modifier_mellstroy_scepter", {duration = self:GetSpecialValueFor("duration")} )
    if not caster:HasModifier("modifier_mell_amam") then
        EmitSoundOn("mellstroy_scepter", caster)
    end
end


modifier_mellstroy_scepter = class({})

function modifier_mellstroy_scepter:IsHidden() return false end
function modifier_mellstroy_scepter:IsPurgable() return true end

function modifier_mellstroy_scepter:OnCreated(kv)
    self.k = 0
    self.parent = self:GetParent()
    local ability = self:GetAbility()
    self.purge_threshold = ability:GetSpecialValueFor("damage_cleanse")
    self.reset_interval = ability:GetSpecialValueFor("damage_reset_interval")
    if not IsServer() then return end
    self.damage = 0
    self.on_cooldown = false
    local particle = ParticleManager:CreateParticle("particles/mellstroy_scepter.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_mellstroy_scepter:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_mellstroy_scepter:OnTakeDamage(params)
    if not IsServer() then return end
    local ability = self:GetAbility()
    if params.unit:IsIllusion() then return end
    if params.unit ~= self.parent then return end
    if not params.attacker:GetPlayerOwner() then return end
    if self.on_cooldown then return end
    self.damage = self.damage + params.original_damage
    if self.damage >= self.purge_threshold then
        self.damage = 0
        self.on_cooldown = true
        self:FireMeteors()
        self:StartIntervalThink(self.reset_interval)
    end
end

function modifier_mellstroy_scepter:FireMeteors()
    if not IsServer() then return end
	local caster = self:GetParent()
    local meteors_ability = caster:FindAbilityByName("mellstroy_meteors")
    if not meteors_ability then return end
    if meteors_ability:GetLevel() < 1 then return end
    self.k = self.k % 5 + 1
    local eff = "particles/invoker_chaos_meteor_mell_" .. self.k .. ".vpcf"
    EmitSoundOn("mellstroy_scepter_"..self.k, caster)
    local forward_dir = caster:GetForwardVector()
    forward_dir.z = 0
    local angle_step = math.rad(45)
    meteors_ability.tartar = {}
    for i = 0, 7 do
        local angle = angle_step * i
        local cosA  = math.cos(angle)
        local sinA  = math.sin(angle)
        local vx = forward_dir.x * cosA - forward_dir.y * sinA
        local vy = forward_dir.x * sinA + forward_dir.y * cosA
        local dir2d = Vector(vx, vy, 0)
        local proj = {
            Ability             = meteors_ability,
            EffectName          = eff,
            vSpawnOrigin        = caster:GetAbsOrigin(),
            fDistance           = 800,
            fStartRadius        = 115,
            fEndRadius          = 120,
            Source              = caster,
            bHasFrontalCone     = false,
            bReplaceExisting    = false,
            iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            bDeleteOnHit        = true,
            vVelocity           = dir2d * 1500,
            bProvidesVision     = true,
            iVisionRadius       = 200,
            iVisionTeamNumber   = caster:GetTeamNumber(),
        }
        ProjectileManager:CreateLinearProjectile(proj)
    end
end

function modifier_mellstroy_scepter:OnIntervalThink()
    self.on_cooldown = false
    self.damage = 0
    self:StartIntervalThink(-1)
end
