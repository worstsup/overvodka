LinkLuaModifier("modifier_peacemaker_deagle", "heroes/peacemaker/modifier_peacemaker_deagle", LUA_MODIFIER_MOTION_NONE)

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
    parent:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
    self.attack_range_bonus = self:GetAbility():GetSpecialValueFor("attack_range") - parent:Script_GetAttackRange()
end

function modifier_peacemaker_deagle:OnRefresh()
    self:OnCreated()
end

function modifier_peacemaker_deagle:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
    }
end

function modifier_peacemaker_deagle:GetModifierAttackRangeBonus()
    return self.attack_range_bonus
end

function modifier_peacemaker_deagle:GetModifierModelChange()
    return "models/peacemaker/deagle_peacemaker.vmdl"
end

function modifier_peacemaker_deagle:GetAttackSound()
    return "Peacemaker.Deagle.Attack"
end