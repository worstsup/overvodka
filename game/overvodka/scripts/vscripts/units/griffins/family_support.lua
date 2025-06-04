LinkLuaModifier("modifier_family_support", "units/griffins/family_support.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_family_support_effect", "units/griffins/family_support.lua", LUA_MODIFIER_MOTION_NONE)

family_support = class({})

function family_support:GetIntrinsicModifierName()
    return "modifier_family_support"
end

modifier_family_support = class({})

function modifier_family_support:IsHidden() return true end
function modifier_family_support:IsDebuff() return false end
function modifier_family_support:IsPurgable() return false end
function modifier_family_support:IsAura() return true end

function modifier_family_support:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("AbilityCastRange")
end

function modifier_family_support:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_family_support:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_family_support:GetModifierAura()
    return "modifier_family_support_effect"
end

function modifier_family_support:GetAuraEntityReject(hEntity)
    return false
end

modifier_family_support_effect = class({})

function modifier_family_support_effect:IsHidden()    return false end
function modifier_family_support_effect:IsDebuff()    return false end
function modifier_family_support_effect:IsPurgable()  return false end

function modifier_family_support_effect:OnCreated()
    local ability = self:GetAbility()
    if not ability then return end
    self.mult = 1
    self.health_bonus_flat = ability:GetSpecialValueFor("health_bonus_flat")
    self.attack_speed_bonus = ability:GetSpecialValueFor("attack_speed_bonus")
    self.radius = ability:GetSpecialValueFor("AbilityCastRange")
    self:StartIntervalThink(0.5)
    self:OnIntervalThink()
end

function modifier_family_support_effect:OnRefresh()
    self:OnCreated()
end

function modifier_family_support_effect:OnIntervalThink()
    if not IsServer() then return end
    local has_rock_golem = false
    local units = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),
        self:GetParent():GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    for _, unit in pairs(units) do
        if unit:GetUnitName() == "npc_dota_neutral_rock_golem" then
            has_rock_golem = true
            break
        end
    end
    if has_rock_golem then
        self.mult = 2
    else
        self.mult = 1
    end
end

function modifier_family_support_effect:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end

function modifier_family_support_effect:GetModifierExtraHealthBonus()
    return self.health_bonus_flat * self.mult
end

function modifier_family_support_effect:GetModifierAttackSpeedBonus_Constant()
    return self.attack_speed_bonus * self.mult
end
