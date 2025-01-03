modifier_arsen_baza = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_arsen_baza:IsHidden()
	return false
end

function modifier_arsen_baza:IsDebuff()
	return true
end

function modifier_arsen_baza:IsStunDebuff()
	return false
end

function modifier_arsen_baza:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_arsen_baza:OnCreated( kv )
	if not IsServer() then return end

	-- references
	self.damage = self:GetAbility():GetSpecialValueFor( "burn_damage" )
	self.damage_pct = self:GetAbility():GetSpecialValueFor( "burn_damage_pct" )
	local interval = 1
	-- precache damage
	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		-- damage = damage,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self, --Optional.
	}

	-- Start interval
	self:StartIntervalThink( interval )

	-- Play effects
	self:PlayEffects()
end

function modifier_arsen_baza:OnRefresh( kv )
	if not IsServer() then return end
	-- references
	self.damage = self:GetAbility():GetSpecialValueFor( "burn_damage" )
	self.damage_pct = self:GetAbility():GetSpecialValueFor( "burn_damage_pct" )
	local interval = 1

	-- Start interval
	self:StartIntervalThink( interval )

	-- Play effects
	self:PlayEffects()
end

function modifier_arsen_baza:OnRemoved()
end

function modifier_arsen_baza:OnDestroy()
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_arsen_baza:OnIntervalThink()
	-- update damage
	self.damageTable.damage = self.damage + (self.damage_pct/100)*self:GetParent():GetMaxHealth()

	-- apply damage
	ApplyDamage( self.damageTable )
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_arsen_baza:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_infernal_blade_debuff.vpcf"
end

function modifier_arsen_baza:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_arsen_baza:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/econ/items/vengeful/vengeful_arcana/vengeful_arcana_nether_swap_v3_explosion.vpcf"
	local sound_cast = "baza"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetParent() )
end