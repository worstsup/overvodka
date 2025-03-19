LinkLuaModifier( "modifier_golmiy_blev", "heroes/golmiy/golmiy_blev", LUA_MODIFIER_MOTION_NONE )

golmiy_blev = class({})


function golmiy_blev:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end


function golmiy_blev:OnSpellStart()

	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local duration = self:GetSpecialValueFor( "duration" )

	CreateModifierThinker(
		caster, -- player source
		self, -- ability source
		"modifier_golmiy_blev", -- modifier name
		{ duration = duration }, -- kv
		point,
		caster:GetTeamNumber(),
		false
	)
end


modifier_golmiy_blev = class({})


function modifier_golmiy_blev:IsHidden()
	return false
end

function modifier_golmiy_blev:IsDebuff()
	return true
end

function modifier_golmiy_blev:IsStunDebuff()
	return false
end

function modifier_golmiy_blev:IsPurgable()
	return false
end


function modifier_golmiy_blev:OnCreated( kv )

	local interval = self:GetAbility():GetSpecialValueFor( "tick_rate" )
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.magic = self:GetAbility():GetSpecialValueFor( "magic_reduction" )
	self.movespeed = self:GetAbility():GetSpecialValueFor( "slow" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )

	self.thinker = kv.isProvidedByAura~=1

	if not IsServer() then return end
	if not self.thinker then return end

	self.damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(), --Optional.
	}

	self:StartIntervalThink( interval )

	self:PlayEffects()
end

function modifier_golmiy_blev:OnRefresh( kv )
	
end

function modifier_golmiy_blev:OnRemoved()
end

function modifier_golmiy_blev:OnDestroy()
	if not IsServer() then return end
	if not self.thinker then return end

	UTIL_Remove( self:GetParent() )
end


function modifier_golmiy_blev:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}

	return funcs
end

function modifier_golmiy_blev:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_golmiy_blev:GetModifierMagicalResistanceBonus()
	return self.magic
end


function modifier_golmiy_blev:OnIntervalThink()

	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do

		self.damageTable.victim = enemy
		ApplyDamage( self.damageTable )

	end
end


function modifier_golmiy_blev:IsAura()
	return self.thinker
end

function modifier_golmiy_blev:GetModifierAura()
	return "modifier_golmiy_blev"
end

function modifier_golmiy_blev:GetAuraRadius()
	return self.radius
end

function modifier_golmiy_blev:GetAuraDuration()
	return 0.5
end

function modifier_golmiy_blev:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_golmiy_blev:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_golmiy_blev:GetAuraSearchFlags()
	return 0
end

function modifier_golmiy_blev:GetEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_acid_spray_debuff.vpcf"
end

function modifier_golmiy_blev:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_golmiy_blev:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf"
	local sound_cast = "blue"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 1, 1 ) )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetParent() )
end