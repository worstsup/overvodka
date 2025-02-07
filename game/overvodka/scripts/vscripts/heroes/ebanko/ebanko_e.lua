LinkLuaModifier( "modifier_ebanko_e_smoke", "heroes/ebanko/ebanko_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ebanko_e_smoke_buff", "heroes/ebanko/ebanko_e", LUA_MODIFIER_MOTION_NONE )

ebanko_e = class({})

function ebanko_e:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function ebanko_e:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function ebanko_e:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function ebanko_e:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function ebanko_e:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")
    local thinker = CreateModifierThinker(caster, self, "modifier_ebanko_e_smoke", {duration = duration, target_point_x = point.x , target_point_y = point.y}, point, caster:GetTeamNumber(), false)
    caster:EmitSound("kakao")
end

modifier_ebanko_e_smoke = class({})

function modifier_ebanko_e_smoke:IsPurgable() return false end
function modifier_ebanko_e_smoke:IsHidden() return true end
function modifier_ebanko_e_smoke:IsAura() return true end

function modifier_ebanko_e_smoke:OnCreated()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    local particle = ParticleManager:CreateParticle("particles/riki_smokebomb_ebanko.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, self.radius, self.radius))  
    self:AddParticle(particle, false, false, -1, false, false)  
end

function modifier_ebanko_e_smoke:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY 
end

function modifier_ebanko_e_smoke:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_ebanko_e_smoke:GetModifierAura()
    return "modifier_ebanko_e_smoke_buff"
end

function modifier_ebanko_e_smoke:GetAuraRadius()
    return self.radius
end

modifier_ebanko_e_smoke_buff = class({})

function modifier_ebanko_e_smoke_buff:IsPurgable() return false end

function modifier_ebanko_e_smoke_buff:DeclareFunctions()
    local funcs = 
    { 
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL, 
        MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
    return funcs
end

function modifier_ebanko_e_smoke_buff:CheckState()
    local state = 
    {
        [MODIFIER_STATE_INVISIBLE] = true,
    }
    return state
end

function modifier_ebanko_e_smoke_buff:GetModifierInvisibilityLevel()
    return 1
end

function modifier_ebanko_e_smoke_buff:GetModifierHealthRegenPercentage()
    return self:GetAbility():GetSpecialValueFor("heal")
end

function modifier_ebanko_e_smoke_buff:GetModifierEvasion_Constant()
    return self:GetAbility():GetSpecialValueFor("evasion")
end

function modifier_ebanko_e_smoke_buff:GetOverrideAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end