modifier_c4_ring = class({})
--------------------------------------------------------------------------------
-- Classifications
function modifier_c4_ring:IsHidden()
	return true
end

function modifier_c4_ring:IsDebuff()
	return false
end

function modifier_c4_ring:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_c4_ring:OnCreated( kv )
	local nFXIndex = ParticleManager:CreateParticle( "particles/doom_bringer_doom_ring_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius, 1, self.radius ) )
	self:AddParticle( nFXIndex, false, false, -1, false, false )
	local nFXIndex1 = ParticleManager:CreateParticle( "particles/doom_bringer_doom_ring_bomb.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( nFXIndex1, 1, Vector( self.radius, 1, self.radius ) )
	self:AddParticle( nFXIndex1, false, false, -1, false, false )
end

function modifier_c4_ring:OnRefresh( kv )
	local nFXIndex = ParticleManager:CreateParticle( "particles/doom_bringer_doom_ring_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius, 1, self.radius ) )
	self:AddParticle( nFXIndex, false, false, -1, false, false )
	local nFXIndex1 = ParticleManager:CreateParticle( "particles/doom_bringer_doom_ring_bomb.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( nFXIndex1, 1, Vector( self.radius, 1, self.radius ) )
	self:AddParticle( nFXIndex1, false, false, -1, false, false )
end

function modifier_c4_ring:OnDestroy( kv )
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_c4_ring:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}

	return funcs
end
function modifier_c4_ring:GetModifierIncomingDamage_Percentage()
	return -100
end

function modifier_c4_ring:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}

	return state
end