modifier_overvodka_store_skin_1 = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsPurgeException        = function(self) return false end,
    IsDebuff                = function(self) return false end,
    RemoveOnDeath           = function(self) return false end,
    IsPermanent             = function(self) return true end,
    GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end,
})

function modifier_overvodka_store_skin_1:OnCreated()
	if not IsServer() then return end
	self:GetParent().lit1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "litvin/litenergy/lit_energy.vmdl"})
	self:GetParent().lit1:FollowEntityMerge(self:GetParent(), "attach_attack1")
	self:GetParent().lit2 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "litvin/litenergy/lit_energy.vmdl"})
	self:GetParent().lit2:FollowEntityMerge(self:GetParent(), "attach_attack2")
end

function modifier_overvodka_store_skin_1:OnDestroy()
	if not IsServer() then return end
	if self:GetParent().lit1 then
		self:GetParent().lit1:RemoveSelf()
	end
	if self:GetParent().lit2 then
		self:GetParent().lit2:RemoveSelf()
	end
end