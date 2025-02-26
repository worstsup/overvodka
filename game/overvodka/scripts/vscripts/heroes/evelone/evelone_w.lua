LinkLuaModifier( "modifier_evelone_w_smoke", "heroes/evelone/evelone_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_evelone_w_smoke_buff", "heroes/evelone/evelone_w", LUA_MODIFIER_MOTION_NONE )

evelone_w = class({})

function evelone_w:Precache(context)
    PrecacheResource("particle", "particles/evelone_w.vpcf", context)
    PrecacheResource("particle", "particles/evelone_w_night.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_phantom_assassin_persona/pa_persona_crit_impact.vpcf", context)
    PrecacheResource("soundfile", "soundevents/evelone_w.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/evelone_w_hit.vsndevts", context)
end

function evelone_w:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function evelone_w:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function evelone_w:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function evelone_w:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function evelone_w:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")
    local thinker = CreateModifierThinker(caster, self, "modifier_evelone_w_smoke", {duration = duration, target_point_x = point.x , target_point_y = point.y}, point, caster:GetTeamNumber(), false)
    caster:EmitSound("evelone_w")
end

modifier_evelone_w_smoke = class({})

function modifier_evelone_w_smoke:IsPurgable() return false end
function modifier_evelone_w_smoke:IsHidden() return true end
function modifier_evelone_w_smoke:IsAura() return true end

function modifier_evelone_w_smoke:OnCreated()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    local particle_name = "particles/evelone_w.vpcf"
    if self:GetCaster():HasModifier("modifier_evelone_r") then
        particle_name = "particles/evelone_w_night.vpcf"
    end
    local particle = ParticleManager:CreateParticle(particle_name, PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, self.radius, self.radius))  
    self:AddParticle(particle, false, false, -1, false, false)  
end

function modifier_evelone_w_smoke:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_BOTH 
end

function modifier_evelone_w_smoke:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_evelone_w_smoke:GetModifierAura()
    return "modifier_evelone_w_smoke_buff"
end

function modifier_evelone_w_smoke:GetAuraRadius()
    return self.radius
end

modifier_evelone_w_smoke_buff = class({})

function modifier_evelone_w_smoke_buff:IsDebuff()
    if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then return false end
    return true
end

function modifier_evelone_w_smoke_buff:IsPurgable() return false end

function modifier_evelone_w_smoke_buff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_MISS_PERCENTAGE,
        MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
    }
    return funcs
end

function modifier_evelone_w_smoke_buff:GetModifierMiss_Percentage()
    if IsServer() then
        if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then return end
        return self:GetAbility():GetSpecialValueFor("miss_chance")
    end
end

function modifier_evelone_w_smoke_buff:GetModifierPreAttack_CriticalStrike(params)
    if IsServer() then
        if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then return end
        if not self:GetParent():IsRealHero() then return end
        if self:GetParent():IsIllusion() then return end
        if not params.target:HasModifier("modifier_evelone_w_smoke_buff") then return end
        if self:RollChance(self:GetAbility():GetSpecialValueFor("crit_chance")) then
            self.record = params.record
            return self:GetAbility():GetSpecialValueFor("crit_bonus")
        end
    end
end

function modifier_evelone_w_smoke_buff:GetModifierProcAttack_Feedback( params )
	if IsServer() then
		if self.record then
			self.record = nil
			self:PlayEffects( params.target )
		end
	end
end

function modifier_evelone_w_smoke_buff:PlayEffects( target )
	local particle_cast = "particles/units/heroes/hero_phantom_assassin_persona/pa_persona_crit_impact.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		target:GetOrigin(),
		true
	)
	ParticleManager:SetParticleControlForward( effect_cast, 1, (self:GetParent():GetOrigin()-target:GetOrigin()):Normalized() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
    target:EmitSound("evelone_w_hit")
end

function modifier_evelone_w_smoke_buff:RollChance( chance )
	local rand = math.random()
	if rand<chance/100 then
		return true
	end
	return false
end