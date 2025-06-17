modifier_invincible_arcana = class({})

function modifier_invincible_arcana:IsHidden()
	return true
end

function modifier_invincible_arcana:IsPurgable()
	return false
end

function modifier_invincible_arcana:IsPurgeException()
	return false
end

function modifier_invincible_arcana:IsPermanent()
	return true
end

function modifier_invincible_arcana:RemoveOnDeath()
	return false
end

function modifier_invincible_arcana:AllowIllusionDuplicate()
	return true
end

function modifier_invincible_arcana:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_invincible_arcana:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
	}
end

function modifier_invincible_arcana:GetModifierModelChange()
	return "models/invincible/arcana/whatsapp.vmdl"
end

function modifier_invincible_arcana:GetModifierModelScale()
	return -10
end