modifier_cheater_smoke = class({})

--------------------------------------------------------------------------------
function modifier_cheater_smoke:IsHidden()
	return false
end

function modifier_cheater_smoke:IsDebuff()
	return true
end

function modifier_cheater_smoke:IsStunDebuff()
	return false
end

function modifier_cheater_smoke:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_cheater_smoke:OnCreated( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.misses = self:GetAbility():GetSpecialValueFor( "misses" )
	self.owner = kv.isProvidedByAura~=1

	if not IsServer() then return end

	if self.owner then
		self:PlayEffects()
	end

end

function modifier_cheater_smoke:OnRefresh( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.misses = self:GetAbility():GetSpecialValueFor( "misses" )
end

function modifier_cheater_smoke:OnRemoved()
end

function modifier_cheater_smoke:OnDestroy()
	if not IsServer() then return end
	if not self.owner then return end
	UTIL_Remove( self:GetParent() )
end

--------------------------------------------------------------------------------
function modifier_cheater_smoke:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MISS_PERCENTAGE,
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
	}

	return funcs
end
function modifier_cheater_smoke:GetModifierMiss_Percentage()
	return self.misses
end
function modifier_cheater_smoke:GetBonusDayVision()
	return -1600
end
function modifier_cheater_smoke:GetBonusNightVision()
	return -600
end

--------------------------------------------------------------------------------
function modifier_cheater_smoke:IsAura()
	return self.owner
end

function modifier_cheater_smoke:GetModifierAura()
	return "modifier_cheater_smoke"
end

function modifier_cheater_smoke:GetAuraRadius()
	return self.radius
end

function modifier_cheater_smoke:GetAuraDuration()
	return 0.5
end

function modifier_cheater_smoke:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_cheater_smoke:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_cheater_smoke:PlayEffects()
	local particle_cast = "particles/riki_smokebomb_ti8_new.vpcf"
	local sound_cast = "smoke_explosion"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, self.radius, self.radius ) )
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
	EmitSoundOn( sound_cast, self:GetParent() )
end