serega_opa = class({})
LinkLuaModifier( "modifier_serega_opa", "heroes/pirat/serega_opa", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_silenced_lua", "modifier_generic_silenced_lua", LUA_MODIFIER_MOTION_NONE )

function serega_opa:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_serega_opa", { duration = self:GetSpecialValueFor("duration") } )
	EmitSoundOn( "serega_opa", caster )
end

modifier_serega_opa = class({})

function modifier_serega_opa:IsHidden()
	return false
end
function modifier_serega_opa:IsPurgable()
	return false
end

function modifier_serega_opa:OnCreated()
	self.bonus = self:GetAbility():GetSpecialValueFor("bonus_resist_pct")
	self.armor = self:GetAbility():GetSpecialValueFor("armor")
	self.duration = self:GetAbility():GetSpecialValueFor("silence_duration")
	self.hex_duration = self:GetAbility():GetSpecialValueFor("hex_duration")
end

function modifier_serega_opa:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ABSORB_SPELL,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
	return funcs
end

function modifier_serega_opa:GetModifierMagicalResistanceBonus()
	return self.bonus
end
function modifier_serega_opa:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_serega_opa:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("damage_absorb")
end

function modifier_serega_opa:GetAbsorbSpell( params )
	if IsServer() then
		if (not self:GetParent():IsIllusion()) and params.ability:GetCaster() ~= self:GetParent() and params.ability:GetAbilityName() ~= "rubick_spell_steal" then
			params.ability:GetCaster():AddNewModifier( self:GetParent(), self, "modifier_generic_silenced_lua", { duration = self.duration } )
			self:PlayEffects(true)
			return 1
		end
	end
end

function modifier_serega_opa:GetEffectName()
	return "particles/serega_opa.vpcf"
end
function modifier_serega_opa:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_serega_opa:PlayEffects( bBlock )
	local particle_cast = "particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf"
	EmitSoundOn("serega_absorb", self:GetParent())
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end