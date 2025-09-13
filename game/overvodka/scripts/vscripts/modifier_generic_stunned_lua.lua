modifier_generic_stunned_lua = class({})

function modifier_generic_stunned_lua:IsDebuff() return true end
function modifier_generic_stunned_lua:IsStunDebuff() return true end

function modifier_generic_stunned_lua:OnCreated( kv )
	if not IsServer() then return end
	local resist = 1-self:GetParent():GetStatusResistance()
	local duration = kv.duration*resist
	self:SetDuration( duration, true )
end

function modifier_generic_stunned_lua:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_generic_stunned_lua:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end

function modifier_generic_stunned_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end

function modifier_generic_stunned_lua:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

function modifier_generic_stunned_lua:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_generic_stunned_lua:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end