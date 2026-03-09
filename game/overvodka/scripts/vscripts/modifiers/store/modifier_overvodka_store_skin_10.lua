modifier_overvodka_store_skin_10 = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsPurgeException        = function(self) return false end,
    IsDebuff                = function(self) return false end,
    RemoveOnDeath           = function(self) return false end,
    IsPermanent             = function(self) return true end,
    GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end,
})

function modifier_overvodka_store_skin_10:OnCreated()
	if not IsServer() then return end
end

function modifier_overvodka_store_skin_10:OnDestroy()
	if not IsServer() then return end
end

function modifier_overvodka_store_skin_10:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE,
	}
end

function modifier_overvodka_store_skin_10:GetModifierModelChange()
	return "sasavot/sasavot_arcana/sasavotarcana.vmdl"
end