LinkLuaModifier("modifier_papich_facet_regen_no_enemies", "heroes/papich/papich_facet_regen", LUA_MODIFIER_MOTION_NONE)

papich_facet_regen = class({})

function papich_facet_regen:GetIntrinsicModifierName()
    return "modifier_papich_facet_regen_no_enemies"
end

modifier_papich_facet_regen_no_enemies = class({})

function modifier_papich_facet_regen_no_enemies:IsHidden()
    return (self:GetStackCount() == 0)
end
function modifier_papich_facet_regen_no_enemies:IsPurgable() return false end
function modifier_papich_facet_regen_no_enemies:RemoveOnDeath() return false end

function modifier_papich_facet_regen_no_enemies:OnCreated()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.regen = self:GetAbility():GetSpecialValueFor("regen")
    self:StartIntervalThink(0.2)
end

function modifier_papich_facet_regen_no_enemies:OnIntervalThink()

    local parent = self:GetParent()
    local enemies = FindUnitsInRadius(
        parent:GetTeamNumber(),
        parent:GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )

    if #enemies == 0 then
        self:SetStackCount(self.regen)
    else
        self:SetStackCount(0)
    end
end

function modifier_papich_facet_regen_no_enemies:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE
    }
end

function modifier_papich_facet_regen_no_enemies:GetModifierHPRegenAmplify_Percentage()
    return self:GetStackCount()
end

