modifier_ashab_dogon_debuff = class({})

function modifier_ashab_dogon_debuff:IsHidden()
	if IsClient() then
		return GetLocalPlayerTeam()~=self:GetCaster():GetTeamNumber()
	end

	return true
end

function modifier_ashab_dogon_debuff:IsDebuff()
	return true
end
function modifier_ashab_dogon_debuff:IsHidden()
	return true
end
function modifier_ashab_dogon_debuff:IsPurgable()
	return false
end

function modifier_ashab_dogon_debuff:OnCreated( kv )
	if not IsServer() then return end
	self:PlayEffects()
end

function modifier_ashab_dogon_debuff:OnRefresh( kv )
	
end

function modifier_ashab_dogon_debuff:OnRemoved()
end

function modifier_ashab_dogon_debuff:OnDestroy()
end

function modifier_ashab_dogon_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
	}

	return funcs
end

function modifier_ashab_dogon_debuff:GetModifierProvidesFOWVision()
	return 1
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_ashab_dogon_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_PROVIDES_VISION] = true,
	}

	return state
end


function modifier_ashab_dogon_debuff:PlayEffects()
	local particle_cast = "particles/spirit_breaker_charge_target_new.vpcf"
	local effect_cast = ParticleManager:CreateParticleForTeam( particle_cast, PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber() )
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end