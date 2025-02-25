modifier_golovach_e = class({})

function modifier_golovach_e:IsHidden()
	return false
end

function modifier_golovach_e:IsDebuff()
	return true
end

function modifier_golovach_e:IsStunDebuff()
	return false
end

function modifier_golovach_e:IsPurgable()
	return true
end

function modifier_golovach_e:OnCreated( kv )
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor( "freeze_damage" )
		self.duration = self:GetAbility():GetSpecialValueFor( "freeze_duration")
		self.cooldown = self:GetAbility():GetSpecialValueFor( "freeze_cooldown" )
		self.threshold = self:GetAbility():GetSpecialValueFor( "damage_trigger" )
		self.onCooldown = false
	end
end

function modifier_golovach_e:OnRefresh( kv )
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor( "freeze_damage" )
		self.duration = self:GetAbility():GetSpecialValueFor( "freeze_duration")
		self.cooldown = self:GetAbility():GetSpecialValueFor( "freeze_cooldown" )
		self.threshold = self:GetAbility():GetSpecialValueFor( "damage_trigger" )
	end
end
 
function modifier_golovach_e:OnDestroy( kv )

end

function modifier_golovach_e:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}

	return funcs
end

function modifier_golovach_e:OnTakeDamage( params )
	if IsServer() then
		if params.unit~=self:GetParent() then return end
		if params.attacker~=self:GetCaster() then return end
		if params.damage<self.threshold then return end
		if self.onCooldown then return end
		local random_chance = RandomInt(1, 100)
		if random_chance <= self:GetAbility():GetSpecialValueFor("hui_chance") then
			EmitSoundOn( "golovach_e_fail", self:GetParent() )
			return
		end
		self:Freeze()

		self:PlayEffects( params.attacker )
		self:PlayEffects1( params.unit )
	end
end

function modifier_golovach_e:OnIntervalThink()
	self.onCooldown = false
	self:StartIntervalThink(-1)
end

function modifier_golovach_e:Freeze()
	self.onCooldown = true
	self:GetParent():AddNewModifier(
		self:GetCaster(),
		self:GetAbility(),
		"modifier_generic_stunned_lua",
		{ duration = self.duration }
	)
	self:StartIntervalThink( self.cooldown )
end

function modifier_golovach_e:GetEffectName()
	return "particles/units/heroes/hero_invoker/invoker_cold_snap_status.vpcf"
end

function modifier_golovach_e:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_golovach_e:PlayEffects( attacker )
	local particle_cast = "particles/units/heroes/hero_invoker/invoker_cold_snap.vpcf"
	local sound_cast = "golovach_e"
	local direction = self:GetParent():GetOrigin()-attacker:GetOrigin()
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), 
		true
	)
	ParticleManager:SetParticleControl( effect_cast, 1,  self:GetParent():GetOrigin()+direction )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_golovach_e:PlayEffects1(target)
	local particle_cast = "particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/am_basher_c_gold.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, target )
	local direction = (target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
    ParticleManager:SetParticleControlForward(effect_cast, 0, direction)
    ParticleManager:SetParticleControlForward(effect_cast, 1, direction)
	ParticleManager:ReleaseParticleIndex(effect_cast) 
end