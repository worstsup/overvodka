LinkLuaModifier( "modifier_dave_sunflower_passive", "heroes/dave/dave_sunflower", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dave_sunflower_passive_aura", "heroes/dave/dave_sunflower", LUA_MODIFIER_MOTION_NONE )

dave_sunflower = class({})

function dave_sunflower:Precache(context)
    PrecacheResource("soundfile", "soundevents/gribochki.vsndevts", context )
    PrecacheResource("model", "pvz/sunflower_defaultflower_mesh.vmdl", context )
    PrecacheResource("particle", "particles/units/heroes/hero_treant/treant_eyesintheforest.vpcf", context )
end

function dave_sunflower:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function dave_sunflower:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function dave_sunflower:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function dave_sunflower:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function dave_sunflower:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    if point == self:GetCaster():GetAbsOrigin() then
        point = point + self:GetCaster():GetForwardVector()
    end
    local duration = self:GetSpecialValueFor('duration')
    local radius = self:GetSpecialValueFor( "radius" )
    caster:EmitSound("gribochki")
    GridNav:DestroyTreesAroundPoint(point, radius, false)
    self.sunflower = CreateUnitByName("npc_sunflower", point, true, caster, nil, caster:GetTeamNumber())
    self.sunflower:SetOwner(caster)
    FindClearSpaceForUnit(self.sunflower, self.sunflower:GetAbsOrigin(), true)
    self.sunflower:AddNewModifier(self:GetCaster(), self, "modifier_dave_sunflower_passive", {duration = duration})
end

modifier_dave_sunflower_passive = class({})

function modifier_dave_sunflower_passive:IsHidden()
    return true
end

function modifier_dave_sunflower_passive:IsPurgable()
    return false
end

function modifier_dave_sunflower_passive:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1)
    local duration = self:GetAbility():GetSpecialValueFor('duration')
    local radius = self:GetAbility():GetSpecialValueFor( "radius" )
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_eyesintheforest.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(radius, radius, radius))
    self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_dave_sunflower_passive:OnIntervalThink()
    local radius = self:GetAbility():GetSpecialValueFor( "radius" ) 
    local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

    for i,unit in ipairs(units) do
        local radius = self:GetAbility():GetSpecialValueFor( "radius" )
        local heal_pct = self:GetAbility():GetSpecialValueFor( "pct_heal" )
        local target_health_percentage = unit:GetHealth() / 100
        local base_damage = self:GetAbility():GetSpecialValueFor("base_damage")
        local damage_pct = self:GetAbility():GetSpecialValueFor("pct_damage")
        local total_damage = target_health_percentage * damage_pct + base_damage
        local caster_team = self:GetCaster():GetTeamNumber()

        if unit:GetTeamNumber() ~= caster_team then
            ApplyDamage({ victim = unit, attacker = self:GetCaster(), damage = total_damage, ability = self:GetAbility(), damage_type = self:GetAbility():GetAbilityDamageType() })
        else
            unit:GiveMana(heal_pct)
        end
    end
end


function modifier_dave_sunflower_passive:CheckState()
    local state = 
    { 
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_INVULNERABLE] = true
    }
    return state
end

function modifier_dave_sunflower_passive:IsAura() return true end

function modifier_dave_sunflower_passive:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY 
end

function modifier_dave_sunflower_passive:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_dave_sunflower_passive:GetModifierAura()
    return "modifier_dave_sunflower_passive_aura"
end

function modifier_dave_sunflower_passive:GetAuraDuration() return 0 end

function modifier_dave_sunflower_passive:GetAuraRadius()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("radius")
    end
end

function modifier_dave_sunflower_passive:OnDestroy()
    if not IsServer() then return end
    UTIL_Remove(self:GetParent())
end

modifier_dave_sunflower_passive_aura = class({})

function modifier_dave_sunflower_passive_aura:IsHidden()
    return false
end

function modifier_dave_sunflower_passive_aura:IsPurgable()
    return false
end

function modifier_dave_sunflower_passive_aura:OnCreated()
    if not IsServer() then return end
end

function modifier_dave_sunflower_passive_aura:OnDestroy()
    if not IsServer() then return end
end

function modifier_dave_sunflower_passive_aura:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end

function modifier_dave_sunflower_passive_aura:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow")
end