modifier_arsen_baza = class({})

function modifier_arsen_baza:IsHidden() return false end
function modifier_arsen_baza:IsDebuff() return true end
function modifier_arsen_baza:IsStunDebuff() return false end
function modifier_arsen_baza:IsPurgable() return true end

function modifier_arsen_baza:OnCreated( kv )
	if not IsServer() then return end
	self.damage = self:GetAbility():GetSpecialValueFor( "burn_damage" )
	self.damage_pct = self:GetAbility():GetSpecialValueFor( "burn_damage_pct" )
	local interval = 1
	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self,
	}
	self:StartIntervalThink( interval )
	self:PlayEffects()
end

function modifier_arsen_baza:OnRefresh( kv )
	if not IsServer() then return end
	self.damage = self:GetAbility():GetSpecialValueFor( "burn_damage" )
	self.damage_pct = self:GetAbility():GetSpecialValueFor( "burn_damage_pct" )
	local interval = 1
	self:StartIntervalThink( interval )
	self:PlayEffects()
end

function modifier_arsen_baza:OnRemoved()
end

function modifier_arsen_baza:OnDestroy()
end

function modifier_arsen_baza:OnIntervalThink()
	self.damageTable.damage = self.damage + (self.damage_pct/100)*self:GetParent():GetMaxHealth()
	ApplyDamage( self.damageTable )
end

function modifier_arsen_baza:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_infernal_blade_debuff.vpcf"
end

function modifier_arsen_baza:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_arsen_baza:PlayEffects()
	local particle_cast = "particles/econ/items/vengeful/vengeful_arcana/vengeful_arcana_nether_swap_v3_explosion.vpcf"
	local sound_cast = "baza"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( sound_cast, self:GetParent() )
end