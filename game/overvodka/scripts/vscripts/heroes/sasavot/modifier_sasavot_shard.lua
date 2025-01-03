modifier_sasavot_shard = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_sasavot_shard:IsHidden()
	return false
end

function modifier_sasavot_shard:IsDebuff()
	return true
end

function modifier_sasavot_shard:IsStunDebuff()
	return false
end

function modifier_sasavot_shard:IsPurgable()
	return false
end

function modifier_sasavot_shard:OnCreated( kv )
	self.ms = self:GetAbility():GetSpecialValueFor( "ms" )
	self:PlayEffects()
end

function modifier_sasavot_shard:OnRefresh( kv )
	self.ms = self:GetAbility():GetSpecialValueFor( "ms" )
	local sound_cast = "Hero_DoomBringer.Doom"
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_sasavot_shard:OnRemoved()
end

function modifier_sasavot_shard:OnDestroy()
	if not IsServer() then return end
	-- stop sound
	local sound_cast = "Hero_DoomBringer.Doom"
	StopSoundOn( sound_cast, self:GetParent() )
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_sasavot_shard:CheckState()
	local state = {
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
	}
	return state
end
function modifier_sasavot_shard:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end
function modifier_sasavot_shard:GetModifierMoveSpeedBonus_Percentage()
	return -self.ms
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_sasavot_shard:GetStatusEffectName()
	return "particles/status_fx/status_effect_doom.vpcf"
end

function modifier_sasavot_shard:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_sasavot_shard:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/doom_bringer_doom_sasavot.vpcf"
	local sound_cast = "sasavot_shard"

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