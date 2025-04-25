LinkLuaModifier( "modifier_item_drobe", "items/drobe", LUA_MODIFIER_MOTION_NONE )

item_drobe = class({})

function item_drobe:GetIntrinsicModifierName() 
    return "modifier_item_drobe"
end

modifier_item_drobe = class({})

function modifier_item_drobe:IsHidden() return true end
function modifier_item_drobe:IsPurgable() return false end
function modifier_item_drobe:IsPurgeException() return false end

function modifier_item_drobe:DeclareFunctions()
    return  
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
    }
end

function modifier_item_drobe:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_damage")
    end
end

function modifier_item_drobe:GetModifierConstantHealthRegen()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_hp_regen')
    end
end

function modifier_item_drobe:GetModifierConstantManaRegen()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
    end
end
function modifier_item_drobe:GetModifierBonusStats_Strength()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_str')
end

function modifier_item_drobe:GetModifierBonusStats_Agility()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_agi')
end
function modifier_item_drobe:GetModifierAttackRangeBonus()
    if not self:GetAbility() then return end
    if not self:GetParent():IsRangedAttacker() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_range')
end
function modifier_item_drobe:OnCreated()
    self.true_attack = true
end

function modifier_item_drobe:OnAttackLanded(params)
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end
    if params.target:IsBuilding() then return end
    if params.attacker:IsIllusion() then return end
    if self:GetParent():FindAllModifiersByName("modifier_item_drobe")[1] ~= self then return end
    if params.no_attack_cooldown then return end

    if self:GetParent():IsRangedAttacker() then
        local targets = FindUnitsInRadius(params.attacker:GetTeamNumber(),
            params.target:GetAbsOrigin(),
            nil,
            self:GetAbility():GetSpecialValueFor("radius"),
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
        for _,unit in pairs(targets) do
            if unit ~= params.target then 
                ApplyDamage({victim = unit, attacker = params.attacker, damage = params.damage * self:GetAbility():GetSpecialValueFor("cleave") / 100, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self:GetAbility()})
            end
        end
        self:PlayEffects(params.target)
    end
    self:GetParent():EmitSound("drobe_cast")
end
function modifier_item_drobe:PlayEffects(target)
    local particle_cast = "particles/kotl_ti10_blinding_light_groundring_new.vpcf"
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( effect_cast, 1, target:GetAbsOrigin() )
    ParticleManager:ReleaseParticleIndex(effect_cast)
end