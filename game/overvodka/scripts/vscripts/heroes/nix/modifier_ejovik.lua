modifier_ejovik = class({})
--------------------------------------------------------------------------------
function modifier_ejovik:IsPurgable()
	return true
end

function modifier_ejovik:OnCreated( kv )
	self.as = self:GetAbility():GetSpecialValueFor( "bonus_as" )
	self.mp = self:GetAbility():GetSpecialValueFor( "bonus_mp" )
	self.resist = self:GetAbility():GetSpecialValueFor( "bonus_resist" )
	self.evasion = self:GetAbility():GetSpecialValueFor( "evasion" )
	self.mag = self:GetAbility():GetSpecialValueFor( "bonus_mag" )
	self.range = self:GetAbility():GetSpecialValueFor( "bonus_range" )
	self.vision = self:GetAbility():GetSpecialValueFor( "bonus_vision" )
	self.shard = self:GetParent():HasModifier("modifier_item_aghanims_shard")
	self.armor = self:GetAbility():GetSpecialValueFor( "armor" )
	self:StartIntervalThink(1)
end

--------------------------------------------------------------------------------
function modifier_ejovik:OnIntervalThink()
	self.armor = self.armor + 4
end
function modifier_ejovik:OnRemoved()
end


--------------------------------------------------------------------------------

function modifier_ejovik:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}

	return funcs
end
function modifier_ejovik:CheckState()
	local state = {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_FORCED_FLYING_VISION] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = self.shard,
		[MODIFIER_STATE_DEBUFF_IMMUNE] = self.shard,
	}

	return state
end
--------------------------------------------------------------------------------
function modifier_ejovik:GetModifierPhysicalArmorBonus( params )
	if not self.shard then return end
	return self.armor
end
function modifier_ejovik:GetBonusDayVision( params )
	return self.vision
end
function modifier_ejovik:GetBonusNightVision( params )
	return self.vision
end
function modifier_ejovik:GetModifierConstantManaRegen( params )
	return self.mp
end
function modifier_ejovik:GetModifierAttackRangeBonus( params )
	return self.range
end
function modifier_ejovik:GetModifierSpellAmplify_Percentage( params )
	return self.mag
end
function modifier_ejovik:GetModifierMagicalResistanceBonus( params )
	return self.resist
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
function modifier_ejovik:GetEffectName()
	if not self.shard then return end
	return "particles/pangolier_shard_rollup_magic_immune_nix.vpcf"
end

function modifier_ejovik:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end