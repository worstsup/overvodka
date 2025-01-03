modifier_litvin_enrage = class({})

--------------------------------------------------------------------------------

function modifier_litvin_enrage:IsHidden()
	return false
end

function modifier_litvin_enrage:IsDebuff()
	return false
end

function modifier_litvin_enrage:IsPurgable()
	return false
end
--------------------------------------------------------------------------------

function modifier_litvin_enrage:OnCreated( kv )
	-- get reference
	self.damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
end

function modifier_litvin_enrage:OnRefresh( kv )
	-- get reference
	self.damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
end

function modifier_litvin_enrage:OnDestroy( kv )
	-- get reference
	self.damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
end
--------------------------------------------------------------------------------

function modifier_litvin_enrage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,

		MODIFIER_PROPERTY_MODEL_SCALE,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_litvin_enrage:GetModifierIncomingDamage_Percentage( params )
	return -self.damage_reduction
end

function modifier_litvin_enrage:GetModifierModelScale( params )
	return 50
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_litvin_enrage:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
end

function modifier_litvin_enrage:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end