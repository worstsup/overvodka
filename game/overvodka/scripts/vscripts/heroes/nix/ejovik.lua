LinkLuaModifier( "modifier_ejovik", "heroes/nix/ejovik", LUA_MODIFIER_MOTION_NONE )

ejovik = class({})

function ejovik:Precache( context )
	PrecacheResource( "soundfile", "soundevents/ejovik.vsndevts", context ) 
	PrecacheResource( "particle", "particles/pangolier_shard_rollup_magic_immune_nix.vpcf", context )
end

function ejovik:OnSpellStart()
	if not IsServer() then return end
	EmitSoundOn( "ejovik", self:GetCaster() )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_ejovik", { duration = self:GetSpecialValueFor( "duration" ) } )
end


modifier_ejovik = class({})

function modifier_ejovik:IsPurgable() return true end

function modifier_ejovik:OnCreated()
	self.shard = self:GetParent():HasShard()
	self.armor = self:GetAbility():GetSpecialValueFor( "armor" )
	self:StartIntervalThink(1)
end

function modifier_ejovik:OnIntervalThink()
	self.shard = self:GetParent():HasShard()
	local armor_step = self:GetAbility():GetSpecialValueFor( "armor" )
	if armor_step > 0 then
		self.armor = self.armor + armor_step
	end
end

function modifier_ejovik:DeclareFunctions()
	return {
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
end

function modifier_ejovik:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_FORCED_FLYING_VISION] = true,
		[MODIFIER_STATE_DEBUFF_IMMUNE] = self:GetParent():HasShard(),
	}
end

function modifier_ejovik:GetModifierPhysicalArmorBonus()
	if not self:GetParent():HasShard() then return end
	return self.armor
end
function modifier_ejovik:GetBonusDayVision()
	return self:GetAbility():GetSpecialValueFor( "bonus_vision" )
end
function modifier_ejovik:GetBonusNightVision()
	return self:GetAbility():GetSpecialValueFor( "bonus_vision" )
end
function modifier_ejovik:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor( "bonus_mp" )
end
function modifier_ejovik:GetModifierAttackRangeBonus()
	return self:GetAbility():GetSpecialValueFor( "bonus_range" )
end
function modifier_ejovik:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor( "bonus_mag" )
end
function modifier_ejovik:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor( "bonus_resist" )
end
function modifier_ejovik:GetModifierEvasion_Constant()
	return self:GetAbility():GetSpecialValueFor( "evasion" )
end
function modifier_ejovik:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor( "bonus_as" )
end
function modifier_ejovik:GetModifierModelChange()
	return "nix/pc_nightmare_mushroom.vmdl"
end

function modifier_ejovik:GetEffectName()
	if not self:GetParent():HasShard() then return end
	return "particles/pangolier_shard_rollup_magic_immune_nix.vpcf"
end

function modifier_ejovik:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
