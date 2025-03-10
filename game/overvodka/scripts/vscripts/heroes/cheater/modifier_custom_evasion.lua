modifier_custom_evasion = class({})

function modifier_custom_evasion:IsHidden() return true end
function modifier_custom_evasion:IsPurgable() return false end
function modifier_custom_evasion:RemoveOnDeath() return false end

function modifier_custom_evasion:OnCreated()
    if not IsServer() then return end
    self.current_evasion = 30
    self:StartIntervalThink(0.1)
end
function modifier_custom_evasion:OnRemoved()
end
function modifier_custom_evasion:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():PassivesDisabled() then
        self.current_evasion = 0
        return
    end
    local caster = self:GetParent()
    local max_evasion = self:GetAbility():GetSpecialValueFor( "max_evasion" )
    local mid_evasion = self:GetAbility():GetSpecialValueFor( "mid_evasion" )
    local min_evasion = self:GetAbility():GetSpecialValueFor( "min_evasion" )
    local close_range = self:GetAbility():GetSpecialValueFor( "close_range" )
    local mid_range = self:GetAbility():GetSpecialValueFor( "mid_range" )
    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        mid_range,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    if #enemies == 0 then
        self.current_evasion = max_evasion
        return
    end
    local closest_distance = mid_range
    for _, enemy in pairs(enemies) do
        local distance = (enemy:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
        closest_distance = math.min(closest_distance, distance)
    end
    if closest_distance <= close_range then
        self.current_evasion = min_evasion
    elseif closest_distance <= mid_range then
        self.current_evasion = mid_evasion
    else
        self.current_evasion = max_evasion
    end
    print("Current Evasion:", self.current_evasion)
end

function modifier_custom_evasion:DeclareFunctions()
    local funcs = 
	{
		MODIFIER_PROPERTY_EVASION_CONSTANT,
	}
	return funcs
end

function modifier_custom_evasion:GetModifierEvasion_Constant()
    return self.current_evasion or 0
end