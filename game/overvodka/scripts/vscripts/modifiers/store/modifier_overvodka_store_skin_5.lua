modifier_overvodka_store_skin_5 = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsPurgeException        = function(self) return false end,
    IsDebuff                = function(self) return false end,
    RemoveOnDeath           = function(self) return false end,
    IsPermanent             = function(self) return true end,
    GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end,
})

function modifier_overvodka_store_skin_5:OnCreated()
	if not IsServer() then return end
	self:GetParent().back = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/brewmaster/back.vmdl"})
	self:GetParent().back:FollowEntity(self:GetParent(), true)
	self:GetParent().barrel = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/brewmaster/barrel.vmdl"})
	self:GetParent().barrel:FollowEntity(self:GetParent(), true)
	self:GetParent().bracers = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/brewmaster/bracer.vmdl"})
	self:GetParent().bracers:FollowEntity(self:GetParent(), true)
	self:GetParent().weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/brewmaster/weapon.vmdl"})
	self:GetParent().weapon:FollowEntity(self:GetParent(), true)
end

function modifier_overvodka_store_skin_5:OnDestroy()
	if not IsServer() then return end
	if self:GetParent().back then
		self:GetParent().back:RemoveSelf()
	end
	if self:GetParent().barrel then
		self:GetParent().barrel:RemoveSelf()
	end
	if self:GetParent().bracers then
		self:GetParent().bracers:RemoveSelf()
	end
	if self:GetParent().weapon then
		self:GetParent().weapon:RemoveSelf()
	end
end

function modifier_overvodka_store_skin_5:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}
end

function modifier_overvodka_store_skin_5:GetModifierModelChange()
	return "models/heroes/brewmaster/brewmaster.vmdl"
end

function modifier_overvodka_store_skin_5:GetModifierModelScale()
	return -40
end

function modifier_overvodka_store_skin_5:GetAttackSound()
	return "Hero_Brewmaster.Attack"
end