LinkLuaModifier("modifier_item_silvername_chair",          "items/silvername_chair", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_silvername_chair_buff",     "items/silvername_chair", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_silvername_chair_unit",     "items/silvername_chair", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_silvername_chair_redirect", "items/silvername_chair", LUA_MODIFIER_MOTION_NONE)

item_silvername_chair = class({})

function item_silvername_chair:GetIntrinsicModifierName()
    return "modifier_item_silvername_chair"
end

function item_silvername_chair:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("chair_duration") or 0
    local radius   = self:GetSpecialValueFor("aura_radius") or 1200

    if duration <= 0 then return end

    if caster.silvername_chair_unit and not caster.silvername_chair_unit:IsNull() then
        local mod = caster.silvername_chair_unit:FindModifierByName("modifier_silvername_w_facet_2_target")
        if mod and not mod:IsNull() then
            mod:Destroy()
        end
        caster.silvername_chair_unit:ForceKill(false)
        UTIL_Remove(caster.silvername_chair_unit)
        caster.silvername_chair_unit = nil
    end

    local sum_hp = math.max(1, caster:GetHealth())

    local team = caster:GetTeamNumber()
    local owner = caster

    local allies = FindUnitsInRadius(
        team,
        caster:GetAbsOrigin(),
        nil,
        10000,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
        FIND_ANY_ORDER,
        false
    )

    for _,unit in ipairs(allies) do
        if unit and not unit:IsNull() and unit ~= caster and unit:GetOwner() == owner then
            if not unit:IsBuilding() and not unit:IsOther() and not unit:IsWard() then
                sum_hp = sum_hp + math.max(unit:GetHealth(), 0)
            end
        end
    end

    if sum_hp <= 0 then
        sum_hp = 1
    end

    local chair = CreateUnitByName("npc_silvername_chair", point, true, caster, caster, team)

    chair:SetOwner(caster)
    chair:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)

    sum_hp = math.floor( sum_hp * self:GetSpecialValueFor("chair_hp_pct") * 0.01 )
    chair:SetBaseMaxHealth(sum_hp)
    chair:SetMaxHealth(sum_hp)
    chair:SetHealth(sum_hp)

    chair:AddNewModifier(caster, self, "modifier_phased", {})
    chair:AddNewModifier(caster, self, "modifier_kill", { duration = duration })
    chair:AddNewModifier(caster, self, "modifier_item_silvername_chair_unit", {})

    caster.silvername_chair_unit = chair
end

modifier_item_silvername_chair = class({})

function modifier_item_silvername_chair:IsHidden() return true end
function modifier_item_silvername_chair:IsPurgable() return false end
function modifier_item_silvername_chair:IsPurgeException() return false end
function modifier_item_silvername_chair:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_silvername_chair:AllowIllusionDuplicate() return true end

function modifier_item_silvername_chair:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK_SPECIAL,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
end

function modifier_item_silvername_chair:GetModifierHealthBonus()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_health')
end

function modifier_item_silvername_chair:GetModifierConstantHealthRegen()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_health_regen')
end

function modifier_item_silvername_chair:GetModifierPhysical_ConstantBlockSpecial()
    if not self:GetAbility() then return end
    if self:GetParent():FindAllModifiersByName("modifier_item_silvername_chair")[1] ~= self then return end
    if self:GetParent():HasModifier("modifier_item_vanguard") then return end

	if RollPercentage(self:GetAbility():GetSpecialValueFor("chance")) then
        if self:GetParent():IsRangedAttacker() then
   		    return self:GetAbility():GetSpecialValueFor("block_range")
        end
        return self:GetAbility():GetSpecialValueFor("block_melee")
   	end
end

function modifier_item_silvername_chair:GetModifierPhysicalArmorBonus()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_armor')
end

function modifier_item_silvername_chair:GetModifierConstantManaRegen()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_mana_regen')
end

function modifier_item_silvername_chair:IsAura() return true end
function modifier_item_silvername_chair:IsAuraActiveOnDeath() return false end

function modifier_item_silvername_chair:GetAuraRadius()
    if not self:GetAbility() then return 0 end
    if self:GetParent():HasModifier("modifier_item_vladmir") then return 0 end
	return self:GetAbility():GetSpecialValueFor('aura_radius')
end

function modifier_item_silvername_chair:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_item_silvername_chair:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_silvername_chair:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_item_silvername_chair:GetModifierAura()
	return "modifier_item_silvername_chair_buff"
end

function modifier_item_silvername_chair:GetAuraDuration()
    return 0.5
end

modifier_item_silvername_chair_buff = class({})

function modifier_item_silvername_chair_buff:IsHidden() return false end
function modifier_item_silvername_chair_buff:IsPurgable() return false end

function modifier_item_silvername_chair_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_item_silvername_chair_buff:GetModifierPhysicalArmorBonus()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('aura_armor')
end

