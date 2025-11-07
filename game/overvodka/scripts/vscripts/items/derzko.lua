LinkLuaModifier("modifier_item_derzko", "items/derzko", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_derzko_active", "items/derzko", LUA_MODIFIER_MOTION_NONE)

item_derzko = class({})

function item_derzko:GetIntrinsicModifierName()
    return "modifier_item_derzko"
end

function item_derzko:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    caster:Purge(false, true, false, true, false)
    caster:AddNewModifier(caster, self, "modifier_item_derzko_active", {duration = self:GetSpecialValueFor("duration")})
    caster:EmitSound("lvinoe")
end


modifier_item_derzko_active = class({})

function modifier_item_derzko_active:IsHidden() return false end
function modifier_item_derzko_active:IsPurgable() return true end

function modifier_item_derzko_active:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MIN_HEALTH,
    }
end

function modifier_item_derzko_active:GetMinHealth()
    return 1
end

function modifier_item_derzko_active:GetEffectName()
    return "particles/bloodseeker_rupture_new.vpcf"
end

function modifier_item_derzko_active:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


modifier_item_derzko = class({})

function modifier_item_derzko:IsHidden() return true end
function modifier_item_derzko:IsPurgable() return false end
function modifier_item_derzko:IsPurgeException() return false end
function modifier_item_derzko:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_derzko:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_item_derzko:OnCreated()
    self.str = self:GetAbility():GetSpecialValueFor('bonus_strength')
    self.health = self:GetAbility():GetSpecialValueFor('bonus_health')
    self.mana = self:GetAbility():GetSpecialValueFor('bonus_mana')
    self.damage = self:GetAbility():GetSpecialValueFor('bonus_damage')
    if not IsServer() then return end
    self.health_regen_pct = self:GetAbility():GetSpecialValueFor('health_regen_percent_per_second')
    if self:GetParent():FindAllModifiersByName("modifier_item_derzko")[1] ~= self then
        self.health_regen_pct = 0
    end
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(FrameTime())
end

function modifier_item_derzko:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():FindAllModifiersByName("modifier_item_derzko")[1] ~= self then
        self.health_regen_pct = 0
    else
        self.health_regen_pct = self:GetAbility():GetSpecialValueFor('health_regen_percent_per_second')
    end
    self:SendBuffRefreshToClients()
end

function modifier_item_derzko:AddCustomTransmitterData()
    return 
    {
        health_regen_pct = self.health_regen_pct,
    }
end

function modifier_item_derzko:HandleCustomTransmitterData( data )
    self.health_regen_pct = data.health_regen_pct
end

function modifier_item_derzko:GetModifierBonusStats_Strength()
    if not self:GetAbility() then return end
    return self.str
end

function modifier_item_derzko:GetModifierHealthRegenPercentage()
    if not self:GetAbility() then return end
    return self.health_regen_pct
end

function modifier_item_derzko:GetModifierHealthBonus()
    if not self:GetAbility() then return end
    return self.health
end

function modifier_item_derzko:GetModifierManaBonus()
    if not self:GetAbility() then return end
    return self.mana
end

function modifier_item_derzko:GetModifierPreAttack_BonusDamage()
    if not self:GetAbility() then return end
    return self.damage
end