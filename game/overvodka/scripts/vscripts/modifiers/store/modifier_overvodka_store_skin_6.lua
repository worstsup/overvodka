modifier_overvodka_store_skin_6 = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsPurgeException        = function(self) return false end,
    IsDebuff                = function(self) return false end,
    RemoveOnDeath           = function(self) return false end,
    IsPermanent             = function(self) return true end,
    GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end,
})

function modifier_overvodka_store_skin_6:OnCreated()
	if not IsServer() then return end
end

function modifier_overvodka_store_skin_6:OnDestroy()
	if not IsServer() then return end
end

function modifier_overvodka_store_skin_6:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE
	}
end

function modifier_overvodka_store_skin_6:GetModifierModelChange()
	return "models/blackflash/blackflash.vmdl"
end

function modifier_overvodka_store_skin_6:GetModifierModelScale()
	return 0
end