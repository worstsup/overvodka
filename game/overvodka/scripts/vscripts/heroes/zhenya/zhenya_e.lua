LinkLuaModifier("modifier_zhenya_e_passive", "heroes/zhenya/zhenya_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zhenya_e_stats", "heroes/zhenya/zhenya_e", LUA_MODIFIER_MOTION_NONE )

zhenya_e = class({})

function zhenya_e:GetIntrinsicModifierName()
    return "modifier_zhenya_e_passive"
end

modifier_zhenya_e_passive = class({}) 

function modifier_zhenya_e_passive:IsHidden() return self:GetStackCount() == 0 end

function modifier_zhenya_e_passive:IsPurgable()
    return false
end

function modifier_zhenya_e_passive:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
    return funcs
end

function modifier_zhenya_e_passive:OnAttackLanded( params )
    if not IsServer() then return end
    if params.target ~= self:GetParent() then return end
    if self:GetParent():IsIllusion() then return end
    if self:GetParent():PassivesDisabled() then return end
    if not self:GetParent():IsAlive() then return end
    local max_stack = self:GetAbility():GetSpecialValueFor("maxstack")
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    if self:GetStackCount() < max_stack then
        self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_zhenya_e_stats", { duration = duration } )
        self:IncrementStackCount()
    end
end

function modifier_zhenya_e_passive:GetModifierPhysicalArmorBonus()
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_zhenya_e_passive:GetModifierMagicalResistanceBonus()
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("magicarmor")
end

function modifier_zhenya_e_passive:GetModifierConstantHealthRegen()
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("hpregen")
end

function modifier_zhenya_e_passive:RemoveStack()
    self:DecrementStackCount()
end

modifier_zhenya_e_stats = class({})

function modifier_zhenya_e_stats:IsHidden()
    return true
end

function modifier_zhenya_e_stats:IsPurgable()
    return false
end

function modifier_zhenya_e_stats:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_zhenya_e_stats:OnDestroy()
    if not IsServer() then return end
    local modifier = self:GetParent():FindModifierByName( "modifier_zhenya_e_passive" )
    if modifier then
        modifier:RemoveStack()
    end
end