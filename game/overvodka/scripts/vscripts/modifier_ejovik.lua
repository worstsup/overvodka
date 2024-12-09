modifier_ejovik = class({})
--------------------------------------------------------------------------------
function modifier_ejovik:IsPurgable()
	return true
end

function modifier_ejovik:OnCreated( kv )
	self.as = self:GetAbility():GetSpecialValueFor( "bonus_as" )
	self.ms = self:GetAbility():GetSpecialValueFor( "bonus_ms" )
	self.mp = self:GetAbility():GetSpecialValueFor( "bonus_mp" )
	self.resist = self:GetAbility():GetSpecialValueFor( "bonus_resist" )
	self.evasion = self:GetAbility():GetSpecialValueFor( "evasion" )
	self.mag = self:GetAbility():GetSpecialValueFor( "bonus_mag" )
	self:PlayEffects( self:GetParent() )
end

--------------------------------------------------------------------------------

function modifier_ejovik:OnRemoved()
	ParticleManager:DestroyParticle( self.nChannelFX, false )
end


--------------------------------------------------------------------------------

function modifier_ejovik:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_MODEL_SCALE_ANIMATE_TIME,
	}

	return funcs
end
--------------------------------------------------------------------------------
function modifier_ejovik:GetModifierConstantManaRegen( params )
	return self.mp
end
function modifier_ejovik:GetModifierSpellAmplify_Percentage( params )
	return self.mag
end
function modifier_ejovik:GetModifierMagicalResistanceBonus( params )
	return self.resist
end
function modifier_ejovik:GetModifierMoveSpeedBonus_Percentage( params )
	return self.ms
end
function modifier_ejovik:GetModifierEvasion_Constant( params )
	return self.evasion
end
function modifier_ejovik:GetModifierAttackSpeedBonus_Constant( params )
	return self.as
end
function modifier_ejovik:GetModifierModelChange( params )
	return "nix/pc_nightmare_mushroom.vmdl"
end
function modifier_ejovik:GetModifierModelScaleAnimateTime( params )
	return 0
end
function modifier_ejovik:GetModifierModelScale( params )
	if self:GetParent():GetUnitName() == "npc_dota_hero_rubick" then return 16000 end
	return 0
end
function modifier_ejovik:PlayEffects( target )
	self.nChannelFX = ParticleManager:CreateParticle( "particles/econ/items/shadow_shaman/ti8_ss_mushroomer_belt/ti8_ss_mushroomer_belt_ambient_shimmer.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
end
