modifier_fountain_aura_effect_lua = class({})

--------------------------------------------------------------------------------

function modifier_fountain_aura_effect_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
	}
	return funcs
end

function modifier_fountain_aura_effect_lua:GetTexture()
	return "rune_regen"
end

function modifier_fountain_aura_effect_lua:GetModifierHealthRegenPercentage()
	return 15
end

function modifier_fountain_aura_effect_lua:GetModifierTotalPercentageManaRegen()
	return 15
end

function modifier_fountain_aura_effect_lua:GetModifierConstantManaRegen()
	return 20
end

function modifier_fountain_aura_effect_lua:GetModifierMoveSpeed_Absolute()
	return 550
end