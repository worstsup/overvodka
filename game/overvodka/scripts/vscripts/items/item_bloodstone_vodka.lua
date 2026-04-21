LinkLuaModifier("modifier_item_bloodstone_vodka", "items/item_bloodstone_vodka", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_bloodstone_vodka_active", "items/item_bloodstone_vodka", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_bloodstone_vodka_aura_debuff", "items/item_bloodstone_vodka", LUA_MODIFIER_MOTION_NONE)

item_bloodstone_vodka = class({})

function item_bloodstone_vodka:GetIntrinsicModifierName()
    return "modifier_item_bloodstone_vodka"
end

function item_bloodstone_vodka:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local duration = self:GetSpecialValueFor("buff_duration")
    caster:AddNewModifier(caster, self, "modifier_item_bloodstone_vodka_active", { duration = duration })
    caster:EmitSound("DOTA_Item.Bloodstone.Cast")
end

modifier_item_bloodstone_vodka = class({})

function modifier_item_bloodstone_vodka:IsHidden() return true end
function modifier_item_bloodstone_vodka:IsPurgable() return false end
function modifier_item_bloodstone_vodka:IsPurgeException() return false end
function modifier_item_bloodstone_vodka:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_bloodstone_vodka:OnCreated()
    self:RefreshValues()
end

function modifier_item_bloodstone_vodka:OnRefresh()
    self:RefreshValues()
end

function modifier_item_bloodstone_vodka:RefreshValues()
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return end

    self.bonus_health = ability:GetSpecialValueFor("bonus_health")
    self.bonus_mana = ability:GetSpecialValueFor("bonus_mana")
    self.bonus_mp_regen = ability:GetSpecialValueFor("bonus_mp_regen")
    self.bonus_hp_regen = ability:GetSpecialValueFor("bonus_hp_regen")
    self.bonus_intellect = ability:GetSpecialValueFor("bonus_intellect")
    self.spell_lifesteal = ability:GetSpecialValueFor("spell_lifesteal")
    self.spell_lifesteal_while_active = ability:GetSpecialValueFor("spell_lifesteal_while_active")
    self.aura_radius = ability:GetSpecialValueFor("aura_radius")
end

function modifier_item_bloodstone_vodka:IsItemActive()
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return false end
    if ability:IsInBackpack() then return false end

    local parent = self:GetParent()
    if not parent or parent:IsNull() then return false end

    for _, modifier in pairs(parent:FindAllModifiersByName("modifier_item_bloodstone_vodka_active")) do
        if modifier and not modifier:IsNull() and modifier:GetAbility() == ability then
            return true
        end
    end

    return false
end

function modifier_item_bloodstone_vodka:IsItemReady()
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return false end
    return not ability:IsInBackpack()
end

function modifier_item_bloodstone_vodka:HasActiveElixirCollector()
    if not IsServer() then return false end
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return false end

    for slot = 0, 5 do
        local item = parent:GetItemInSlot(slot)
        if item and not item:IsNull() and item:GetName() == "item_elixir_collector" then
            return true
        end
    end

    return false
end

function modifier_item_bloodstone_vodka:IsPassiveReady()
    return self:IsItemReady() and not self:HasActiveElixirCollector()
end

function modifier_item_bloodstone_vodka:IsPrimaryBloodstoneModifier()
    if not IsServer() then return false end
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return false end

    for _, modifier in pairs(parent:FindAllModifiersByName("modifier_item_bloodstone_vodka")) do
        if modifier and not modifier:IsNull() and modifier.IsPassiveReady and modifier:IsPassiveReady() then
            return modifier == self
        end
    end

    return false
end

function modifier_item_bloodstone_vodka:GetBestBloodstoneSpellLifesteal()
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return 0 end

    local best_lifesteal = 0
    for _, modifier in pairs(parent:FindAllModifiersByName("modifier_item_bloodstone_vodka")) do
        if modifier and not modifier:IsNull() and modifier.IsPassiveReady and modifier:IsPassiveReady() then
            local current_lifesteal = modifier.spell_lifesteal or 0
            if modifier.IsItemActive and modifier:IsItemActive() then
                current_lifesteal = modifier.spell_lifesteal_while_active or current_lifesteal
            end

            if current_lifesteal > best_lifesteal then
                best_lifesteal = current_lifesteal
            end
        end
    end

    return best_lifesteal
end


function modifier_item_bloodstone_vodka:IsAura()
    return self:IsPassiveReady() and self:IsPrimaryBloodstoneModifier()
end

function modifier_item_bloodstone_vodka:GetModifierAura()
    return "modifier_item_bloodstone_vodka_aura_debuff"
end

function modifier_item_bloodstone_vodka:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_bloodstone_vodka:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_item_bloodstone_vodka:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_bloodstone_vodka:GetAuraRadius()
    if not self:IsPassiveReady() or not self:IsPrimaryBloodstoneModifier() then return 0 end
    return self.aura_radius or 0
end

