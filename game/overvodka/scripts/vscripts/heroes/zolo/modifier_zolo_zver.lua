modifier_zolo_zver = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_zolo_zver:IsHidden()
	return true
end

function modifier_zolo_zver:IsDebuff()
	return false
end

function modifier_zolo_zver:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_zolo_zver:OnCreated( kv )
	-- references
	self.bonus_damage = self:GetAbility():GetSpecialValueFor( "bonus_damage_vs_heroes" )
	self.bonus_crit = self:GetAbility():GetSpecialValueFor( "crit_mult" )
end

function modifier_zolo_zver:OnRefresh( kv )
end

function modifier_zolo_zver:OnRemoved()
end

function modifier_zolo_zver:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_zolo_zver:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE_POST_CRIT,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	}

	return funcs
end

function modifier_zolo_zver:GetModifierPreAttack_BonusDamagePostCrit( params )
	if not IsServer() then return end
	return self.bonus_damage
end
function modifier_zolo_zver:GetModifierPreAttack_CriticalStrike( params )
	return self.bonus_crit
end