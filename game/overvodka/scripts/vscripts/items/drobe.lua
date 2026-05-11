LinkLuaModifier( "modifier_item_drobe", "items/drobe", LUA_MODIFIER_MOTION_NONE )

item_drobe = class({})

function item_drobe:GetIntrinsicModifierName() 
    return "modifier_item_drobe"
end

modifier_item_drobe = class({})

function modifier_item_drobe:IsHidden() return true end
function modifier_item_drobe:IsPurgable() return false end
function modifier_item_drobe:IsPurgeException() return false end
function modifier_item_drobe:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_drobe:OnCreated()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self.agi = self.ability:GetSpecialValueFor('bonus_agi')
    self.str = self.ability:GetSpecialValueFor('bonus_str')
    self.mana = self.ability:GetSpecialValueFor('bonus_mana_regen')
    self.damage = self.ability:GetSpecialValueFor('bonus_damage')
    self.hp_regen = self.ability:GetSpecialValueFor('bonus_hp_regen')
    self.radius = self.ability:GetSpecialValueFor('radius')
    self.bonus_range = 0
    if not IsServer() then return end
    self._txData = self._txData or {}
    self:SetHasCustomTransmitterData(true)
    self:UpdateBonusRange()
    self:StartIntervalThink(0.1)
    self:OnIntervalThink()
end

function modifier_item_drobe:OnIntervalThink()
    if not IsServer() then return end
    self:UpdateBonusRange()
    self:SendBuffRefreshToClients()
end

function modifier_item_drobe:HasAttackRangeConflict()
    return self.parent:HasItemInInventory("item_dragon_lance") or self.parent:HasItemInInventory("item_hurricane_pike") or self.parent:HasItemInInventory("item_hydras_breath")
end

function modifier_item_drobe:UpdateBonusRange()
    if not self.parent:IsRangedAttacker() then
        self.bonus_range = 0
        return
    end

    if self.parent:FindAllModifiersByName("modifier_item_drobe")[1] ~= self or self:HasAttackRangeConflict() then
        self.bonus_range = 0
        return
    end

    self.bonus_range = self.ability:GetSpecialValueFor('bonus_range')
end

function modifier_item_drobe:AddCustomTransmitterData()
    self._txData = self._txData or {}
    self._txData.bonus_range = self.bonus_range
    return self._txData
end

function modifier_item_drobe:HandleCustomTransmitterData( data )
    self.bonus_range = data.bonus_range
end

function modifier_item_drobe:DeclareFunctions()
    return {
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
    if not self.ability then return end
    return self.damage
end

function modifier_item_drobe:GetModifierConstantHealthRegen()
    if not self.ability then return end
    return self.hp_regen
end

function modifier_item_drobe:GetModifierConstantManaRegen()
    if not self.ability then return end
    return self.mana
end

function modifier_item_drobe:GetModifierBonusStats_Strength()
    if not self.ability then return end
    return self.str
end

function modifier_item_drobe:GetModifierBonusStats_Agility()
    if not self.ability then return end
    return self.agi
end

function modifier_item_drobe:GetModifierAttackRangeBonus()
    if not self.ability then return end
    return self.bonus_range
end

function modifier_item_drobe:OnAttackLanded(params)
    if params.attacker ~= self.parent then return end
    if params.target:IsWard() then return end
    if params.target:IsBuilding() then return end
    if self.parent:IsIllusion() then return end
    if self.parent:FindAllModifiersByName("modifier_item_drobe")[1] ~= self then return end
    if params.no_attack_cooldown then return end

    if self.parent:IsRangedAttacker() then
        local targets = FindUnitsInRadius(self.parent:GetTeamNumber(), params.target:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
        local damage_table = {
            attacker = self.parent,
            damage = params.damage * self.ability:GetSpecialValueFor("cleave") / 100,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self.ability,
        }
        for _,unit in pairs(targets) do
            if unit ~= params.target then 
                damage_table.victim = unit
                ApplyDamage(damage_table)
            end
        end
        self:PlayEffects(params.target)
    end
    self:GetParent():EmitSound("drobe_cast")
end

function modifier_item_drobe:PlayEffects(target)
    local effect_cast = ParticleManager:CreateParticle("particles/kotl_ti10_blinding_light_groundring_new.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(effect_cast, 1, target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
end