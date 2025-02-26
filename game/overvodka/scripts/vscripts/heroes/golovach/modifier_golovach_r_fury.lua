modifier_golovach_r_fury = class({})

function modifier_golovach_r_fury:IsHidden()
	return false
end
function modifier_golovach_r_fury:IsDebuff()
	return false
end
function modifier_golovach_r_fury:IsPurgable()
	return false
end

function modifier_golovach_r_fury:OnCreated( kv )
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "flurry_bonus_attack_speed" )
	self.recovery = self:GetAbility():GetSpecialValueFor( "time_between_flurries" )
	self.charges = self:GetAbility():GetSpecialValueFor( "charges_per_flurry" )
	self.timer = self:GetAbility():GetSpecialValueFor( "max_time_window_per_hit" )
	self.radius = self:GetAbility():GetSpecialValueFor( "pulse_radius" )
	self.damage = self:GetAbility():GetSpecialValueFor( "pulse_damage" )
	self.duration = self:GetAbility():GetSpecialValueFor( "pulse_debuff_duration" )
	if not IsServer() then return end
	self.counter = self.charges
	self:SetStackCount( self.counter )
	self.success = 0
	self.animation = self.parent:AddNewModifier(
		self.parent,
		self.ability,
		"modifier_golovach_r_animation",
		{}
	)
	self:PlayEffects1()
	self:PlayEffects2( self.parent, self.counter )
end

function modifier_golovach_r_fury:OnRefresh( kv )
end

function modifier_golovach_r_fury:OnRemoved()
end

function modifier_golovach_r_fury:OnDestroy()
	if not IsServer() then return end
	if not self.animation:IsNull() then
		self.animation:Destroy()
	end
	local main = self.parent:FindModifierByNameAndCaster( "modifier_golovach_r", self.parent )
	if not main then return end
	if self.forced then return end
	self.parent:AddNewModifier(
		self.parent,
		self.ability,
		"modifier_golovach_r_recovery",
		{
			duration = self.recovery,
			success = self.success,
		}
	)
	if self.success~=1 then return end
end

function modifier_golovach_r_fury:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_IGNORE_ATTACKSPEED_LIMIT,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}
	return funcs
end

function modifier_golovach_r_fury:GetModifierAttackSpeed_Limit()
	return 1
end

function modifier_golovach_r_fury:GetModifierProcAttack_Feedback( params )
	self:StartIntervalThink( self.timer )
	self.counter = self.counter - 1
	self:SetStackCount( self.counter )
	self:EditEffects2( self.counter )
	self:PlayEffects3( self.parent, params.target )
	if self.counter<=0 then
		self.success = 1
		self:Pulse( params.target:GetOrigin() )
		self:Destroy()
	end
end

function modifier_golovach_r_fury:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as
end

function modifier_golovach_r_fury:GetActivityTranslationModifiers()
	if self:GetStackCount()==1 then
		return "flurry_pulse_attack"
	end

	if self:GetStackCount()%2==0 then
		return "flurry_attack_b"
	end

	return "flurry_attack_a"
end

function modifier_golovach_r_fury:OnIntervalThink()
	self:Destroy()
end

function modifier_golovach_r_fury:Pulse( center )
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),
		center,
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		0,
		false
	)
	local damageTable = {
		attacker = self.parent,
		damage = self.damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability,
	}

	for _,enemy in pairs(enemies) do
		damageTable.victim = enemy
		ApplyDamage(damageTable)
		local direction = enemy:GetOrigin()-self:GetParent():GetOrigin()
		direction.z = 0
		direction = direction:Normalized()
		enemy:AddNewModifier(
			self.parent,
			self.ability,
			"modifier_golovach_r_debuff",
			{ duration = self.duration }
		)
		enemy:AddNewModifier(
				self.parent,
				self.ability,
				"modifier_generic_arc_lua",
				{
					dir_x = direction.x,
					dir_y = direction.y,
					duration = 0.3,
					distance = 0,
					height = 100,
					activity = ACT_DOTA_FLAIL,
				}
			)
	end
	self:PlayEffects4( center, self.radius )
end

function modifier_golovach_r_fury:ForceDestroy()
	self.forced = true
	self:Destroy()
end

function modifier_golovach_r_fury:ShouldUseOverheadOffset()
	return true
end

function modifier_golovach_r_fury:PlayEffects1()
	local particle_cast = "particles/units/heroes/hero_marci/marci_unleash_buff.vpcf"
	local sound_cast = "Hero_Marci.Unleash.Charged"
	local sound_cast2 = "Hero_Marci.Unleash.Charged.2D"
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
	EmitSoundOn( sound_cast, self:GetParent() )
	EmitSoundOnClient( sound_cast2, self:GetParent():GetPlayerOwner() )
end

function modifier_golovach_r_fury:PlayEffects2( caster, counter )
	local particle_cast = "particles/marci_unleash_stack_golovach.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_OVERHEAD_FOLLOW, caster )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( 0, counter, 0 ) )
	self:AddParticle(
		effect_cast,
		false,
		false,
		1,
		false,
		true
	)
	self.effect_cast = effect_cast
end

function modifier_golovach_r_fury:EditEffects2( counter )
	ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( 0, counter, 0 ) )
end

function modifier_golovach_r_fury:PlayEffects3( caster, target )
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

function modifier_golovach_r_fury:PlayEffects4( point, radius )
	local particle_cast = "particles/units/heroes/hero_marci/marci_unleash_pulse.vpcf"
	local sound_cast = "golovach_r_hit"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector(radius,radius,radius) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOnLocationWithCaster( point, sound_cast, self:GetParent() )
end
