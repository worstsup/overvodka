modifier_generic_silenced_lua = class({})

function modifier_generic_silenced_lua:IsDebuff() return true end
function modifier_generic_silenced_lua:IsStunDebuff() return true end

function modifier_generic_silenced_lua:OnCreated( kv )
	if not IsServer() then return end
	local resist = 1-self:GetParent():GetStatusResistance()
	local duration = kv.duration*resist
	self:SetDuration( duration, true )

	local pfx_name = kv.particle or "particles/generic_gameplay/generic_silenced.vpcf"
	if pfx_name and pfx_name ~= "" then
		local particle = ParticleManager:CreateParticle(pfx_name, PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		self:AddParticle(particle, false, false, -1, false, false)
	end
end

function modifier_generic_silenced_lua:OnRefresh( kv )
	if not IsServer() then return end
	local resist = 1-self:GetParent():GetStatusResistance()
	local duration = kv.duration*resist
	self:SetDuration( duration, true )
end

function modifier_generic_silenced_lua:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
	}
end
