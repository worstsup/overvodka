modifier_ashab_slushay_buff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_ashab_slushay_buff:IsHidden()
	return true
end

function modifier_ashab_slushay_buff:IsDebuff()
	return false
end

function modifier_ashab_slushay_buff:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
function modifier_ashab_slushay_buff:OnCreated( kv )
	if not IsServer() then return end
	self.bonus = kv.bonus
end

function modifier_ashab_slushay_buff:OnRefresh( kv )
end

function modifier_ashab_slushay_buff:OnRemoved()
end

function modifier_ashab_slushay_buff:OnDestroy()
end

--------------------------------------------------------------------------------
function modifier_ashab_slushay_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_SUPPRESS_CLEAVE,
	}

	return funcs
end

function modifier_ashab_slushay_buff:GetModifierPreAttack_BonusDamage()
	return self.bonus
end

function modifier_ashab_slushay_buff:GetSuppressCleave()
	return 1
end