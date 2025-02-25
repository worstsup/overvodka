modifier_sasavot_q = class({})

function modifier_sasavot_q:IsHidden()
	return false
end
function modifier_sasavot_q:IsDebuff()
	return true
end
function modifier_sasavot_q:IsPurgable()
	return false
end
function modifier_sasavot_q:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_sasavot_q:OnCreated( kv )
	if IsServer() then
		self:PlayEffects()
	end
end

function modifier_sasavot_q:OnRefresh( kv )
end
function modifier_sasavot_q:OnDestroy( kv )
end

function modifier_sasavot_q:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
	}
	return funcs
end

function modifier_sasavot_q:GetModifierProvidesFOWVision()
	return true
end

function modifier_sasavot_q:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = false,
		[MODIFIER_STATE_PROVIDES_VISION] = true,
	}
	return state
end

function modifier_sasavot_q:PlayEffects()
	local particle_cast = "particles/units/heroes/hero_sniper/sniper_crosshair.vpcf"
	local effect_cast = ParticleManager:CreateParticleForTeam( particle_cast, PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber() )
	self:AddParticle(effect_cast, false, false, -1, false, true)
end