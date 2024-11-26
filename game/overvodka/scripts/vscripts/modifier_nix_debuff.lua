modifier_nix_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_nix_debuff:IsHidden()
	return false
end

function modifier_nix_debuff:IsDebuff()
	return true
end

function modifier_nix_debuff:IsStunDebuff()
	return false
end

function modifier_nix_debuff:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_nix_debuff:OnCreated( kv )
	-- references
	self.lose_strength = self:GetAbility():GetSpecialValueFor( "lose_strength" ) -- special value
end

function modifier_nix_debuff:OnRefresh( kv )
	-- references
	self.lose_strength = self:GetAbility():GetSpecialValueFor( "lose_strength" ) -- special value
end

function modifier_nix_debuff:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_nix_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_nix_debuff:GetModifierBonusStats_Strength_Percentage( params )
	return -self.lose_strength/100

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_nix_debuff:GetEffectName()
	return "particles/units/heroes/hero_enchantress/enchantress_untouchable.vpcf"
end

function modifier_nix_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

