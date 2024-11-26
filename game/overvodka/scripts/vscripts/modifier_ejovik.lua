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
	self:GetParent():SetOriginalModel("maps/cavern_assets/models/mushrooms/mushroom_inkycap_01.vmdl")
	self:GetParent():SetModelScale(1.2)
end

--------------------------------------------------------------------------------

function modifier_ejovik:OnRemoved()
	model = "models/heroes/furion/furion.vmdl"
	if self:GetParent():GetUnitName() == "npc_dota_hero_rubick" then
		model = "models/heroes/rubick/rubick.vmdl"
	end
	self:GetParent():SetOriginalModel(model)
	self:GetParent():SetModelScale(1)
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
function modifier_ejovik:PlayEffects( target )
	self.nChannelFX = ParticleManager:CreateParticle( "particles/econ/items/shadow_shaman/ti8_ss_mushroomer_belt/ti8_ss_mushroomer_belt_ambient_shimmer.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
end
