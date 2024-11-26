modifier_generic_armor = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_generic_armor:IsDebuff()
	return true
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_generic_armor:OnCreated( kv )
	if not IsServer() then return end
	-- calculate status resistance
	local resist = 1-self:GetParent():GetStatusResistance()
	local duration = kv.duration*resist
	self:SetDuration( duration, true )
end

function modifier_generic_armor:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_generic_armor:OnRemoved()
end

function modifier_generic_armor:OnDestroy()
end


--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_generic_armor:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return funcs
end

function modifier_generic_armor:GetModifierPhysicalArmorBonus( params )
	return -self:GetAbility():GetLevel() * 2
end
