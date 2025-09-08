zolo_zver = class({})
LinkLuaModifier( "modifier_zolo_zver", "heroes/zolo/zolo_zver", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zolo_disarm", "heroes/zolo/zolo_zver", LUA_MODIFIER_MOTION_NONE )

function zolo_zver:Precache(context)
	PrecacheResource("particle", "particles/huskar_inner_fire_new.vpcf", context)
	PrecacheResource("particle", "particles/mars_shield_bash_crit_new.vpcf", context)
	PrecacheResource("particle", "particles/primal_beast_2022_prestige_onslaught_chargeup_new.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_invoker/invoker_deafening_blast_disarm_debuff.vpcf", context)
	PrecacheResource("soundfile", "soundevents/zolo_zver.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/zolo_zver_start.vsndevts", context)
end

function zolo_zver:OnAbilityPhaseStart()
	self:PlayEffects3()
end

function zolo_zver:OnAbilityPhaseInterrupted()
	self:StopEffects3()
end

function zolo_zver:OnSpellStart()
	local caster = self:GetCaster()
	local point = caster:GetOrigin()
	local radius = self:GetSpecialValueFor("radius")
	local disarm_duration = self:GetSpecialValueFor( "disarm_duration" )
	local angle = self:GetSpecialValueFor("angle")/2
	local duration = self:GetSpecialValueFor("knockback_duration")
	local distance = self:GetSpecialValueFor("knockback_distance")
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetOrigin(),
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		0,
		false
	)
	local buff = caster:AddNewModifier(caster, self, "modifier_zolo_zver", {})
	local origin = caster:GetOrigin()
	local cast_direction = (point-origin+Vector(50,50,0)):Normalized()
	local cast_angle = VectorToAngles( cast_direction ).y
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(
			caster, 
			self, 
			"modifier_zolo_disarm", 
			{duration = disarm_duration}
		)
		local enemy_direction = (enemy:GetOrigin() - origin):Normalized()
		local enemy_angle = VectorToAngles( enemy_direction ).y
		local angle_diff = math.abs( AngleDiff( cast_angle, enemy_angle ) )
		if angle_diff<=angle then
			self:PlayEffects2( enemy, origin, cast_direction )
			caster:PerformAttack(
				enemy,
				true,
				true,
				true,
				true,
				true,
				false,
				true
			)
			if enemy and not enemy:IsNull() then
				enemy:AddNewModifier(
					caster, 
					self,
					"modifier_knockback",
					{
						center_x = caster:GetAbsOrigin().x,
						center_y = caster:GetAbsOrigin().y,
						center_z = caster:GetAbsOrigin().z,
						duration = duration,
						knockback_duration = duration,
						knockback_distance = distance,
						knockback_height = 30
					}
				)
			end
		end
	end

	buff:Destroy()

	self:PlayEffects1( (point-origin):Normalized() )
end

function zolo_zver:PlayEffects1( direction )
	local particle_cast = "particles/huskar_inner_fire_new.vpcf"
	local sound_cast = "zolo_zver"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 0, direction )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), sound_cast, self:GetCaster() )
end

function zolo_zver:PlayEffects2( target, origin, direction )
	local particle_cast = "particles/mars_shield_bash_crit_new.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, target )
	ParticleManager:SetParticleControl( effect_cast, 0, target:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 1, direction )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function zolo_zver:PlayEffects3()
	self.effect_cast = ParticleManager:CreateParticle( "particles/primal_beast_2022_prestige_onslaught_chargeup_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	EmitSoundOn( "zolo_zver_start", self:GetCaster() )
end

function zolo_zver:StopEffects3()
	if self.effect_cast then
		ParticleManager:DestroyParticle(self.effect_cast, false)
		ParticleManager:ReleaseParticleIndex(self.effect_cast)
		self.effect_cast = nil
	end
	StopSoundOn( "zolo_zver_start", self:GetCaster() )
end


modifier_zolo_zver = class({})

function modifier_zolo_zver:IsHidden() return true end
function modifier_zolo_zver:IsDebuff() return false end
function modifier_zolo_zver:IsPurgable() return false end

function modifier_zolo_zver:OnCreated( kv )
	self.bonus_damage = self:GetAbility():GetSpecialValueFor( "bonus_damage_vs_heroes" )
	self.bonus_crit = self:GetAbility():GetSpecialValueFor( "crit_mult" )
end

function modifier_zolo_zver:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE_POST_CRIT,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	}
end

function modifier_zolo_zver:GetModifierPreAttack_BonusDamagePostCrit( params )
	if not IsServer() then return end
	return self.bonus_damage
end

function modifier_zolo_zver:GetModifierPreAttack_CriticalStrike( params )
	return self.bonus_crit
end


modifier_zolo_disarm = class({})

function modifier_zolo_disarm:IsHidden() return false end
function modifier_zolo_disarm:IsDebuff() return true end
function modifier_zolo_disarm:IsPurgable() return true end

function modifier_zolo_disarm:OnCreated( kv )
	self.slow = self:GetAbility():GetSpecialValueFor( "slow" )
end

function modifier_zolo_disarm:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = true,
	}
end

function modifier_zolo_disarm:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_zolo_disarm:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_zolo_disarm:GetEffectName()
	return "particles/units/heroes/hero_invoker/invoker_deafening_blast_disarm_debuff.vpcf"
end

function modifier_zolo_disarm:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end