modifier_overvodka_store_skin_4 = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsPurgeException        = function(self) return false end,
    IsDebuff                = function(self) return false end,
    RemoveOnDeath           = function(self) return false end,
    IsPermanent             = function(self) return true end,
    GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end,
})

function modifier_overvodka_store_skin_4:OnCreated()
	if not IsServer() then return end
	self:GetParent().back = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/pudge/arcana/pudge_arcana_back.vmdl"})
	self:GetParent().back:FollowEntityMerge(self:GetParent(), "attach_back")
    self:GetParent().back1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/pudge/arcana/pudge_arcana_back.vmdl"})
	self:GetParent().back1:FollowEntityMerge(self:GetParent(), "attach_back1")
	self:GetParent().mask = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "zolo/materials/models/heroes/zol/mask.vmdl"})
	self:GetParent().mask:FollowEntityMerge(self:GetParent(), "attach_mask")
	self.particle = ParticleManager:CreateParticle( "particles/zolo_eye_skin.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() )
    ParticleManager:SetParticleControlEnt( self.particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_eye_l", self:GetParent():GetAbsOrigin(), true )
end

function modifier_overvodka_store_skin_4:OnDestroy()
	if not IsServer() then return end
	if self:GetParent().back then
		self:GetParent().back:RemoveSelf()
	end
    if self:GetParent().back1 then
		self:GetParent().back1:RemoveSelf()
	end
	if self:GetParent().mask then
		self:GetParent().mask:RemoveSelf()
	end
	ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end