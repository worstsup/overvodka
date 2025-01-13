modifier_chillzone_effect = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_chillzone_effect:IsHidden()
	return false
end

function modifier_chillzone_effect:IsDebuff()
	return not self:NotAffected()
end

function modifier_chillzone_effect:IsStunDebuff()
	return not self:NotAffected()
end

function modifier_chillzone_effect:IsPurgable()
	return false
end

function modifier_chillzone_effect:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function modifier_chillzone_effect:NotAffected()
	if self:GetParent()==self:GetCaster() then return true end
	if self:GetParent():GetPlayerOwnerID()==self:GetCaster():GetPlayerOwnerID() then return true end
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_chillzone_effect:OnCreated( kv )
	self.speed = 550
	self.slow = self:GetAbility():GetSpecialValueFor("slow")
	if IsServer() then
		if not self:NotAffected() then
			self:GetParent():InterruptMotionControllers( false )
		else
			self:PlayEffects()
		end
	end
end

function modifier_chillzone_effect:OnRefresh( kv )
	
end

function modifier_chillzone_effect:OnRemoved()
end

function modifier_chillzone_effect:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_chillzone_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE,
	}

	return funcs
end

function modifier_chillzone_effect:GetModifierMoveSpeed_AbsoluteMin()
	if self:NotAffected() then return self.speed end
end

function modifier_chillzone_effect:GetModifierMoveSpeedBonus_Percentage()
	if not self:NotAffected() then return self.slow end
end

function modifier_chillzone_effect:GetModifierIncomingPhysicalDamage_Percentage()
	return -100
end
--------------------------------------------------------------------------------
-- Status Effects
function modifier_chillzone_effect:CheckState()
	local state1 = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}

	local state2 = {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
	}

	return state2
end

--------------------------------------------------------------------------------
function modifier_chillzone_effect:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_faceless_void/faceless_void_chrono_speed.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	-- ParticleManager:SetParticleControl( effect_cast, iControlPoint, vControlVector )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end