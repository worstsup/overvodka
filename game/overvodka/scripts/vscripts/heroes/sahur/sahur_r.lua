sahur_r = class({})
LinkLuaModifier( "modifier_sahur_r", "heroes/sahur/sahur_r", LUA_MODIFIER_MOTION_NONE )

function sahur_r:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end
function sahur_r:OnAbilityUpgrade( hAbility )
    if not IsServer() then return end
    local result = self.BaseClass.OnAbilityUpgrade( self, hAbility )
    
    local ability = self:GetCaster():FindAbilityByName("sahur_innate")
    if ability then
        ability:SetLevel(ability:GetLevel() + 1)
    end
    return result
end
function sahur_r:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	CreateModifierThinker(
		caster,
		self,
		"modifier_sahur_r",
		{},
		point,
		caster:GetTeamNumber(),
		false
	)
	local sound_cast_2 = "komp"
	EmitSoundOn( sound_cast_2, caster )
	EmitSoundOnLocationWithCaster(point, "sahur_r", caster)
end

modifier_sahur_r = class({})

function modifier_sahur_r:IsHidden()
	return false
end

function modifier_sahur_r:IsDebuff()
	return true
end

function modifier_sahur_r:IsStunDebuff()
	return false
end

function modifier_sahur_r:IsPurgable()
	return true
end

function modifier_sahur_r:OnCreated( kv )
	if not IsServer() then return end
	self.owner = kv.isProvidedByAura~=1
	if not self.owner then return end
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.pulses = self:GetAbility():GetSpecialValueFor( "pulses" )
	local duration = self:GetAbility():GetSpecialValueFor( "duration" )
	local damage = self:GetAbility():GetSpecialValueFor( "damage_max" )
	local interval = duration/self.pulses
	local max_tick_damage = damage*interval
	self.tick_damage = max_tick_damage/self.pulses
	self.pulse = 0
	self.damageTable = {
		attacker = self:GetCaster(),
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(),
	}
	self:StartIntervalThink( interval )
	self:PlayEffects1( duration )
end

function modifier_sahur_r:OnRefresh( kv )
end

function modifier_sahur_r:OnRemoved()
end

function modifier_sahur_r:OnDestroy()
	if not IsServer() then return end
	if self.owner then

		UTIL_Remove( self:GetParent() )
	end
end

function modifier_sahur_r:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_sahur_r:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("move_speed_tooltip")
end

function modifier_sahur_r:GetBonusDayVision()
	return -2000
end

function modifier_sahur_r:GetBonusNightVision()
	return -1000
end
function modifier_sahur_r:CheckState()
	local state = {
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
	}
	return state
end

function modifier_sahur_r:OnIntervalThink()
	self.pulse = self.pulse + 1
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),
		self:GetParent():GetOrigin(),
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		0,
		false
	)
	self.damageTable.damage = self.tick_damage * self.pulse

	for _,enemy in pairs(enemies) do
		self.damageTable.victim = enemy
		ApplyDamage( self.damageTable )
		if enemy and not enemy:IsNull() then
			if enemy:IsRealHero() and not enemy:IsDebuffImmune() then
				self:PlayEffects2(enemy)
			end
		end
	end
	if self.pulse >= self.pulses then
		self:Destroy()
	end
end

function modifier_sahur_r:IsAura()
	return self.owner
end

function modifier_sahur_r:GetModifierAura()
	return "modifier_sahur_r"
end

function modifier_sahur_r:GetAuraRadius()
	return self.radius
end

function modifier_sahur_r:GetAuraDuration()
	return 0.3
end

function modifier_sahur_r:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_sahur_r:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_sahur_r:PlayEffects1( duration )
	local particle_cast = "particles/disruptor_2022_immortal_static_storm_custom.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, self.radius, self.radius ) )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( duration, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_sahur_r:PlayEffects2( target )
	local particle_cast = "particles/kirill_r_black.vpcf"
	local effect_cast = ParticleManager:CreateParticleForPlayer(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target, target:GetPlayerOwner())
	ParticleManager:ReleaseParticleIndex( effect_cast )
end