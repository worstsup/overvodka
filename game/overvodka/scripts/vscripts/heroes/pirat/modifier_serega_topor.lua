modifier_serega_topor = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_serega_topor:IsHidden()
	return false
end

function modifier_serega_topor:IsDebuff()
	return true
end

function modifier_serega_topor:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_serega_topor:OnCreated( kv )
	if not IsServer() then return end
	-- send init data from server to client
	self:SetHasCustomTransmitterData( true )

	-- references
	self.slow = kv.slow
	self:SetStackCount( self.slow )
end

function modifier_serega_topor:OnRefresh( kv )
	if not IsServer() then return end
	-- references
	self.slow = math.max(kv.slow,self.slow)
	self:SetStackCount( self.slow )
end

function modifier_serega_topor:OnRemoved()
end

function modifier_serega_topor:OnDestroy()
end

--------------------------------------------------------------------------------
-- Transmitter data
function modifier_serega_topor:AddCustomTransmitterData()
	-- on server
	local data = {
		slow = self.slow
	}

	return data
end

function modifier_serega_topor:HandleCustomTransmitterData( data )
	-- on client
	self.slow = data.slow
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_serega_topor:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_serega_topor:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow
end