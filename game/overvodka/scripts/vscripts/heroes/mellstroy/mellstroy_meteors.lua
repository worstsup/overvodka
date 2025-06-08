LinkLuaModifier("modifier_mellstroy_meteors", "heroes/mellstroy/mellstroy_meteors", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mellstroy_meteor_slowed_debuff", "heroes/mellstroy/mellstroy_meteors", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mellstroy_meteor_fired_debuff", "heroes/mellstroy/mellstroy_meteors", LUA_MODIFIER_MOTION_NONE)

mellstroy_meteors = class({})

function mellstroy_meteors:Precache(context)
	PrecacheResource("particle", "particles/invoker_chaos_meteor_mell_1.vpcf", context)
	PrecacheResource("particle", "particles/invoker_chaos_meteor_mell_2.vpcf", context)
	PrecacheResource("particle", "particles/invoker_chaos_meteor_mell_3.vpcf", context)
	PrecacheResource("particle", "particles/invoker_chaos_meteor_mell_4.vpcf", context)
	PrecacheResource("particle", "particles/invoker_chaos_meteor_mell_5.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf", context)
    PrecacheResource("soundfile", "soundevents/fruits.vsndevts", context)
end

function mellstroy_meteors:OnSpellStart()
    if not IsServer() then return end
	local caster = self:GetCaster()
	EmitSoundOn("fruits", caster)
	caster:AddNewModifier(caster, self, "modifier_mellstroy_meteors", {duration = 7})
end

function mellstroy_meteors:OnProjectileHit( target, location )
    if not IsServer() then return end
    if not target then return end
    local caster = self:GetCaster()
    local stun_time = self:GetSpecialValueFor("meteor_stun")
    local damage = self:GetSpecialValueFor("damage")
    local gold = self:GetSpecialValueFor("gold")
	local fire_duration = self:GetSpecialValueFor("fire_duration")
    for _,v in ipairs(tartar) do  
        if v == target then return end
    end
    target:EmitSound("Hero_WarlockGolem.Attack")
    if target:IsRealHero() and not target:IsIllusion() then
        caster:ModifyGold(gold, false, 0)
        SendOverheadEventMessage(caster, OVERHEAD_ALERT_GOLD, caster, gold, nil)
    end
    local damageTable = {victim = target, attacker = caster, damage = damage, damage_type = self:GetAbilityDamageType(), ability = self}
    ApplyDamage(damageTable)
    target:AddNewModifier(caster, self, "modifier_mellstroy_meteor_slowed_debuff", {duration = stun_time * (1 - target:GetStatusResistance())})
    target:AddNewModifier(caster, self, "modifier_mellstroy_meteor_fired_debuff", {duration = fire_duration * (1 - target:GetStatusResistance())})
    table.insert(tartar, target)
end

modifier_mellstroy_meteors = class({})
function modifier_mellstroy_meteors:IsHidden() return true end
function modifier_mellstroy_meteors:IsPurgable() return false end
function modifier_mellstroy_meteors:OnCreated()
	self.k = 0
	self:StartIntervalThink(1.5)
	self:OnIntervalThink()
end

function modifier_mellstroy_meteors:OnIntervalThink()
    if not IsServer() then return end
	local caster = self:GetParent()
    self.k = self.k + 1
    local eff = "particles/invoker_chaos_meteor_mell_" .. self.k .. ".vpcf"
    local forward_dir = caster:GetForwardVector()
    forward_dir.z = 0
    local angle_step = math.rad(45)
	tartar = {}
    for i = 0, 7 do
        local angle = angle_step * i
        local cosA  = math.cos(angle)
        local sinA  = math.sin(angle)
        local vx = forward_dir.x * cosA - forward_dir.y * sinA
        local vy = forward_dir.x * sinA + forward_dir.y * cosA
        local dir2d = Vector(vx, vy, 0)
        local proj = {
            Ability             = self:GetAbility(),
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

modifier_mellstroy_meteor_slowed_debuff = class({})
function modifier_mellstroy_meteor_slowed_debuff:IsHidden() return false end
function modifier_mellstroy_meteor_slowed_debuff:IsPurgable() return true end

function modifier_mellstroy_meteor_slowed_debuff:DeclareFunctions()
  	return {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
  	}
end

function modifier_mellstroy_meteor_slowed_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("ms_pct")
end

modifier_mellstroy_meteor_fired_debuff = class({})
function modifier_mellstroy_meteor_fired_debuff:IsHidden() return false end
function modifier_mellstroy_meteor_fired_debuff:IsPurgable() return true end

function modifier_mellstroy_meteor_fired_debuff:OnCreated()
    if not IsServer() then return end
	self:StartIntervalThink(1)
end

function modifier_mellstroy_meteor_fired_debuff:OnIntervalThink()
    local damageTable = {victim = self:GetParent(), attacker = self:GetCaster(), damage = self:GetAbility():GetSpecialValueFor("think_damage"), damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()}
	ApplyDamage(damageTable)
end

function modifier_mellstroy_meteor_fired_debuff:GetEffectName()
	return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
end

function modifier_mellstroy_meteor_fired_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end