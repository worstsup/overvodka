modifier_fountain_aura_effect_lua = class({})

function modifier_fountain_aura_effect_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
	}
	return funcs
end

local function _HasApocalypseOn(unit)
    return unit and not unit:IsNull() and (unit:HasModifier("modifier_visitor_r") or unit:HasModifier("modifier_visitor_r_cooldown"))
end

function modifier_fountain_aura_effect_lua:GetTexture()
	return "rune_regen"
end

function modifier_fountain_aura_effect_lua:GetModifierHealthRegenPercentage()
	local parent = self:GetParent()
	if _HasApocalypseOn(parent) then
		return 0
	end
	return 15
end

function modifier_fountain_aura_effect_lua:GetModifierTotalPercentageManaRegen()
	local parent = self:GetParent()
	if _HasApocalypseOn(parent) then
		return 0
	end
	return 15
end

function modifier_fountain_aura_effect_lua:GetModifierConstantManaRegen()
	local parent = self:GetParent()
	if _HasApocalypseOn(parent) then
		return 0
	end
	return 20
end

function modifier_fountain_aura_effect_lua:GetModifierMoveSpeed_Absolute()
	return 550
end