modifier_serega_sven = class({})

function modifier_serega_sven:IsPurgable()
	return false
end
function modifier_serega_sven:IsHidden()
	return true
end
function modifier_serega_sven:OnCreated( kv )
	if not IsServer() then return end
end
function modifier_serega_sven:OnRemoved()
end
function modifier_serega_sven:OnRefresh( kv )
	self:OnCreated( kv )
end
function modifier_serega_sven:OnDestroy()
	if not IsServer() then return end
end
function modifier_serega_sven:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MODEL_CHANGE,
	}
	return funcs
end

function modifier_serega_sven:GetModifierModelChange()
	return "litvin/models/heroes/lit/sven_new.vmdl"
end
