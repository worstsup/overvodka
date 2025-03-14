modifier_serega_topor = class({})

function modifier_serega_topor:IsHidden()
	return false
end
function modifier_serega_topor:IsDebuff()
	return true
end
function modifier_serega_topor:IsPurgable()
	return true
end

function modifier_serega_topor:OnCreated( kv )
	if not IsServer() then return end
	self:SetHasCustomTransmitterData( true )
	self.slow = kv.slow
	self:SetStackCount( self.slow )
end

function modifier_serega_topor:OnRefresh( kv )
	if not IsServer() then return end
	self.slow = math.max(kv.slow,self.slow)
	self:SetStackCount( self.slow )
end

function modifier_serega_topor:OnRemoved()
end
function modifier_serega_topor:OnDestroy()
end

function modifier_serega_topor:AddCustomTransmitterData()
	local data = {
		slow = self.slow
	}

	return data
end

function modifier_serega_topor:HandleCustomTransmitterData( data )
	self.slow = data.slow
end

function modifier_serega_topor:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_serega_topor:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow
end