modifier_custom_critical_strike = class({})

function modifier_custom_critical_strike:IsHidden() return false end
function modifier_custom_critical_strike:IsDebuff() return false end
function modifier_custom_critical_strike:IsPurgable() return false end

function modifier_custom_critical_strike:OnCreated()
    if not IsServer() then return end
    self.slow = self:GetAbility():GetSpecialValueFor( "slow" )
    self.attack = self:GetAbility():GetSpecialValueFor( "attack_fixed" )
    self.crit_mult = self:GetAbility():GetSpecialValueFor( "crit_mult" )
    self.extra_range = self:GetAbility():GetSpecialValueFor( "extra_range" )
end

function modifier_custom_critical_strike:OnRefresh( )
    self.slow = self:GetAbility():GetSpecialValueFor( "slow" )
    self.attack = self:GetAbility():GetSpecialValueFor( "attack_fixed" )
    self.crit_mult = self:GetAbility():GetSpecialValueFor( "crit_mult" )
    self.extra_range = self:GetAbility():GetSpecialValueFor( "extra_range" )
end
function modifier_custom_critical_strike:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
    }
end
function modifier_custom_critical_strike:GetModifierMoveSpeedBonus_Percentage(params)
    return self.slow
end
function modifier_custom_critical_strike:GetModifierFixedAttackRate(params)
    return self.attack
end
function modifier_custom_critical_strike:GetModifierPreAttack_CriticalStrike(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    if parent == params.attacker then
        return self.crit_mult
    end
end
function modifier_custom_critical_strike:OnAttack( params )
    if self:GetParent():HasModifier("modifier_windranger_focus_fire_lua") then return end
    if params.attacker~=self:GetParent() then return end
    self:GetParent():EmitSound("awp")
end
function modifier_custom_critical_strike:GetModifierAttackRangeBonus(params)
    return self.extra_range
end
function modifier_custom_critical_strike:GetEffectName()
    return "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_trail.vpcf"
end

function modifier_custom_critical_strike:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end