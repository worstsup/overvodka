LinkLuaModifier("modifier_papich_facet_regen_no_enemies", "heroes/papich/papich_facet_regen", LUA_MODIFIER_MOTION_NONE)

papich_facet_regen = papich_facet_regen or class({})

function papich_facet_regen:GetIntrinsicModifierName()
    return "modifier_papich_facet_regen_no_enemies"
end

modifier_papich_facet_regen_no_enemies = modifier_papich_facet_regen_no_enemies or class({})

function modifier_papich_facet_regen_no_enemies:IsHidden() return true end
function modifier_papich_facet_regen_no_enemies:IsPurgable() return false end
function modifier_papich_facet_regen_no_enemies:RemoveOnDeath() return false end

function modifier_papich_facet_regen_no_enemies:OnCreated()
    if not IsServer() then return end

    self.radius = 600
    self:StartIntervalThink(1)
end

function modifier_papich_facet_regen_no_enemies:OnRefresh()
    if not IsServer() then return end

    self.radius = 600
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
        self:SetStackCount(1)
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
    if self:GetStackCount() == 1 then
        return 40
    end
    return 0
end

