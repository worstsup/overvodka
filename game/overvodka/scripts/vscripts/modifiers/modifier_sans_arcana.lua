modifier_sans_arcana = class({})

function modifier_sans_arcana:IsHidden()
	return true
end

function modifier_sans_arcana:IsPurgable()
	return false
end

function modifier_sans_arcana:IsPurgeException()
	return false
end

function modifier_sans_arcana:IsPermanent()
	return true
end

function modifier_sans_arcana:RemoveOnDeath()
	return false
end

function modifier_sans_arcana:AllowIllusionDuplicate()
	return true
end

function modifier_sans_arcana:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_sans_arcana:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		MODIFIER_PROPERTY_MODEL_CHANGE,
	}
end

function modifier_sans_arcana:GetModifierModelChange()
	return "sans/underfell_sans.vmdl"
end

function modifier_sans_arcana:GetModifierProjectileName()
	return "particles/sans_base_attack_arcana.vpcf"
end

function modifier_sans_arcana:GetAttackSound()
	return "Hero_Nevermore.Attack"
end