modifier_mellstroy_shavel_debuff = class({})

function modifier_mellstroy_shavel_debuff:IsHidden()
	return false
end
function modifier_mellstroy_shavel_debuff:IsDebuff()
	return true
end
function modifier_mellstroy_shavel_debuff:IsPurgable()
	return true
end
function modifier_mellstroy_shavel_debuff:IsStunDebuff()
	return true
end

function modifier_mellstroy_shavel_debuff:OnCreated( kv )
	self.parent = self:GetParent()
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.isRoshan = self.parent:GetUnitName()=="npc_dota_roshan"
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "splash_radius" )
	self.ministun = self:GetAbility():GetSpecialValueFor( "ministun" )
	self.damage = self:GetAbility():GetSpecialValueFor( "ministun" )
	self.animrate = self:GetAbility():GetSpecialValueFor( "animation_rate" )
	if not IsServer() then return end
	self.damage = self:GetAbility():GetAbilityDamage()
	self.abilityDamageType = self:GetAbility():GetAbilityDamageType()
	self.abilityTargetTeam = self:GetAbility():GetAbilityTargetTeam()
	self.abilityTargetType = self:GetAbility():GetAbilityTargetType()
	self.abilityTargetFlags = self:GetAbility():GetAbilityTargetFlags()
	self.interrupt_pos = self.caster:GetOrigin() + self.caster:GetForwardVector() * 200
	self.cast_pos = self.caster:GetOrigin()
	self.pos_threshold = 100
	local attach_rollback = {
		[1] = "attach_pummel",
		[2] = "attach_attack1",
		[3] = "attach_attack",
		[4] = "attach_hitloc",
	}
	for i,name in ipairs(attach_rollback) do
		self.attach_name = name
		if self.caster:ScriptLookupAttachment( name )~=0 then
			break
		end
	end
	local hitloc_enum = self.parent:ScriptLookupAttachment( "attach_hitloc" )
	local hitloc_pos = self.parent:GetAttachmentOrigin( hitloc_enum )
	self.deltapos = self.parent:GetOrigin() - hitloc_pos
	if not self:ApplyHorizontalMotionController() then
		if not self.isRoshan then
			self:Destroy()
			return
		end
	end
	if not self:ApplyVerticalMotionController() then
		if not self.isRoshan then
			self:Destroy()
			return
		end
	end

	self:SetPriority( DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST )
	self:StartIntervalThink( self.interval )
end

function modifier_mellstroy_shavel_debuff:OnRefresh( kv )
	
end

function modifier_mellstroy_shavel_debuff:OnRemoved()
	if not IsServer() then return end
end

function modifier_mellstroy_shavel_debuff:OnDestroy()
	if not IsServer() then return end
	self.parent:RemoveHorizontalMotionController( self )

	if not (self.parent:IsCurrentlyHorizontalMotionControlled() or self.parent:IsCurrentlyVerticalMotionControlled()) then
		FindClearSpaceForUnit( self.parent, self.interrupt_pos, false )
		local angle = self.parent:GetAnglesAsVector()
		self.parent:SetAngles( 0, angle.y+180, 0 )
	end

	self.ability:RemoveModifier( self )
end

function modifier_mellstroy_shavel_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
	}

	return funcs
end

function modifier_mellstroy_shavel_debuff:GetOverrideAnimation()
	if self.isRoshan then
		return ACT_DOTA_DISABLED
	end
	return ACT_DOTA_FLAIL
end

function modifier_mellstroy_shavel_debuff:GetOverrideAnimationRate()
	return self.animrate
end

function modifier_mellstroy_shavel_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true,
	}

	return state
end

function modifier_mellstroy_shavel_debuff:OnIntervalThink()
	local origin = self.parent:GetOrigin()
	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(),
		origin,
		nil,
		self.radius,
		self.abilityTargetTeam,
		self.abilityTargetType,
		self.abilityTargetFlags,
		0,
		false
	)
	local damageTable = {
		attacker = self.caster,
		damage = self.damage,
		damage_type = self.abilityDamageType,
		ability = self.ability,
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
	}

	for _,enemy in pairs(enemies) do
		damageTable.victim = enemy
		enemy:AddNewModifier(
			self.caster,
			self,
			"modifier_generic_stunned_lua",
			{ duration = self.ministun }
		)
		ApplyDamage(damageTable)
		EmitSoundOn( "Hero_PrimalBeast.Pulverize.Stun", self.caster )
	end
	self:PlayEffects( origin, self.radius )
	if (self.caster:GetOrigin()-self.cast_pos):Length2D()>self.pos_threshold then
		self:Destroy()
		return		
	end
end

function modifier_mellstroy_shavel_debuff:UpdateHorizontalMotion( me, dt )
end
function modifier_mellstroy_shavel_debuff:OnHorizontalMotionInterrupted()
	self:Destroy()
end
function modifier_mellstroy_shavel_debuff:UpdateVerticalMotion( me, dt )
end
function modifier_mellstroy_shavel_debuff:OnHorizontalMotionInterrupted()
	self:Destroy()
end
function modifier_mellstroy_shavel_debuff:GetPriority()
	return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST
end
function modifier_mellstroy_shavel_debuff:GetMotionPriority()
	return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST
end

function modifier_mellstroy_shavel_debuff:PlayEffects( origin, radius )
	local particle_cast = "particles/units/heroes/hero_primal_beast/primal_beast_pulverize_hit.vpcf"
	local sound_cast = "Hero_PrimalBeast.Pulverize.Impact"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, origin )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector(radius, radius, radius) )
	ParticleManager:DestroyParticle( effect_cast, false )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOnLocationWithCaster( self.parent:GetOrigin(), sound_cast, self.caster )
end