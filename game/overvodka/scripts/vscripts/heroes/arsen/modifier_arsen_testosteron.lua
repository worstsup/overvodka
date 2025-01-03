modifier_arsen_testosteron = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_arsen_testosteron:IsHidden()
	return false
end

function modifier_arsen_testosteron:IsDebuff()
	return false
end

function modifier_arsen_testosteron:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_arsen_testosteron:OnCreated( kv )
	-- references
	self.armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
	self.str = self:GetAbility():GetSpecialValueFor( "bonus_str" )
end

function modifier_arsen_testosteron:OnRefresh( kv )
	-- references
	self.armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
	self.str = self:GetAbility():GetSpecialValueFor( "bonus_str" )
end

function modifier_arsen_testosteron:OnRemoved()
end

function modifier_arsen_testosteron:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_arsen_testosteron:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}

	return funcs
end

function modifier_arsen_testosteron:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_arsen_testosteron:GetModifierModelScale()
	return 40
end

function modifier_arsen_testosteron:GetModifierBonusStats_Strength()
	return self.str
end
--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_arsen_testosteron:GetEffectName()
	return "particles/econ/items/ogre_magi/ogre_ti8_immortal_weapon/ogre_ti8_immortal_bloodlust_buff.vpcf"
end

function modifier_arsen_testosteron:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


