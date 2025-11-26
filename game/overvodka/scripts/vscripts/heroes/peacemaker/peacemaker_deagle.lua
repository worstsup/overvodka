LinkLuaModifier("modifier_peacemaker_deagle", "heroes/peacemaker/peacemaker_deagle", LUA_MODIFIER_MOTION_NONE)

peacemaker_deagle = class({})

function peacemaker_deagle:GetIntrinsicModifierName()
    return "modifier_peacemaker_deagle"
end

modifier_peacemaker_deagle = class({})

function modifier_peacemaker_deagle:IsHidden()   return true end
function modifier_peacemaker_deagle:IsPurgable() return false end
function modifier_peacemaker_deagle:RemoveOnDeath() return false end

function modifier_peacemaker_deagle:OnCreated()
    local parent = self:GetParent()
    self.attack_range_bonus = self:GetAbility():GetSpecialValueFor("attack_range")
    if not IsServer() then return end
    parent:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
end

function modifier_peacemaker_deagle:OnRefresh()
    self:OnCreated()
end

function modifier_peacemaker_deagle:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
        MODIFIER_PROPERTY_PROJECTILE_NAME,
    }
end

function modifier_peacemaker_deagle:GetModifierAttackRangeOverride()
    return self.attack_range_bonus
end

function modifier_peacemaker_deagle:GetModifierModelChange()
    return "models/peacemaker/deagle_peacemaker.vmdl"
end

function modifier_peacemaker_deagle:GetAttackSound()
    return "Peacemaker.Deagle.Attack"
end

function modifier_peacemaker_deagle:GetModifierProjectileName()
    return "particles/peacemaker_deagle_proj.vpcf"
end