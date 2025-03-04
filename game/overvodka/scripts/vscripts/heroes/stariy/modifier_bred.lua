modifier_bred = class({})

function modifier_bred:IsPurgable()
	return true
end

function modifier_bred:OnCreated( kv )
	self.resist = self:GetAbility():GetSpecialValueFor( "resist" )
	self.as_slow = self:GetAbility():GetSpecialValueFor("as_slow")
	self.ms = self:GetAbility():GetSpecialValueFor( "bonus_ms" )
	self.regen = self:GetAbility():GetSpecialValueFor( "regen" )
	self.spell_amp = self:GetAbility():GetSpecialValueFor( "spell_amp" )
	self:PlayEffectsNew( self:GetParent() )
end

function modifier_bred:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
	}
	return funcs
end
function modifier_bred:GetEffectName()
	return "particles/items2_fx/vindicators_axe_armor.vpcf"
end
function modifier_bred:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_bred:GetModifierHealthRegenPercentage()
	return self.regen
end
function modifier_bred:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end
function modifier_bred:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end
function modifier_bred:GetModifierIncomingDamage_Percentage()
	return self.resist
end
function modifier_bred:GetModifierAttackSpeedPercentage()
	return -30
end

function modifier_bred:PlayEffectsNew( target )
	local particle_cast = "particles/events/muerta_ofrenda/muerta_death_reckoning_flames_green.vpcf"
	local effect_cast_new = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast_new )
end