modifier_overvodka_store_skin_2 = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsPurgeException        = function(self) return false end,
    IsDebuff                = function(self) return false end,
    RemoveOnDeath           = function(self) return false end,
    IsPermanent             = function(self) return true end,
    GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end,
})

function modifier_overvodka_store_skin_2:OnCreated()
	if not IsServer() then return end
	self:GetParent():SetRenderColor(0, 0, 255)
end

function modifier_overvodka_store_skin_2:OnDestroy()
	if not IsServer() then return end
	self:GetParent():SetRenderColor(255, 255, 255) 
end