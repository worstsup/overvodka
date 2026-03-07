modifier_overvodka_store_skin_9 = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsPurgeException        = function(self) return false end,
    IsDebuff                = function(self) return false end,
    RemoveOnDeath           = function(self) return false end,
    IsPermanent             = function(self) return true end,
    GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end,
})

function modifier_overvodka_store_skin_9:OnCreated()
	if not IsServer() then return end
end

function modifier_overvodka_store_skin_9:OnDestroy()
	if not IsServer() then return end
end

function modifier_overvodka_store_skin_9:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE,
	}
end

function modifier_overvodka_store_skin_9:GetModifierModelChange()
	return "models/arsen/arsen_skin/arsen_skin.vmdl"
end