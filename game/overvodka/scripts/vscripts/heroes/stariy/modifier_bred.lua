modifier_bred = class({})
--------------------------------------------------------------------------------
function modifier_bred:IsPurgable()
	return true
end

function modifier_bred:OnCreated( kv )
	self.armor = self:GetAbility():GetSpecialValueFor( "armor" )
	self.resist = self:GetAbility():GetSpecialValueFor( "resist" )
	self.ms = self:GetAbility():GetSpecialValueFor( "bonus_ms" )
	self.regen = self:GetAbility():GetSpecialValueFor( "regen" )
	self.spell_amp = self:GetAbility():GetSpecialValueFor( "spell_amp" )
	self:PlayEffectsNew( self:GetParent() )
	self:PlayEffects( self:GetParent() )
end

--------------------------------------------------------------------------------

function modifier_bred:OnRemoved()
	ParticleManager:DestroyParticle( self.nChannelFX, false )
end


--------------------------------------------------------------------------------

function modifier_bred:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}

	return funcs
end

function modifier_bred:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end
--------------------------------------------------------------------------------

function modifier_bred:GetModifierHealthRegenPercentage( params )
	return self.regen
end
function modifier_bred:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end
function modifier_bred:GetModifierPhysicalArmorBonus( params )
	return self.armor
end
function modifier_bred:GetModifierMoveSpeedBonus_Percentage( params )
	return self.ms
end
function modifier_bred:GetModifierMagicalResistanceBonus( params )
	return self.resist
end
function modifier_bred:GetModifierBonusStats_Agility( params )
	return self.bonus_agility
end
function modifier_bred:PlayEffects( target )
	self.nChannelFX = ParticleManager:CreateParticle( "particles/items2_fx/vindicators_axe_armor.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
end

function modifier_bred:PlayEffectsNew( target )
	local particle_cast = "particles/events/muerta_ofrenda/muerta_death_reckoning_flames_green.vpcf"
	local effect_cast_new = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast_new )
end