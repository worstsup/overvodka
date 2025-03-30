LinkLuaModifier("modifier_stray_r", "heroes/stray/stray_r", LUA_MODIFIER_MOTION_NONE)

stray_r = class({}) 

function stray_r:Precache(context)
    PrecacheResource("model", "models/stray/tiger_h1.vmdl", context)
    PrecacheResource("soundfile", "soundevents/stray_r.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/stray_r_shoot.vsndevts", context)
    PrecacheResource("particle", "particles/units/heroes/hero_techies/techies_base_attack.vpcf", context)
end

function stray_r:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level)
end

function stray_r:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function stray_r:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("stray_r")
    local duration = self:GetSpecialValueFor('duration')
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_stray_r", {duration = duration})
end

modifier_stray_r = class({}) 

function modifier_stray_r:IsPurgable() return false end

function modifier_stray_r:OnCreated()
    if not IsServer() then return end
    self.free = false
    if self:GetAbility():GetSpecialValueFor("free") == 1 then
        self.free = true
    end
    self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
end

function modifier_stray_r:OnDestroy()
    if not IsServer() then return end
    if not self:GetParent():GetUnitName() == "npc_dota_hero_rubick" then
        self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
    end
end

function modifier_stray_r:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_PROJECTILE_NAME,
        MODIFIER_PROPERTY_PROJECTILE_SPEED,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
    }
    return decFuncs
end

function modifier_stray_r:CheckState()
    return 
    {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = self.free,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_CLIFFS] = self.free
    }
end

function modifier_stray_r:GetModifierMoveSpeed_Absolute()
    return self:GetAbility():GetSpecialValueFor('mv')
end

function modifier_stray_r:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor('armor')
end

function modifier_stray_r:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor('dmg')
end

function modifier_stray_r:GetModifierFixedAttackRate()
    return self:GetAbility():GetSpecialValueFor('bat')
end

function modifier_stray_r:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor('range')
end

function modifier_stray_r:GetModifierModelChange()
    return "models/stray/tiger_h1.vmdl"
end

function modifier_stray_r:GetModifierProjectileName()
    return "particles/units/heroes/hero_techies/techies_base_attack.vpcf"
end

function modifier_stray_r:GetAttackSound()
    return "stray_r_shoot"
end

function modifier_stray_r:GetModifierProjectileSpeed()
    return 1400
end