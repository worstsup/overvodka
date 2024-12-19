LinkLuaModifier("modifier_amplify_regen_no_enemies", "amplify_regen_ability", LUA_MODIFIER_MOTION_NONE)

amplify_regen_ability = amplify_regen_ability or class({})

function amplify_regen_ability:GetIntrinsicModifierName()
    return "modifier_amplify_regen_no_enemies"
end

--- Modifier ---
modifier_amplify_regen_no_enemies = modifier_amplify_regen_no_enemies or class({})

function modifier_amplify_regen_no_enemies:IsHidden() return true end
function modifier_amplify_regen_no_enemies:IsPurgable() return false end
function modifier_amplify_regen_no_enemies:RemoveOnDeath() return false end

function modifier_amplify_regen_no_enemies:OnCreated()

    self.radius = 600           -- Radius to check for enemies
    self.regen_amp = self:GetAbility():GetSpecialValueFor("regen")     -- 30% regen amplification
    self:StartIntervalThink(1)  -- Check conditions every second
    if not IsServer() then return end
end

function modifier_amplify_regen_no_enemies:OnIntervalThink()

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
        self:SetStackCount(1)  -- Enable bonus regen
    else
        self:SetStackCount(0)  -- Disable bonus regen
    end
end

function modifier_amplify_regen_no_enemies:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE
    }
end

function modifier_amplify_regen_no_enemies:GetModifierHPRegenAmplify_Percentage()
    if self:GetStackCount() == 1 then
        return self.regen_amp -- Return 30% amplified regen (health)
    end
    return 0
end

