LinkLuaModifier( "modifier_chillguy_r", "heroes/chillguy/chillguy_r", LUA_MODIFIER_MOTION_NONE )

chillguy_r = class({})

function chillguy_r:OnSpellStart()
	if not global_sounds_muted then
		EmitSoundOn( "chillguy_r", self:GetCaster() )
	end
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_chillguy_r", { duration = self:GetSpecialValueFor( "duration" ) } )
end

modifier_chillguy_r = class({})

function modifier_chillguy_r:IsPurgable() return false end

function modifier_chillguy_r:OnCreated()
	self.bonus_hpregen = self:GetAbility():GetSpecialValueFor( "bonus_hpregen" )
	self.model_scale = self:GetAbility():GetSpecialValueFor( "model_scale" )
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "bonus_ms" )
	self.spell_amp = self:GetAbility():GetSpecialValueFor( "spell_amp" )
end

function modifier_chillguy_r:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}
end

function modifier_chillguy_r:GetModifierModelScale()
	return self.model_scale
end

function modifier_chillguy_r:GetModifierConstantHealthRegen()
	return self.bonus_hpregen
end

function modifier_chillguy_r:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_ms
end

function modifier_chillguy_r:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end