modifier_serega_opa = class({})

function modifier_serega_opa:IsHidden()
	return true
end
function modifier_serega_opa:OnCreated( kv )
	self.bonus = self:GetAbility():GetSpecialValueFor("bonus_resist_pct")
	self.armor = self:GetAbility():GetSpecialValueFor("armor")
	self.duration = self:GetAbility():GetSpecialValueFor("silence_duration")
end

function modifier_serega_opa:OnRefresh( kv )
	self.bonus = self:GetAbility():GetSpecialValueFor("bonus_resist_pct")
	self.armor = self:GetAbility():GetSpecialValueFor("armor")
	self.duration = self:GetAbility():GetSpecialValueFor("silence_duration")
end

--------------------------------------------------------------------------------

function modifier_serega_opa:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_REFLECT_SPELL,
		MODIFIER_PROPERTY_ABSORB_SPELL,
	}

	return funcs
end

function modifier_serega_opa:GetModifierMagicalResistanceBonus( params )
	if not self:GetParent():PassivesDisabled() then
		return self.bonus
	end
end
function modifier_serega_opa:GetModifierPhysicalArmorBonus( params )
	if not self:GetParent():PassivesDisabled() then
		return self.armor
	end
end
function modifier_serega_opa:GetAbsorbSpell( params )
	if IsServer() then
		if (not self:GetParent():IsIllusion()) and (not self:GetParent():PassivesDisabled()) and self:GetAbility():IsFullyCastable() and params.ability:GetCaster() ~= self:GetParent() and params.ability:GetAbilityName() ~= "rubick_spell_steal" then
			-- use resources
			self:GetAbility():UseResources( true, true, false, true )
			params.ability:GetCaster():AddNewModifier( self:GetParent(), self, "modifier_generic_silenced_lua", { duration = self.duration } )
			if self:GetParent():HasScepter() then
				params.ability:GetCaster():AddNewModifier( self:GetParent(), self, "modifier_shadow_shaman_voodoo", { duration = self.duration } )
			end
			self:PlayEffects( true )
			return 1
		end
	end
end
--------------------------------------------------------------------------------
function modifier_serega_opa:PlayEffects( bBlock )
	-- Get Resources
	local particle_cast = ""
	local sound_cast = ""
	particle_cast = "particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf"
	sound_cast = "serega_opa"

	-- Play particles
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		self:GetParent():GetOrigin(), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Play sounds
	EmitSoundOn( sound_cast, self:GetParent() )
end

modifier_serega_opa.reflect_exceptions = {
	["rubick_spell_steal"] = true
}