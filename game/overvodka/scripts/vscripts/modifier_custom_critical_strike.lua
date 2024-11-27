modifier_custom_critical_strike = class({})

function modifier_custom_critical_strike:IsHidden() return false end
function modifier_custom_critical_strike:IsDebuff() return false end
function modifier_custom_critical_strike:IsPurgable() return false end

-- Declare the properties modified
function modifier_custom_critical_strike:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end
function modifier_custom_critical_strike:GetModifierMoveSpeedBonus_Percentage(params)
    return self:GetAbility():GetSpecialValueFor( "slow" )
end
-- Apply critical strike
function modifier_custom_critical_strike:GetModifierPreAttack_CriticalStrike(params)
    if not IsServer() then return end

    -- Ensure it applies only to the caster
    local parent = self:GetParent()
    if parent == params.attacker then
        return self:GetAbility():GetSpecialValueFor( "crit_mult" ) -- Critical strike damage multiplier
    end
end
function modifier_custom_critical_strike:OnAttack( params )
    if self:GetParent():HasModifier("modifier_windranger_focus_fire_lua") then return end
    if params.attacker~=self:GetParent() then return end
    self:GetParent():EmitSound("awp")
end
-- Add particle effect on critical strikes (optional)
function modifier_custom_critical_strike:GetEffectName()
    return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf"
end

function modifier_custom_critical_strike:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end