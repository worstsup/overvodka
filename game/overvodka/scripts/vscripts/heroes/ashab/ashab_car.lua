LinkLuaModifier("modifier_ashab_car_passive", "heroes/ashab/ashab_car", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ashab_car_passive_aura", "heroes/ashab/ashab_car", LUA_MODIFIER_MOTION_NONE)

ashab_car = class({})

function ashab_car:Precache(context)
    PrecacheResource( "soundfile", "soundevents/ashab_car.vsndevts", context )
    PrecacheResource( "model", "models/items/courier/carty_dire/carty_dire_flying.vmdl", context )
    PrecacheResource( "particle", "particles/ashab_car_aoe.vpcf", context )
end

function ashab_car:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function ashab_car:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function ashab_car:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function ashab_car:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function ashab_car:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")
    local gold = self:GetSpecialValueFor("gold")
    local xp = self:GetSpecialValueFor("xp")
    local car = CreateUnitByName("npc_ashab_car", point, true, caster, caster, caster:GetTeamNumber())
    FindClearSpaceForUnit(car, point, true)
    car:SetControllableByPlayer(caster:GetPlayerID(), false)
    car:SetOwner(caster)
    car:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
    car:AddNewModifier(caster, self, "modifier_phased", {duration = duration})
    car:SetMaximumGoldBounty(gold)
    car:SetMinimumGoldBounty(gold)
    car:SetDeathXP(xp)
    EmitSoundOn("ashab_car", caster)
    car:AddNewModifier(self:GetCaster(), self, "modifier_ashab_car_passive", {duration = duration})
end

modifier_ashab_car_passive = class({})

function modifier_ashab_car_passive:IsHidden()
    return true
end

function modifier_ashab_car_passive:IsPurgable()
    return false
end

function modifier_ashab_car_passive:OnCreated()
    if not IsServer() then return end
    local base_hp = self:GetAbility():GetSpecialValueFor("base_hp")
    self:GetParent():SetBaseMaxHealth(base_hp)
    self:GetParent():SetMaxHealth(base_hp)
    self:GetParent():SetHealth(base_hp)
    local particle = ParticleManager:CreateParticle("particles/ashab_car_aoe.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"), self:GetAbility():GetSpecialValueFor("radius"), self:GetAbility():GetSpecialValueFor("radius")))
    ParticleManager:SetParticleControl(particle, 2, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 3, self:GetParent():GetAbsOrigin())
    self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_ashab_car_passive:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS,
        MODIFIER_PROPERTY_DISABLE_HEALING
    }
    return funcs
end

function modifier_ashab_car_passive:OnAttackLanded(keys)
    if not IsServer() then return end
    if keys.target == self:GetParent() then
        if keys.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() then
            if self:GetParent():GetHealthPercent() > 50 then
                self:GetParent():SetHealth(self:GetParent():GetHealth() - 10)
            else 
                self:GetParent():Kill(nil, keys.attacker)
            end
            return
        end
        local new_health = self:GetParent():GetHealth() - 1
        new_health = math.floor(new_health)
        if new_health <= 0 then
            self:GetParent():Kill(nil, keys.attacker)
        else
            self:GetParent():SetHealth(new_health)
        end
    end
end

function modifier_ashab_car_passive:GetDisableHealing()
    return 1
end

function modifier_ashab_car_passive:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end

function modifier_ashab_car_passive:GetModifierHealthBarPips()
    return self:GetParent():GetMaxHealth()
end

function modifier_ashab_car_passive:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_ashab_car_passive:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_ashab_car_passive:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_ashab_car_passive:IsAura() return true end

function modifier_ashab_car_passive:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_ashab_car_passive:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_ashab_car_passive:GetModifierAura()
    return "modifier_ashab_car_passive_aura"
end

function modifier_ashab_car_passive:GetAuraDuration()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("aura_duration")
    end
end

function modifier_ashab_car_passive:GetAuraRadius()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("radius")
    end
end

modifier_ashab_car_passive_aura = class({})

function modifier_ashab_car_passive_aura:IsHidden()
    return false
end

function modifier_ashab_car_passive_aura:IsPurgable()
    return false
end

function modifier_ashab_car_passive_aura:OnCreated()
    if not IsServer() then return end
end

function modifier_ashab_car_passive_aura:OnDestroy()
    if not IsServer() then return end
end

function modifier_ashab_car_passive_aura:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
    return funcs
end

function modifier_ashab_car_passive_aura:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_ms")
end

function modifier_ashab_car_passive_aura:GetModifierHealthRegenPercentage()
    return self:GetAbility():GetSpecialValueFor("hpregen")
end

function modifier_ashab_car_passive_aura:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_as")
end