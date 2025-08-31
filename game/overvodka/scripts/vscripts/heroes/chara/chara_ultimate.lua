LinkLuaModifier("modifier_chara_ultimate", "heroes/chara/chara_ultimate", LUA_MODIFIER_MOTION_NONE)

chara_ultimate = class({})

function chara_ultimate:Precache(ctx)
    PrecacheResource("soundfile", "soundevents/chara_sounds.vsndevts", ctx)
    PrecacheResource("particle", "particles/quadrobe_buff.vpcf", ctx)
    PrecacheResource("particle", "particles/chara_r_status.vpcf", ctx)
    PrecacheResource("particle", "particles/econ/items/drow/drow_arcana/drow_arcana_lifesteal.vpcf", ctx)
    PrecacheResource("particle", "particles/chara_r.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_life_stealer/life_stealer_infest_cast.vpcf", ctx)
end

function chara_ultimate:OnAbilityPhaseStart()
    self.random = RandomInt(1,2)
    EmitSoundOn("chara_r_cast_"..self.random, self:GetCaster())
    return true
end

function chara_ultimate:OnAbilityPhaseInterrupted()
    StopSoundOn("chara_r_cast_"..self.random, self:GetCaster())
end

function chara_ultimate:OnSpellStart()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_chara_ultimate", {duration = self:GetSpecialValueFor("duration")})
    EmitSoundOn("chara_r_"..self.random, self:GetCaster())
    local p = ParticleManager:CreateParticle("particles/chara_r.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(p, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(p, 1, self:GetCaster():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(p)
end

modifier_chara_ultimate = class({})

function modifier_chara_ultimate:IsHidden() return false end
function modifier_chara_ultimate:IsPurgable() return false end

function modifier_chara_ultimate:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
        MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_chara_ultimate:OnDestroy()
    if not IsServer() then return end
    local p = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(p, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(p, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(p)
    if not self:GetAbility() then return end
    StopSoundOn("chara_r_"..self:GetAbility().random, self:GetCaster())
end

function modifier_chara_ultimate:GetModifierBaseAttackTimeConstant()
    return self:GetAbility():GetSpecialValueFor("bat")
end
 
function modifier_chara_ultimate:OnCreated()
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.lifesteal = self:GetAbility():GetSpecialValueFor( "lifesteal_pct" )/100
	if not IsServer() then return end
end

function modifier_chara_ultimate:GetModifierProcAttack_Feedback( params )
	if not IsServer() then return end
	if params.target:GetTeamNumber()==self.parent:GetTeamNumber() then return end
	if params.target:IsBuilding() or params.target:IsOther() then return end
	self.attack_record = params.record
end

function modifier_chara_ultimate:OnTakeDamage( params )
	if not IsServer() then return end
	if self.attack_record ~= params.record then return end
	local heal = params.damage * self.lifesteal
	self.parent:Heal( heal, self.ability )
	self:PlayEffects2()
end

function modifier_chara_ultimate:ShouldUseOverheadOffset()
	return true
end

function modifier_chara_ultimate:GetStatusEffectName()
	return "particles/chara_r_status.vpcf"
end

function modifier_chara_ultimate:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function modifier_chara_ultimate:PlayEffects2()
	local particle_cast = "particles/econ/items/drow/drow_arcana/drow_arcana_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_chara_ultimate:GetEffectName()
    return "particles/quadrobe_buff.vpcf"
end

function modifier_chara_ultimate:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end