modifier_overvodka_store_skin_14 = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsPurgeException        = function(self) return false end,
    IsDebuff                = function(self) return false end,
    RemoveOnDeath           = function(self) return false end,
    IsPermanent             = function(self) return true end,
    GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end,
})

function modifier_overvodka_store_skin_14:OnCreated()
	if not IsServer() then return end
end

function modifier_overvodka_store_skin_14:OnDestroy()
	if not IsServer() then return end
end

function modifier_overvodka_store_skin_14:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
	}
end

function modifier_overvodka_store_skin_14:GetModifierModelChange()
	return "models/drun/temniydrun.vmdl"
end

function modifier_overvodka_store_skin_14:GetAttackSound()
	return "Hero_NightStalker.Attack"
end
