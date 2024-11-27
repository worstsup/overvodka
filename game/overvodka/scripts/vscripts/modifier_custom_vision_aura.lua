modifier_custom_vision_aura = class({})

function modifier_custom_vision_aura:IsHidden() return true end
function modifier_custom_vision_aura:IsDebuff() return false end
function modifier_custom_vision_aura:IsPurgable() return false end

function modifier_custom_vision_aura:OnCreated()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self:StartIntervalThink(0.1)
end

function modifier_custom_vision_aura:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()
    
    -- Provide vision and True Sight in a 900 radius
    AddFOWViewer(parent:GetTeamNumber(), parent:GetAbsOrigin(), self.radius, 0.1, false)
    
    -- True Sight logic
    local enemies = FindUnitsInRadius(
        parent:GetTeamNumber(),
        parent:GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    
    for _, enemy in ipairs(enemies) do
        if enemy:IsInvisible() then
            enemy:AddNewModifier(parent, nil, "modifier_truesight", {duration = 0.2})
        end
    end
end