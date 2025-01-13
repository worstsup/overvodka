modifier_chillzone_thinker = class({})

--------------------------------------------------------------------------------
-- Initializations
function modifier_chillzone_thinker:OnCreated( kv )
	-- references
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )

	if IsServer() then
		self:PlayEffects()
	end
end

function modifier_chillzone_thinker:OnRefresh( kv )
	
end

function modifier_chillzone_thinker:OnRemoved()
end

function modifier_chillzone_thinker:OnDestroy()
	if IsServer() then
		UTIL_Remove( self:GetParent() )
	end
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_chillzone_thinker:CheckState()
	local state = {
		[MODIFIER_STATE_FROZEN] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Aura Effects
function modifier_chillzone_thinker:IsAura()
	return true
end

function modifier_chillzone_thinker:GetModifierAura()
	return "modifier_chillzone_effect"
end

function modifier_chillzone_thinker:GetAuraRadius()
	return self.radius
end

function modifier_chillzone_thinker:GetAuraDuration()
	return 0.01
end

function modifier_chillzone_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_chillzone_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

function modifier_chillzone_thinker:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_chillzone_thinker:GetAuraEntityReject( hEntity )
	if IsServer() then
		-- -- reject if owner
		-- if hEntity==self:GetCaster() then return true end

		-- -- reject if owner controlled
		-- if hEntity:GetPlayerOwnerID()==self:GetCaster():GetPlayerOwnerID() then return true end

		-- reject if unit is named faceless void
		if hEntity:GetUnitName()=="npc_dota_faceless_void" then return true end
	end

	return false
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_chillzone_thinker:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/rubick_faceless_void_chronosphere_new.vpcf"
	local sound_cast = "Hero_FacelessVoid.Chronosphere"

	-- Create Particle
	-- local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, self:GetParent() )
	local effect_cast = assert(loadfile("rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_ABSORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, self.radius, self.radius ) )

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
	EmitSoundOn( "chillzone", self:GetParent() )
end