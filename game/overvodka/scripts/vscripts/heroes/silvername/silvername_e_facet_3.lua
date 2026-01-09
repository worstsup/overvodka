LinkLuaModifier( "modifier_silvername_e_facet_3_poison", "heroes/silvername/silvername_e_facet_3", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_silvername_e_facet_3_fire", "heroes/silvername/silvername_e_facet_3", LUA_MODIFIER_MOTION_NONE )

silvername_e_facet_3 = class({})

function silvername_e_facet_3:OnAbilityPhaseStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound( "silvername_e_facet_3" )
    self:GetCaster():EmitSound( "playercard.deal_five" )
    return true
end

function silvername_e_facet_3:OnAbilityPhaseInterrupted()
    if not IsServer() then return end
    self:GetCaster():StopSound( "silvername_e_facet_3" )
    self:GetCaster():StopSound( "playercard.deal_five" )
end

function silvername_e_facet_3:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local primary = self:GetCursorTarget()
    if not caster or caster:IsNull() or not primary or primary:IsNull() then return end
    local info = {
        Source = caster,
        Target = primary,
        Ability = self,
        iMoveSpeed = 800,
        EffectName = "particles/silvername_e_facet_3_cast.vpcf",
        bDodgeable = true,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
    }
    ProjectileManager:CreateTrackingProjectile( info )
end

function silvername_e_facet_3:OnProjectileHit( hTarget, vLocation )
    if not IsServer() then return end
    if not hTarget or hTarget:IsNull() then return end
    if hTarget:IsInvulnerable() then return end
    if hTarget:TriggerSpellAbsorb( self ) then return end

    local caster = self:GetCaster()
    local effect = RandomInt( 1, 3 )
    local duration_poison = self:GetSpecialValueFor( "duration_poison" )
    local duration_fire = self:GetSpecialValueFor( "duration_fire" )
    local duration_hex = self:GetSpecialValueFor( "duration_hex" )
    if effect == 1 then
        hTarget:AddNewModifier( caster, self, "modifier_silvername_e_facet_3_poison", { duration = duration_poison * (1 - hTarget:GetStatusResistance() ) } )
        local p = ParticleManager:CreateParticle( "particles/econ/items/shadow_demon/sd_ti7_shadow_poison/sd_ti7_shadow_poison_release_crush_splash.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
        ParticleManager:SetParticleControl( p, 4, hTarget:GetAbsOrigin() )
        ParticleManager:ReleaseParticleIndex( p )
    elseif effect == 2 then
        hTarget:AddNewModifier( caster, self, "modifier_silvername_e_facet_3_fire", { duration = duration_fire * (1 - hTarget:GetStatusResistance() ) } )
        local p = ParticleManager:CreateParticle( "particles/econ/items/huskar/huskar_2022_immortal/huskar_2022_immortal_life_break_gold_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
        ParticleManager:ReleaseParticleIndex( p )
    else
        hTarget:AddNewModifier( caster, self, "modifier_lion_voodoo", { duration = duration_hex } )
    end
    EmitSoundOn( "playercard.flip", hTarget )
    local damage = self:GetSpecialValueFor( "damage" )
    ApplyDamage( { victim = hTarget, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self} )
end


modifier_silvername_e_facet_3_poison = class({})

function modifier_silvername_e_facet_3_poison:IsHidden() return false end
function modifier_silvername_e_facet_3_poison:IsPurgable() return true end

function modifier_silvername_e_facet_3_poison:OnCreated()
    self.ability = self:GetAbility()
    self.damage = self.ability:GetSpecialValueFor( "damage_poison" )
    self.slow = self.ability:GetSpecialValueFor( "poison_slow" )
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.interval = 0.5
    self:StartIntervalThink(self.interval)
end

function modifier_silvername_e_facet_3_poison:OnIntervalThink()
    if not IsServer() then return end
    if not self.ability or self.ability:IsNull() then
        self:Destroy()
        return
    end
    ApplyDamage( { victim = self.parent, attacker = self.caster, damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self.ability } )
end

function modifier_silvername_e_facet_3_poison:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_silvername_e_facet_3_poison:GetModifierMoveSpeedBonus_Percentage()
    return -self.slow
end

function modifier_silvername_e_facet_3_poison:GetEffectName()
    return "particles/econ/items/viper/viper_ti7_immortal/viper_poison_crimson_debuff_ti7.vpcf"
end

function modifier_silvername_e_facet_3_poison:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


modifier_silvername_e_facet_3_fire = class({})

function modifier_silvername_e_facet_3_fire:IsHidden() return false end
function modifier_silvername_e_facet_3_fire:IsPurgable() return true end

function modifier_silvername_e_facet_3_fire:OnCreated()
    self.ability = self:GetAbility()
    self.damage = self.ability:GetSpecialValueFor( "damage_fire" )
    self.rest_red = self.ability:GetSpecialValueFor( "fire_rest" )
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.interval = 0.5
    self:StartIntervalThink(self.interval)
end

function modifier_silvername_e_facet_3_fire:OnIntervalThink()
    if not IsServer() then return end
    if not self.ability or self.ability:IsNull() then
        self:Destroy()
        return
    end
    self.parent:EmitSound("Hero_Alchemist.AcidSpray.Damage")
    ApplyDamage( { victim = self.parent, attacker = self.caster, damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self.ability } )
end

function modifier_silvername_e_facet_3_fire:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
    }
end

function modifier_silvername_e_facet_3_fire:GetModifierHealAmplify_PercentageTarget()
    return -self.rest_red
end

function modifier_silvername_e_facet_3_fire:GetModifierHPRegenAmplify_Percentage()
    return -self.rest_red
end

function modifier_silvername_e_facet_3_fire:GetModifierLifestealRegenAmplify_Percentage()
    return -self.rest_red
end

function modifier_silvername_e_facet_3_fire:GetModifierSpellLifestealRegenAmplify_Percentage()
    return -self.rest_red
end

function modifier_silvername_e_facet_3_fire:GetEffectName()
    return "particles/econ/items/huskar/huskar_2021_immortal/huskar_2021_immortal_burning_spear_debuff.vpcf"
end

function modifier_silvername_e_facet_3_fire:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end