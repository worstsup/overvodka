modifier_overvodka_store_skin_13 = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsPurgeException        = function(self) return false end,
    IsDebuff                = function(self) return false end,
    RemoveOnDeath           = function(self) return false end,
    IsPermanent             = function(self) return true end,
    GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end,
})

function modifier_overvodka_store_skin_13:OnCreated()
	if not IsServer() then return end
	self:GetParent().mask = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/invincible/maska.vmdl"})
	self:GetParent().mask:FollowEntityMerge(self:GetParent(), "attach_head")
end

function modifier_overvodka_store_skin_13:OnDestroy()
	if not IsServer() then return end
	if self:GetParent().mask then
		self:GetParent().mask:RemoveSelf()
	end
end