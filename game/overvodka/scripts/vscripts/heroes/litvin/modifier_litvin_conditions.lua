modifier_litvin_conditions = class({})

function modifier_litvin_conditions:IsHidden()
	return true
end
function modifier_litvin_conditions:IsDebuff()
	return self:GetCaster():GetTeamNumber()~=self:GetParent():GetTeamNumber()
end
function modifier_litvin_conditions:IsStunDebuff()
	return true
end
function modifier_litvin_conditions:IsPurgable()
	return true
end

function modifier_litvin_conditions:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()

	self.damage = self:GetAbility():GetSpecialValueFor( "toss_damage" )
	self.mnozh = self:GetAbility():GetSpecialValueFor( "mnozh" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.stun_duration = self:GetAbility():GetSpecialValueFor( "stun_duration" )

	if not IsServer() then return end
	local duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.target = EntIndexToHScript( kv.target )
	local height = 400
	self.parent:AddNewModifier(
		self.caster,
		self:GetAbility(),
		"modifier_generic_stunned_lua",
		{ duration = duration + 0.1 }
	)
	self.arc = self.parent:AddNewModifier(
		self.caster,
		self:GetAbility(),
		"modifier_generic_arc_lua",
		{
			duration = duration,
			distance = 0,
			height = height,
			fix_duration = false,
			isStun = true,
			activity = ACT_DOTA_FLAIL,
		}
	)
	self.arc:SetEndCallback(function( interrupted )
		self:Destroy()
		if interrupted then return end
		local enemies = FindUnitsInRadius(
			self.caster:GetTeamNumber(),
			self.parent:GetOrigin(),
			nil,
			self.radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			0,
			false
		)
		local damageTable = {
			attacker = self.caster,
			damage = self.damage,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(),
		}
		for _,enemy in pairs(enemies) do
			damageTable.victim = enemy
			if enemy==self.parent then
				damageTable.damage = self.mnozh*self.damage
			else
				damageTable.damage = self.damage
			end
			enemy:AddNewModifier(
			self:GetCaster(),
			self:GetAbility(), 
			"modifier_generic_stunned_lua", 
			{duration = self.stun_duration}
		)
			ApplyDamage(damageTable)
		end
		GridNav:DestroyTreesAroundPoint( self.parent:GetOrigin(), self.radius, false )
		local sound_cast = "Ability.TossImpact"
		EmitSoundOn( sound_cast, self.parent )
	end)
	local origin = self.target:GetOrigin()
	local direction = origin-self.parent:GetOrigin()
	local distance = direction:Length2D()
	direction.z = 0
	direction = direction:Normalized()
	self.distance = distance
	if self.distance==0 then self.distance = 1 end
	self.duration = duration
	self.speed = distance/duration
	self.accel = 100
	self.max_speed = 3000
	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
	end
	local sound_cast = "cond"
	EmitSoundOn( sound_cast, self.caster )
end

function modifier_litvin_conditions:OnRefresh( kv )
end

function modifier_litvin_conditions:OnRemoved()
end

function modifier_litvin_conditions:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController( self )
end

function modifier_litvin_conditions:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function modifier_litvin_conditions:UpdateHorizontalMotion( me, dt )
	local target = self.target:GetOrigin()
	local parent = self.parent:GetOrigin()
	local duration = self:GetElapsedTime()
	local direction = target-parent
	local distance = direction:Length2D()
	direction.z = 0
	direction = direction:Normalized()
	local original_distance = duration/self.duration * self.distance
	local expected_speed
	if self:GetElapsedTime()>=self.duration then
		expected_speed = self.speed
	else
		expected_speed = distance/(self.duration-self:GetElapsedTime())
	end
	if self.speed<expected_speed then
		self.speed = math.min(self.speed + self.accel, self.max_speed)
	elseif self.speed>expected_speed then
		self.speed = math.max(self.speed - self.accel, 0)
	end
	local pos = parent + direction * self.speed * dt
	me:SetOrigin( pos )
end

function modifier_litvin_conditions:OnHorizontalMotionInterrupted()
	self:Destroy()
end

function modifier_litvin_conditions:GetEffectName()
	return "particles/units/heroes/hero_tiny/tiny_toss_blur.vpcf"
end

function modifier_litvin_conditions:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end