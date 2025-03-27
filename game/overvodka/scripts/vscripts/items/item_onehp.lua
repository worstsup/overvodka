LinkLuaModifier( "modifier_item_onehp", "items/item_onehp", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_onehp_active", "items/item_onehp", LUA_MODIFIER_MOTION_NONE )

item_onehp = class({})

function item_onehp:GetIntrinsicModifierName() 
    return "modifier_item_onehp"
end

modifier_item_onehp = class({})

function modifier_item_onehp:IsHidden() return true end
function modifier_item_onehp:IsPurgable() return false end
function modifier_item_onehp:IsPurgeException() return false end
function modifier_item_onehp:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_onehp:DeclareFunctions()
    return  
    {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_item_onehp:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_damage")
    end
end

function modifier_item_onehp:GetModifierHealthBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_health")
    end
end

function modifier_item_onehp:GetModifierManaBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_mana')
    end
end

function modifier_item_onehp:OnCreated()
    if not self:GetParent():IsRealHero() then return end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.check_interval = 0.1

    if IsServer() then
        self:StartIntervalThink(self.check_interval)
    end
end
function modifier_item_onehp:OnIntervalThink()
    if not IsServer() then return end
    if not self.ability or not self.parent or self.parent:IsIllusion() then return end
    if not self.ability:IsCooldownReady() then return end
    local current_health = self.parent:GetHealth()
    local max_health = self.parent:GetMaxHealth()
    local health_threshold = max_health * 0.15
    if current_health <= health_threshold then
        self.parent:Purge(false, true, false, true, false)
        self.parent:AddNewModifier(self.parent, self.ability, "modifier_item_onehp_active", {duration = self:GetAbility():GetSpecialValueFor("duration")})
        self.ability:StartCooldown(self.ability:GetCooldown(self.ability:GetLevel()))
        self:PlayEffects(self.parent)
        EmitSoundOn("onehp", self.parent)
    end
end
function modifier_item_onehp:PlayEffects(target)
    local particle_cast = "particles/ti9_banner_fireworksrockets_b_new.vpcf"
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( effect_cast, 1, target:GetAbsOrigin() )
    ParticleManager:ReleaseParticleIndex(effect_cast)
end

modifier_item_onehp_active = class({})

function modifier_item_onehp_active:IsHidden() return false end
function modifier_item_onehp_active:IsPurgable() return false end
function modifier_item_onehp_active:IsPurgeException() return false end

function modifier_item_onehp_active:DeclareFunctions()
    return  
    {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
end
function modifier_item_onehp_active:GetModifierIncomingDamage_Percentage()
    return -100
end

function modifier_item_onehp_active:GetModifierTotalDamageOutgoing_Percentage()
    return -100
end