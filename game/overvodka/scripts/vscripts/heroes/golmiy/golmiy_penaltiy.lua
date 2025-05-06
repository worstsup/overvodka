LinkLuaModifier("modifier_golmiy_penaltiy", "heroes/golmiy/golmiy_penaltiy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)

golmiy_penaltiy = class({})

tartar = {}

function golmiy_penaltiy:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level)
end

function golmiy_penaltiy:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function golmiy_penaltiy:Precache( context )
    PrecacheResource("particle", "particles/invoker_chaos_meteor_new.vpcf", context)
    PrecacheResource("soundfile", "soundevents/penal.vsndevts", context)
    PrecacheResource("particle", "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf", context)
end

function golmiy_penaltiy:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target_loc = self:GetCursorPosition()
    local caster_loc = caster:GetAbsOrigin()
    local direction = (target_loc - caster_loc):Normalized()
    local speed = 1000
    if target_loc == caster_loc then
        direction = caster:GetForwardVector()
    else
        direction = (target_loc - caster_loc):Normalized()
    end
    tartar = {}
    local baseInfo = {
        Ability             = self,
        EffectName          = "particles/invoker_chaos_meteor_new.vpcf",
        vSpawnOrigin        = caster:GetAbsOrigin(),
        fDistance           = 1050,
        fStartRadius        = 115,
        fEndRadius          = 120,
        Source              = caster,
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        bDeleteOnHit        = false,
        bProvidesVision     = true,
        iVisionRadius       = 200,
        iVisionTeamNumber   = caster:GetTeamNumber(),
    }
    local angles = { 0 }
    EmitSoundOn("penal", caster)
    local talent = caster:FindAbilityByName("special_bonus_unique_golmiy_7")
    if talent and talent:GetLevel() > 0 then
        table.insert(angles,  30)
        table.insert(angles, -30)
    end
    for _, ang in ipairs(angles) do
        local dir = RotateVector2D(direction, ang)
        local info = shallowcopy(baseInfo)
        info.vVelocity = dir * speed
        ProjectileManager:CreateLinearProjectile(info)
    end
end

function RotateVector2D(vec, degrees)
    local rad = math.rad(degrees)
    local c = math.cos(rad)
    local s = math.sin(rad)
    return Vector(
        vec.x * c - vec.y * s,
        vec.x * s + vec.y * c,
        0
    )
end

function golmiy_penaltiy:OnProjectileHit( target, location )
    if not IsServer() then return end
    if not target then return end
    local caster = self:GetCaster()
    local stun_time = self:GetSpecialValueFor("meteor_stun")
    local damage = self:GetSpecialValueFor("damage")
    local gold = self:GetSpecialValueFor("gold")
    for _,v in ipairs(tartar) do  
        if v == target then return end
    end
    target:EmitSound("Hero_WarlockGolem.Attack")
    if target:IsRealHero() then
        caster:ModifyGold(gold, false, 0)
        SendOverheadEventMessage(caster, OVERHEAD_ALERT_GOLD, caster, gold, nil)
    end
    ApplyDamage({attacker = caster, victim = target, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
    target:AddNewModifier(caster, self, "modifier_generic_stunned_lua", {duration = stun_time})
    target:AddNewModifier(caster, self, "modifier_golmiy_penaltiy", {duration = self:GetSpecialValueFor("fire_duration") * (1 - target:GetStatusResistance())})
    table.insert(tartar, target)
end

modifier_golmiy_penaltiy = class({})
function modifier_golmiy_penaltiy:IsHidden() return false end
function modifier_golmiy_penaltiy:IsDebuff() return true end
function modifier_golmiy_penaltiy:IsPurgable() return true end
function modifier_golmiy_penaltiy:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1)
    self:OnIntervalThink()
end

function modifier_golmiy_penaltiy:OnIntervalThink()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetParent()
    local ability = self:GetAbility()
    local damage = ability:GetSpecialValueFor("think_damage")
    ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
end

function modifier_golmiy_penaltiy:GetEffectName()
    return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
end

function modifier_golmiy_penaltiy:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end