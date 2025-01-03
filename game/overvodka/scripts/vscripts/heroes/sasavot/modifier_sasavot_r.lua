modifier_sasavot_r = class({})

--------------------------------------------------------------------------------

function modifier_sasavot_r:IsHidden()
	return false
end

function modifier_sasavot_r:IsDebuff()
	return false
end

function modifier_sasavot_r:IsPurgable()
	return false
end
--------------------------------------------------------------------------------

function modifier_sasavot_r:OnCreated( kv )
	-- get reference
	self.damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
	self.status = self:GetAbility():GetSpecialValueFor("status_res")
end

function modifier_sasavot_r:OnRefresh( kv )
	-- get reference
	self.damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
	self.status = self:GetAbility():GetSpecialValueFor("status_res")
end

function modifier_sasavot_r:OnDestroy( kv )
	-- get reference
	self.damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
end
--------------------------------------------------------------------------------

function modifier_sasavot_r:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
		MODIFIER_PROPERTY_MODEL_SCALE,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_sasavot_r:GetModifierIncomingDamage_Percentage( params )
	return -self.damage_reduction
end

function modifier_sasavot_r:GetModifierModelScale( params )
	return 30
end

function modifier_sasavot_r:GetModifierStatusResistance( params )
	return self.status
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_sasavot_r:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
end

function modifier_sasavot_r:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end