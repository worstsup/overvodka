-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
modifier_cheater_smoke = class({})

--------------------------------------------------------------------------------
-- Classifications
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
-- Modifier Effects
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
-- Aura Effects
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
	-- Get Resources
	local particle_cast = "particles/riki_smokebomb_ti8_new.vpcf"
	local sound_cast = "smoke_explosion"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, self.radius, self.radius ) )
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