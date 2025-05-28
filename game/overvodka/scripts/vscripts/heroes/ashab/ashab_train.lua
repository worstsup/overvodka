ashab_train = class({})
LinkLuaModifier( "modifier_train", "heroes/ashab/ashab_train", LUA_MODIFIER_MOTION_NONE )

function ashab_train:Precache(context)
	PrecacheResource( "soundfile", "soundevents/ashab_train.vsndevts", context )
	PrecacheResource( "particle", "particles/tamaev_train.vpcf", context )
end

function ashab_train:OnSpellStart()
	if not IsServer() then return end
	EmitSoundOn( "ashab_train", self:GetCaster() )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_train", { duration = self:GetSpecialValueFor( "duration" ) } )
end

modifier_train = class({})

function modifier_train:IsPurgable()
	return false
end

function modifier_train:OnCreated( kv )
	local particle = ParticleManager:CreateParticle("particles/tamaev_train.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(particle, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(particle, 3, self:GetParent():GetAbsOrigin())
	self:AddParticle(particle, false, false, -1, false, false)
	self.model_scale = self:GetAbility():GetSpecialValueFor( "model_scale" )
	self.bonus_status = self:GetAbility():GetSpecialValueFor( "bonus_status" )
	self.bonus_strength   = self:GetParent():GetStrength() * self:GetAbility():GetSpecialValueFor("bonus_strength") * 0.01
end

function modifier_train:OnRemoved()
end

function modifier_train:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
	}
	return funcs
end

function modifier_train:GetModifierModelScale( params )
	return self.model_scale
end

function modifier_train:GetModifierBonusStats_Strength( params )
	return self.bonus_strength
end

function modifier_train:GetModifierStatusResistance()
	return self.bonus_status
end