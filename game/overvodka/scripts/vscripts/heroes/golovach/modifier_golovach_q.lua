modifier_golovach_q = class({})

function modifier_golovach_q:IsHidden()
	return true
end

function modifier_golovach_q:IsDebuff()
	return false
end

function modifier_golovach_q:IsPurgable()
	return false
end

function modifier_golovach_q:OnCreated( kv )
	self.reduction_back = self:GetAbility():GetSpecialValueFor( "back_damage_reduction" )
	self.angle_back = self:GetAbility():GetSpecialValueFor( "back_angle" )
	self.max_threshold = self:GetAbility():GetSpecialValueFor( "quill_release_threshold" )
	self.ability_proc = "golovach_hidden"

	self.threshold = 0
end

function modifier_golovach_q:OnRefresh( kv )
	self.reduction_back = self:GetAbility():GetSpecialValueFor( "back_damage_reduction" )
	self.angle_back = self:GetAbility():GetSpecialValueFor( "back_angle" )
	self.max_threshold = self:GetAbility():GetSpecialValueFor( "quill_release_threshold" )
end

function modifier_golovach_q:OnDestroy( kv )

end

function modifier_golovach_q:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end

function modifier_golovach_q:OnAttackLanded( params )
	if IsServer() and (not self:GetParent():PassivesDisabled()) then
		if self:GetAbility():GetCooldownTimeRemaining() ~= 0 then return end
		if params.attacker == self:GetParent() then return end
		if params.target ~= self:GetParent() then return end
		if params.target:IsStunned() then return end
		local parent = self:GetParent()
		local attacker = params.attacker
		local reduction = 0
		if attacker:IsTower() then
			return 0
		end
		local facing_direction = parent:GetAnglesAsVector().y
		local attacker_vector = (attacker:GetOrigin() - parent:GetOrigin()):Normalized()
		local attacker_direction = VectorToAngles( attacker_vector ).y
		local angle_diff = AngleDiff( facing_direction, attacker_direction )
		angle_diff = math.abs(angle_diff)
		-- calculate damage reduction
		if angle_diff > (180-self.angle_back) then
			reduction = self.reduction_back
			self:ThresholdLogic( params.damage, params.attacker )
			self:PlayEffects( true, attacker_vector )
		end
	end
end

function modifier_golovach_q:ThresholdLogic( damage, target )
	local random_chance = RandomInt(1, 2)
	if damage > 0 and random_chance == 1 then
		local ability = self:GetParent():FindAbilityByName( self.ability_proc )
		if self:GetCaster():IsIllusion() then return end
		if not self:GetCaster():IsAlive() then return end
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
			self:GetCaster():GetAbsOrigin(),
			nil,
			350,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			FIND_ANY_ORDER,
			false)
		if #enemies == 0 then return end
		if ability~=nil then
			self:GetAbility():UseResources( false, false, false, true )
			EmitSoundOn( "golovach_q", self:GetCaster() )
			local dmg = self:GetCaster():GetAverageTrueAttackDamage(nil) * 2
			if self:GetAbility():GetSpecialValueFor( "attackdamage" ) == 1 then
				ApplyDamage({ victim = target, attacker = self:GetCaster(), damage = dmg, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self:GetAbility() })
			end
			self:GetParent():CastAbilityOnTarget( target, ability, self:GetParent():GetPlayerID() )
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_golovach_q_buff", {duration = self:GetAbility():GetSpecialValueFor("slow_dur_tooltip")})
		end
	end
end
function modifier_golovach_q:PlayEffects( bBack, direction )
	local particle_cast_back = "particles/units/heroes/hero_bristleback/bristleback_back_dmg.vpcf"
	local particle_cast_side = "particles/units/heroes/hero_bristleback/bristleback_side_dmg.vpcf"
	local sound_cast = "Hero_Bristleback.Bristleback"
	local effect_cast = nil
	if bBack then
		effect_cast = ParticleManager:CreateParticle( particle_cast_back, PATTACH_ABSORIGIN, self:GetParent() )
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			1,
			self:GetParent(),
			PATTACH_POINT_FOLLOW,
			"attach_hitloc",
			self:GetParent():GetOrigin(), -- unknown
			true -- unknown, true
		)
		EmitSoundOn( sound_cast, self:GetParent() )
	else
		effect_cast = ParticleManager:CreateParticle( particle_cast_side, PATTACH_ABSORIGIN, self:GetParent() )
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			1,
			self:GetParent(),
			PATTACH_POINT_FOLLOW,
			"attach_hitloc",
			self:GetParent():GetOrigin(), -- unknown
			true -- unknown, true
		)
		ParticleManager:SetParticleControlForward( effect_cast, 3, -direction )

	end
	ParticleManager:ReleaseParticleIndex( effect_cast )
end