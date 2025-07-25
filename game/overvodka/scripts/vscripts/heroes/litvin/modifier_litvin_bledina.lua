modifier_litvin_bledina = class({})

function modifier_litvin_bledina:IsPurgable()
	return false
end

function modifier_litvin_bledina:OnCreated( kv )
	self.bat = self:GetAbility():GetSpecialValueFor( "bat" )
	self.max_attacks = self:GetAbility():GetSpecialValueFor("max_attacks")
	if IsServer() then
		self:SetStackCount(self.max_attacks)
	end
	self:PlayEffects1()
end

function modifier_litvin_bledina:OnRemoved()
end

function modifier_litvin_bledina:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}
	return funcs
end

function modifier_litvin_bledina:GetModifierBaseAttackTimeConstant()
	return self.bat
end

function modifier_litvin_bledina:GetModifierAttackSpeedBonus_Constant()
	return 2000
end

function modifier_litvin_bledina:GetModifierProcAttack_Feedback( params )
	self:PlayEffects2( self:GetParent(), params.target )
	if IsServer() then
		self:DecrementStackCount()
		if self:GetStackCount() < 1 then
			self:Destroy()
		end
	end
end

function modifier_litvin_bledina:PlayEffects1()
	local particle_cast = "particles/units/heroes/hero_marci/marci_unleash_buff.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"eye_l",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		2,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"eye_r",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		3,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		4,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_attack2",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		5,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		6,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_attack2",
		Vector(0,0,0),
		true
	)
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
end

function modifier_litvin_bledina:PlayEffects2( caster, target )
	local particle_cast = "particles/units/heroes/hero_marci/marci_unleash_attack.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end