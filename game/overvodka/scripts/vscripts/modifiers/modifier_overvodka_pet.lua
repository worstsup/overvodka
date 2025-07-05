modifier_overvodka_pet = class({})

function modifier_overvodka_pet:IsHidden()
	return true
end

function modifier_overvodka_pet:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
	}
end

function modifier_overvodka_pet:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
	}
end

function modifier_overvodka_pet:GetModifierMoveSpeed_Absolute()
	return self:GetParent():GetOwner():GetMoveSpeedModifier(self:GetParent():GetOwner():GetBaseMoveSpeed(), true)
end