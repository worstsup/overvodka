modifier_chillguy_e = class({})
function modifier_chillguy_e:IsHidden()
	return false
end

function modifier_chillguy_e:IsDebuff()
	return true
end

function modifier_chillguy_e:IsStunDebuff()
	return false
end

function modifier_chillguy_e:IsPurgable()
	return false
end

function modifier_chillguy_e:OnCreated( kv )
	if not IsServer() then return end
	self:PlayEffects() 
end

function modifier_chillguy_e:OnRefresh( kv )
	if not IsServer() then return end
	local sound_cast = "chillguy_photo"
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_chillguy_e:OnRemoved()
end

function modifier_chillguy_e:OnDestroy()
	if not IsServer() then return end
	-- stop sound
	local sound_cast = "chillguy_photo"
	StopSoundOn( sound_cast, self:GetParent() )
end

function modifier_chillguy_e:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_MUTED] = true,
	}

	return state
end

function modifier_chillguy_e:GetStatusEffectName()
	return "particles/status_fx/status_effect_doom.vpcf"
end

function modifier_chillguy_e:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end
function modifier_chillguy_e:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_freezing_field_explosion_white_arcana1.vpcf"
	local sound_cast = "chillguy_photo"

	-- Create Particle
	-- local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	local effect_cast = assert(loadfile("rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	-- ParticleManager:SetParticleControl( effect_cast, iControlPoint, vControlVector )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		MODIFIER_PRIORITY_SUPER_ULTRA, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetParent() )
end