function modifier_item_bloodstone_vodka:GetAuraDuration()
    return 0.5
end

function modifier_item_bloodstone_vodka:AuraEntityReject(target)
    if not target or target:IsNull() then return true end
    if target:IsBuilding() or target:IsOther() then return true end
    if target:IsInvulnerable() or target:IsOutOfGame() then return true end
    return false
end

function modifier_item_bloodstone_vodka:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_item_bloodstone_vodka:GetModifierHealthBonus()
    return self:IsItemReady() and (self.bonus_health or 0) or 0
end

function modifier_item_bloodstone_vodka:GetModifierManaBonus()
    return self:IsItemReady() and (self.bonus_mana or 0) or 0
end

function modifier_item_bloodstone_vodka:GetModifierConstantManaRegen()
    return self:IsItemReady() and (self.bonus_mp_regen or 0) or 0
end

function modifier_item_bloodstone_vodka:GetModifierConstantHealthRegen()
    return self:IsItemReady() and (self.bonus_hp_regen or 0) or 0
end

function modifier_item_bloodstone_vodka:GetModifierBonusStats_Intellect()
    return self:IsItemReady() and (self.bonus_intellect or 0) or 0
end

function modifier_item_bloodstone_vodka:IsValidSpellLifestealDamage(params)
    if not params then return false end
    if self:GetParent() ~= params.attacker then return false end
    if self:GetParent() == params.unit then return false end
    if not params.unit or params.unit:IsNull() then return false end
    if params.unit:IsBuilding() or params.unit:IsOther() then return false end
    if params.unit:IsInvulnerable() or params.unit:IsOutOfGame() then return false end
    if self:GetParent():IsIllusion() then return false end
    if not params.damage or params.damage <= 0 then return false end

    local flags = params.damage_flags or 0
    if bit.band(flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then return false end
    if bit.band(flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) == DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then return false end

    if params.damage_type == DAMAGE_TYPE_MAGICAL then return true end
    if params.inflictor ~= nil and params.damage_type == DAMAGE_TYPE_PHYSICAL then return true end

    return false
end

function modifier_item_bloodstone_vodka:GetSpellLifestealAmplification()
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return 0 end

    local bonus_percentage = 0
    for _, modifier in pairs(parent:FindAllModifiers()) do
        if modifier ~= self and modifier.GetModifierSpellLifestealRegenAmplify_Percentage then
            local value = modifier:GetModifierSpellLifestealRegenAmplify_Percentage()
            if value then
                bonus_percentage = bonus_percentage + value
            end
        end
    end

    return bonus_percentage
end

function modifier_item_bloodstone_vodka:OnTakeDamage(params)
    if not IsServer() then return end
    if not self:IsPrimaryBloodstoneModifier() then return end
    if not self:IsPassiveReady() then return end
    if not self:IsValidSpellLifestealDamage(params) then return end

    local lifesteal = self:GetBestBloodstoneSpellLifesteal()
    if lifesteal <= 0 then return end

    if not params.unit:IsRealHero() then
        lifesteal = lifesteal * 0.2
    end

    local amplify = self:GetSpellLifestealAmplification()
    local heal = params.damage * lifesteal * 0.01 * (1 + amplify * 0.01)
    if heal <= 0 then return end

    local parent = self:GetParent()
    parent:Heal(heal, params.inflictor or self:GetAbility())

    local lifesteal_particle = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:ReleaseParticleIndex(lifesteal_particle)
end

modifier_item_bloodstone_vodka_active = class({})

function modifier_item_bloodstone_vodka_active:IsHidden() return false end
function modifier_item_bloodstone_vodka_active:IsPurgable() return false end
function modifier_item_bloodstone_vodka_active:IsPurgeException() return false end
function modifier_item_bloodstone_vodka_active:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_bloodstone_vodka_active:RefreshValues()
    local ability = self:GetAbility()
    if ability and not ability:IsNull() then
        self.spell_lifesteal_while_active = ability:GetSpecialValueFor("spell_lifesteal_while_active")
    else
        self.spell_lifesteal_while_active = 0
    end
end

function modifier_item_bloodstone_vodka_active:OnCreated()
    self:RefreshValues()

    if not IsServer() then return end

    self._txData = self._txData or {}
    self:SetHasCustomTransmitterData(true)

    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    local particle = ParticleManager:CreateParticle("particles/items_fx/bloodstone_heal.vpcf", PATTACH_OVERHEAD_FOLLOW, parent)
    ParticleManager:SetParticleControl(particle, 0, parent:GetAbsOrigin())
    self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_item_bloodstone_vodka_active:OnRefresh()
    self:RefreshValues()
    if not IsServer() then return end
    self:SendBuffRefreshToClients()
end

function modifier_item_bloodstone_vodka_active:AddCustomTransmitterData()
    self._txData = self._txData or {}
    self._txData.spell_lifesteal_while_active = self.spell_lifesteal_while_active or 0
    return self._txData
end

function modifier_item_bloodstone_vodka_active:HandleCustomTransmitterData(data)
    self.spell_lifesteal_while_active = data.spell_lifesteal_while_active or 0
end

function modifier_item_bloodstone_vodka_active:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_item_bloodstone_vodka_active:OnTooltip()
    return self.spell_lifesteal_while_active
end

modifier_item_bloodstone_vodka_aura_debuff = class({})

function modifier_item_bloodstone_vodka_aura_debuff:IsHidden() return false end
function modifier_item_bloodstone_vodka_aura_debuff:IsDebuff() return true end
function modifier_item_bloodstone_vodka_aura_debuff:IsPurgable() return false end
function modifier_item_bloodstone_vodka_aura_debuff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_item_bloodstone_vodka_aura_debuff:RefreshValues()
    local ability = self:GetAbility()
    if ability and not ability:IsNull() then
        self.aura_spell_vulnerability = ability:GetSpecialValueFor("aura_spell_vulnerability")
    else
        self.aura_spell_vulnerability = 0
    end

    if not IsServer() then return end

    if self:IsPrimarySpellWeakness() then
        self.tooltip_spell_vulnerability = self.aura_spell_vulnerability or 0
        self.incoming_damage_pct = math.max((self.aura_spell_vulnerability or 0) - self:GetVeilSpellWeakness(), 0)
    else
        self.tooltip_spell_vulnerability = 0
        self.incoming_damage_pct = 0
    end
end

function modifier_item_bloodstone_vodka_aura_debuff:OnCreated()
    self:RefreshValues()
    if not IsServer() then return end

    self._txData = self._txData or {}
    self:SetHasCustomTransmitterData(true)
end

function modifier_item_bloodstone_vodka_aura_debuff:OnRefresh()
    self:RefreshValues()
    if not IsServer() then return end
    self:SendBuffRefreshToClients()
end

function modifier_item_bloodstone_vodka_aura_debuff:AddCustomTransmitterData()
    self._txData = self._txData or {}
    self._txData.aura_spell_vulnerability = self.aura_spell_vulnerability or 0
    self._txData.tooltip_spell_vulnerability = self.tooltip_spell_vulnerability or 0
    self._txData.incoming_damage_pct = self.incoming_damage_pct or 0
    return self._txData
end

function modifier_item_bloodstone_vodka_aura_debuff:HandleCustomTransmitterData(data)
    self.aura_spell_vulnerability = data.aura_spell_vulnerability or 0
    self.tooltip_spell_vulnerability = data.tooltip_spell_vulnerability or 0
    self.incoming_damage_pct = data.incoming_damage_pct or 0
end

function modifier_item_bloodstone_vodka_aura_debuff:IsElixirCollectorSource()
    local ability = self:GetAbility()
    return ability and not ability:IsNull() and ability:GetName() == "item_elixir_collector"
end

function modifier_item_bloodstone_vodka_aura_debuff:GetSourcePriority()
    if self:IsElixirCollectorSource() then return 2 end
    return 1
end

function modifier_item_bloodstone_vodka_aura_debuff:IsPrimarySpellWeakness()
    if not IsServer() then return false end
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return false end

    local best_modifier = nil
    local best_priority = -1
    local best_vulnerability = -1

    for _, modifier in pairs(parent:FindAllModifiersByName("modifier_item_bloodstone_vodka_aura_debuff")) do
        if modifier and not modifier:IsNull() and modifier.GetSourcePriority then
            local priority = modifier:GetSourcePriority()
            local vulnerability = modifier.aura_spell_vulnerability or 0

            if priority > best_priority or (priority == best_priority and vulnerability > best_vulnerability) then
                best_modifier = modifier
                best_priority = priority
                best_vulnerability = vulnerability
            end
        end
    end

    return best_modifier == self
end

function modifier_item_bloodstone_vodka_aura_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_item_bloodstone_vodka_aura_debuff:GetVeilSpellWeakness()
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return 0 end

    local veil = parent:FindModifierByName("modifier_item_veil_of_discord_debuff")
    if not veil or veil:IsNull() then return 0 end

    local ability = veil:GetAbility()
    if ability and not ability:IsNull() then
        local spell_amp = ability:GetSpecialValueFor("spell_amp")
        if spell_amp and spell_amp > 0 then
            return spell_amp
        end
    end

    return 0
end

function modifier_item_bloodstone_vodka_aura_debuff:GetModifierIncomingDamage_Percentage(params)
    if not params then return 0 end
    if params.inflictor == nil then return 0 end
    if not IsServer() then
        return self.incoming_damage_pct or 0
    end
    if not self:IsPrimarySpellWeakness() then return 0 end
    return math.max((self.aura_spell_vulnerability or 0) - self:GetVeilSpellWeakness(), 0)
end

function modifier_item_bloodstone_vodka_aura_debuff:OnTooltip()
    if not IsServer() then
        return self.tooltip_spell_vulnerability or 0
    end
    if not self:IsPrimarySpellWeakness() then return 0 end
    return self.aura_spell_vulnerability or 0
end
