modifier_cheater_granades = class({})

--------------------------------------------------------------------------------
function modifier_cheater_granades:IsHidden()
	return false
end

function modifier_cheater_granades:IsDebuff()
	return true
end

function modifier_cheater_granades:IsStunDebuff()
	return false
end

function modifier_cheater_granades:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
function modifier_cheater_granades:OnCreated( kv )
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.magic_resist = self:GetAbility():GetSpecialValueFor( "magic_resistance" )

	self.owner = kv.isProvidedByAura~=1

	if not IsServer() then return end

	if not self.owner then
		self.damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(), --Optional.
		}
		self:StartIntervalThink( 1 )
	else
		self:PlayEffects()
	end

end

function modifier_cheater_granades:OnRefresh( kv )
	-- references
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.magic_resist = self:GetAbility():GetSpecialValueFor( "magic_resistance" )
end

function modifier_cheater_granades:OnRemoved()
end

function modifier_cheater_granades:OnDestroy()
	if not IsServer() then return end
	if not self.owner then return end
	UTIL_Remove( self:GetParent() )
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_cheater_granades:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}

	return funcs
end

function modifier_cheater_granades:GetModifierMagicalResistanceBonus()
	return self.magic_resist
end
--------------------------------------------------------------------------------
-- Status Effects
function modifier_cheater_granades:CheckState()
	local state = {
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_cheater_granades:OnIntervalThink()
	-- Apply damage
	ApplyDamage( self.damageTable )

	-- Play effects
	local sound_cast = "molotov_burn"
	EmitSoundOn( sound_cast, self:GetParent() )
end

--------------------------------------------------------------------------------
-- Aura Effects
function modifier_cheater_granades:IsAura()
	return self.owner
end

function modifier_cheater_granades:GetModifierAura()
	return "modifier_cheater_granades"
end

function modifier_cheater_granades:GetAuraRadius()
	return self.radius
end

function modifier_cheater_granades:GetAuraDuration()
	return 0.5
end

function modifier_cheater_granades:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_cheater_granades:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_cheater_granades:GetEffectName()
	if not self.owner then
		return "particles/fire_barracks_new.vpcf"
	end
end

function modifier_cheater_granades:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_cheater_granades:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/molotov_fire.vpcf"
	local sound_cast = "molotov_fire"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( self.radius, 1, 1 ) )
	-- ParticleManager:ReleaseParticleIndex( effect_cast )

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