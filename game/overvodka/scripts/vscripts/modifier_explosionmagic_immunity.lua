
modifier_ExplosionMagic_immunity = class({})

-----------------------------------------------------------------------------------------

function modifier_ExplosionMagic_immunity:IsHidden()
	return true
end

-----------------------------------------------------------------------------------------

function modifier_ExplosionMagic_immunity:IsPurgable()
	return false
end
function modifier_ExplosionMagic_immunity:OnCreated()
	if not IsServer() then return end
	self.scepter = false
	self.slow = self:GetAbility():GetSpecialValueFor("scepter_slow")
end
-----------------------------------------------------------------------------------------

function modifier_ExplosionMagic_immunity:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = self.scepter,}
end

function modifier_ExplosionMagic_immunity:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end
function modifier_ExplosionMagic_immunity:GetModifierMoveSpeedBonus_Percentage()
	return -50
end

-----------------------------------------------------------------------------------------

function modifier_ExplosionMagic_immunity:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_ExplosionMagic_immunity:GetEffectName()
	if not self.scepter then return end
	return "particles/econ/items/lifestealer/lifestealer_immortal_backbone_gold/lifestealer_immortal_backbone_gold_rage.vpcf"
end
function modifier_ExplosionMagic_immunity:GetEffectAttachType()
	if not self.scepter then return end
	return PATTACH_ABSORIGIN_FOLLOW
end
-----------------------------------------------------------------------------------------

