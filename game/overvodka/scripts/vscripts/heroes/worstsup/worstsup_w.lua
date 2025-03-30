worstsup_w = class({})
LinkLuaModifier("modifier_worstsup_w_debuff", "heroes/worstsup/worstsup_w.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_worstsup_w_buff", "heroes/worstsup/worstsup_w.lua", LUA_MODIFIER_MOTION_NONE)

function worstsup_w:Precache(context)
    PrecacheResource("particle", "particles/econ/items/wisp/wisp_tether_ti7.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_demonartist/demonartist_soulchain_debuff.vpcf", context)
    PrecacheResource("particle", "particles/worstsup_buff.vpcf", context)
    PrecacheResource( "soundfile", "soundevents/cheza.vsndevts", context )
end

function worstsup_w:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if not IsServer() then return end
    local projectile_info = {
        Target = target,
        Source = caster,
        Ability = self,
        EffectName = "particles/econ/items/wisp/wisp_tether_ti7.vpcf",
        iMoveSpeed = 2000,
        bDodgeable = true,
        bVisible = true,
        bProvidesVision = true,
        iVisionRadius = 200,
        iVisionTeamNumber = caster:GetTeamNumber()
    }
    ProjectileManager:CreateTrackingProjectile(projectile_info)
end

function worstsup_w:OnProjectileHit(target, location)
    if not target or target:IsInvulnerable() then return end
    if target:TriggerSpellAbsorb(self) then return end
    local caster = self:GetCaster()
    EmitSoundOn("cheza", caster)
    
    target:AddNewModifier(caster, self, "modifier_worstsup_w_debuff", {
        duration = self:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance())
    })
    if self:GetSpecialValueFor("buff") == 1 then
        caster:AddNewModifier(caster, self, "modifier_worstsup_w_buff", {
            duration = self:GetSpecialValueFor("duration")
        })
    end
    return true
end

modifier_worstsup_w_debuff = class({})

function modifier_worstsup_w_debuff:IsDebuff() return true end
function modifier_worstsup_w_debuff:IsPurgable() return true end

function modifier_worstsup_w_debuff:OnCreated()
    if not IsServer() then return end
end

function modifier_worstsup_w_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }
end

function modifier_worstsup_w_debuff:GetEffectName()
    return "particles/units/heroes/hero_demonartist/demonartist_soulchain_debuff.vpcf"
end

function modifier_worstsup_w_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_worstsup_w_debuff:GetModifierMagicalResistanceBonus()
    return -self:GetAbility():GetSpecialValueFor("magic")
end

function modifier_worstsup_w_debuff:GetModifierPhysicalArmorBonus()
    return -self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_worstsup_w_debuff:GetBonusDayVision()
    return -self:GetParent():GetBaseDayTimeVisionRange() * self:GetAbility():GetSpecialValueFor("vision") / 100
end

function modifier_worstsup_w_debuff:GetBonusNightVision()
    return -self:GetParent():GetBaseNightTimeVisionRange() * self:GetAbility():GetSpecialValueFor("vision") / 100
end

function modifier_worstsup_w_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_worstsup_w_debuff:GetModifierBonusStats_Strength()
    return -self:GetAbility():GetSpecialValueFor("att")
end

function modifier_worstsup_w_debuff:GetModifierBonusStats_Agility()
    return -self:GetAbility():GetSpecialValueFor("att")
end

function modifier_worstsup_w_debuff:GetModifierBonusStats_Intellect()
    return -self:GetAbility():GetSpecialValueFor("att")
end

modifier_worstsup_w_buff = class({})

function modifier_worstsup_w_buff:IsBuff() return true end
function modifier_worstsup_w_buff:IsPurgable() return false end

function modifier_worstsup_w_buff:OnCreated()
    if not IsServer() then return end
end

function modifier_worstsup_w_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }
end

function modifier_worstsup_w_buff:GetEffectName()
    return "particles/worstsup_buff.vpcf"
end

function modifier_worstsup_w_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_worstsup_w_buff:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("magic")
end

function modifier_worstsup_w_buff:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_worstsup_w_buff:GetBonusDayVision()
    return self:GetAbility():GetSpecialValueFor("vision") * self:GetParent():GetBaseDayTimeVisionRange() / 100
end

function modifier_worstsup_w_buff:GetBonusNightVision()
    return self:GetAbility():GetSpecialValueFor("vision") * self:GetParent():GetBaseNightTimeVisionRange() / 100
end

function modifier_worstsup_w_buff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_worstsup_w_buff:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("att")
end

function modifier_worstsup_w_buff:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("att")
end

function modifier_worstsup_w_buff:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("att")
end