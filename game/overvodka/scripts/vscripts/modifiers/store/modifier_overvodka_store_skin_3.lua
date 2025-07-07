modifier_overvodka_store_skin_3 = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsPurgeException        = function(self) return false end,
    IsDebuff                = function(self) return false end,
    RemoveOnDeath           = function(self) return false end,
    IsPermanent             = function(self) return true end,
    GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end,
})

function modifier_overvodka_store_skin_3:OnCreated()
	if not IsServer() then return end
	self:GetParent():SetMaterialGroup("skin1")
end

function modifier_overvodka_store_skin_3:OnDestroy()
	if not IsServer() then return end
	self:GetParent():SetMaterialGroup("default")
end