function modifier_item_silvername_chair_buff:GetModifierConstantManaRegen()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('aura_mana_regen')
end

function modifier_item_silvername_chair_buff:GetModifierDamageOutgoing_Percentage()
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return 0 end
    return ability:GetSpecialValueFor('aura_damage_pct')
end

function modifier_item_silvername_chair_buff:OnTakeDamage(params)
    if not IsServer() then return end

    local parent  = self:GetParent()
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return end

    if parent ~= params.attacker then return end
    if parent == params.unit then return end

    local victim = params.unit
    if not victim or victim:IsNull() then return end
    if victim:IsBuilding() or victim:IsWard() or victim:IsOther() then return end

    local damage_flags = params.damage_flags or 0

    if params.inflictor == nil and bit.band(damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
        local damage = params.damage or 0
        if damage <= 0 then return end

        local lifesteal_pct = ability:GetSpecialValueFor("aura_lifesteal_heroes") or 0
        if victim:IsCreep() then
            lifesteal_pct = ability:GetSpecialValueFor("aura_lifesteal_creeps") or lifesteal_pct
        end

        if lifesteal_pct ~= 0 then
            local heal = damage * lifesteal_pct * 0.01
            if heal > 0 then
                parent:HealWithParams(heal, ability, true, true, parent, false)

                local effect_cast = ParticleManager:CreateParticle(
                    "particles/generic_gameplay/generic_lifesteal.vpcf",
                    PATTACH_ABSORIGIN_FOLLOW,
                    parent
                )
                ParticleManager:ReleaseParticleIndex(effect_cast)
            end
        end
    end
end

modifier_item_silvername_chair_unit = class({})

function modifier_item_silvername_chair_unit:IsHidden()   return true end
function modifier_item_silvername_chair_unit:IsPurgable() return false end
function modifier_item_silvername_chair_unit:IsAura() return true end
function modifier_item_silvername_chair_unit:IsAuraActiveOnDeath() return false end

function modifier_item_silvername_chair_unit:GetAuraRadius()
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return 0 end
    return ability:GetSpecialValueFor("aura_radius")
end

function modifier_item_silvername_chair_unit:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_silvername_chair_unit:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_item_silvername_chair_unit:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_item_silvername_chair_unit:GetModifierAura()
    return "modifier_item_silvername_chair_redirect"
end

function modifier_item_silvername_chair_unit:GetAuraDuration()
    return 0.5
end

function modifier_item_silvername_chair_unit:GetAuraEntityReject(target)
    if target == self:GetParent() then
        return true
    end
    return false
end

function modifier_item_silvername_chair_unit:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end

function modifier_item_silvername_chair_unit:OnIntervalThink()
    if not IsServer() then return end
    if not self or self:IsNull() then return end
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end
    if not parent:IsAlive() then
        self:Destroy()
        return
    end
end

function modifier_item_silvername_chair_unit:OnDestroy()
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    local owner = parent:GetOwner()
    if owner and not owner:IsNull() and owner.silvername_chair_unit == parent then
        owner.silvername_chair_unit = nil
    end
end

modifier_item_silvername_chair_redirect = class({})

function modifier_item_silvername_chair_redirect:IsHidden()   return false end
function modifier_item_silvername_chair_redirect:IsPurgable() return false end

function modifier_item_silvername_chair_redirect:OnCreated(kv)
    if not IsServer() then return end
    self.parent  = self:GetParent()
    self.ability = self:GetAbility()
    self.chair   = self:GetAuraOwner()

    if self.ability and not self.ability:IsNull() then
        self.owner = self.ability:GetCaster()
    else
        self.owner = nil
    end
end

function modifier_item_silvername_chair_redirect:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_item_silvername_chair_redirect:OnTakeDamage(params)
    if not IsServer() then return end

    local victim = params.unit
    if victim ~= self.parent then return end

    local chair = self.chair
    if not chair or chair:IsNull() or not chair:IsAlive() then
        self:Destroy()
        return
    end

    local owner = self.owner
    if not owner or owner:IsNull() then return end

    local unit_owner = victim:GetOwner()
    if victim ~= owner and unit_owner ~= owner then
        return
    end

    local flags = params.damage_flags or 0
    if bit.band(flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then
        return
    end

    if victim:IsBuilding() or victim:IsOther() or victim:IsWard() then
        return
    end

    local damage = params.damage or 0
    if damage <= 0 then return end

    local hp_after = victim:GetHealth()
    victim:SetHealth( math.min(victim:GetMaxHealth(), hp_after + damage) )

    local dmg_table = {
        victim = chair,
        attacker = params.attacker or owner,
        damage = damage,
        damage_type = params.damage_type or DAMAGE_TYPE_PURE,
        ability = params.inflictor,
        damage_flags = bit.bor(flags, DOTA_DAMAGE_FLAG_REFLECTION, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION),
    }
    ApplyDamage(dmg_table)
end