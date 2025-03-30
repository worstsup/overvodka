LinkLuaModifier("modifier_evelone_q", "heroes/evelone/evelone_q", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_evelone_q_damage", "heroes/evelone/evelone_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_evelone_q_debuff", "heroes/evelone/evelone_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_evelone_q_shard", "heroes/evelone/evelone_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_generic_knockback_lua", "modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH )

evelone_q = class({})

num = 0

function evelone_q:Precache(context)
    PrecacheResource( "particle", "particles/evelone_q_run.vpcf", context )
    PrecacheResource( "particle", "particles/evelone_q.vpcf", context )
    PrecacheResource( "particle", "particles/evelone_q_hit.vpcf", context )
    PrecacheResource( "particle", "particles/evelone_q_ulti.vpcf", context )
    PrecacheResource( "particle", "particles/evelone_q_run_ulti.vpcf", context )
    PrecacheResource( "particle", "particles/evelone_q_hit_ulti.vpcf", context )
    PrecacheResource( "soundfile", "soundevents/evelone_q_knife.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/evelone_q_1.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/evelone_q_2.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/evelone_q_3.vsndevts", context )
end

function evelone_q:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function evelone_q:GetCastRange(location, target)
    if IsClient() then
        return self:GetSpecialValueFor("range")
    end
    return self.BaseClass.GetCastRange(self, location, target)
end

function evelone_q:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function evelone_q:GetIntrinsicModifierName()
    return "modifier_evelone_q_shard"
end

function evelone_q:OnAbilityUpgrade( hAbility )
	if not IsServer() then return end
	self.BaseClass.OnAbilityUpgrade( self, hAbility )
	self:EnableAbilityChargesOnTalentUpgrade( hAbility, "special_bonus_unique_faceless_void_2" )
end


modifier_evelone_q_shard = class({})

function modifier_evelone_q_shard:IsHidden()
    return true
end

function modifier_evelone_q_shard:IsPurgable()
    return false
end

function modifier_evelone_q_shard:DestroyOnExpire()
    return false
end

function modifier_evelone_q_shard:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_HERO_KILLED
    }
    return funcs
end

function modifier_evelone_q_shard:OnHeroKilled( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        if self:GetParent():IsIllusion() then return end
        if not self:GetParent():HasModifier("modifier_item_aghanims_shard") then return end
        if self:GetAbility():GetMaxAbilityCharges(self:GetAbility():GetLevel()) > self:GetAbility():GetCurrentAbilityCharges() then
            self:GetAbility():SetCurrentAbilityCharges(self:GetAbility():GetCurrentAbilityCharges()+1)
        end
        if self:GetAbility():GetCurrentAbilityCharges() >= self:GetAbility():GetMaxAbilityCharges(self:GetAbility():GetLevel()) then
            self:GetAbility():RefreshCharges()
        end
        if self:GetAbility():GetMaxAbilityCharges(self:GetAbility():GetLevel()) == 0 then
            self:GetAbility():EndCooldown()
        end
    end
end

function evelone_q:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    if point == self:GetCaster():GetAbsOrigin() then
        point = point + self:GetCaster():GetForwardVector()
    end
    local direction = point - self:GetCaster():GetAbsOrigin()
    local length = direction:Length2D()
    direction.z = 0
    direction = direction:Normalized()
    local speed = self:GetSpecialValueFor("speed")
    local distance = math.min(length, self:GetSpecialValueFor("range"))

    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_evelone_q", {duration = distance/speed})
    self:GetCaster():AddNewModifier(
        self:GetCaster(),
        self,
        "modifier_generic_knockback_lua",
        {
            direction_x = direction.x,
            direction_y = direction.y,
            distance = distance,
            duration = distance/speed,
        }
    )
    if num == 0 then
        self:GetCaster():EmitSound("evelone_q_1")
        num = 1
    elseif num == 1 then
        self:GetCaster():EmitSound("evelone_q_2")
        num = 2
    elseif num == 2 then
        self:GetCaster():EmitSound("evelone_q_3")
        num = 0
    end
end

modifier_evelone_q = class({})
function modifier_evelone_q:IsPurgable() return false end
function modifier_evelone_q:IsHidden() return true end
function modifier_evelone_q:IsAura() return true end
function modifier_evelone_q:GetAuraDuration() return 0 end
function modifier_evelone_q:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_evelone_q:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_evelone_q:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_evelone_q:GetModifierAura() return "modifier_evelone_q_damage" end
function modifier_evelone_q:GetAuraRadius() return 100 end
function modifier_evelone_q:OnCreated()
    if not IsServer() then return end
    local base_damage = self:GetAbility():GetSpecialValueFor("base_damage")
    self.percent_damage = self:GetAbility():GetSpecialValueFor("attack_damage")
    self.damage = base_damage
    local effect
    if self:GetParent():HasModifier("modifier_evelone_r") then
        effect = ParticleManager:CreateParticle("particles/evelone_q_ulti.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    else
        effect = ParticleManager:CreateParticle("particles/evelone_q_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    end
    ParticleManager:SetParticleControl(effect, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect)
end

function modifier_evelone_q:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
	return funcs
end

function modifier_evelone_q:GetModifierDamageOutgoing_Percentage( params )
	if IsServer() then
		return self.percent_damage
	end
end

function modifier_evelone_q:GetModifierPreAttack_BonusDamage( params )
	if IsServer() then
		return self.damage * 100 / ( 100 + self.percent_damage )
	end
end

function modifier_evelone_q:GetEffectName()
    if self:GetParent():HasModifier("modifier_evelone_r") then
        return "particles/evelone_q_run_ulti.vpcf"
    end
    return "particles/evelone_q_run.vpcf"
end

function modifier_evelone_q:OnDestroy()
    if not IsServer() then return end
    FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
    self:GetCaster():MoveToPositionAggressive(self:GetCaster():GetAbsOrigin())
end

modifier_evelone_q_damage = class({})
function modifier_evelone_q_damage:IsPurgable() return false end
function modifier_evelone_q_damage:IsHidden() return true end

function modifier_evelone_q_damage:OnCreated()
	if not IsServer() then return end
    local parent = self:GetParent()
    local caster = self:GetCaster()
	local duration = self:GetAbility():GetSpecialValueFor("duration")
    local hit_blood
    if not parent:IsDebuffImmune() then
        parent:AddNewModifier(caster, self:GetAbility(), "modifier_evelone_q_debuff", { duration = duration * (1 - parent:GetStatusResistance()) })
    end
    if caster:HasModifier("modifier_evelone_r") then
        hit_blood = ParticleManager:CreateParticle("particles/evelone_q_hit_ulti.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    else
        hit_blood = ParticleManager:CreateParticle("particles/evelone_q.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    end
    ParticleManager:SetParticleControl(hit_blood, 0, parent:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(hit_blood)
	self:GetParent():EmitSound("evelone_q_knife")
    caster:PerformAttack(parent, true, true, true, true, false, false, true)
end

modifier_evelone_q_debuff = class({})

function modifier_evelone_q_debuff:IsPurgable()
    return true
end

function modifier_evelone_q_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end

function modifier_evelone_q_debuff:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_evelone_q_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slowing")
end