modifier_generic_silenced_lua = class({})

function modifier_generic_silenced_lua:IsDebuff() return true end
function modifier_generic_silenced_lua:IsStunDebuff() return true end

function modifier_generic_silenced_lua:OnCreated( kv )
	if not IsServer() then return end
	local resist = 1-self:GetParent():GetStatusResistance()
	local duration = kv.duration*resist
	self:SetDuration( duration, true )
end

function modifier_generic_silenced_lua:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_generic_silenced_lua:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
	}
end

function modifier_generic_silenced_lua:GetEffectName()
	return "particles/generic_gameplay/generic_silenced.vpcf"
end

function modifier_generic_silenced_lua:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end