modifier_cheater_rage = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_cheater_rage:IsHidden()
	return false
end

function modifier_cheater_rage:IsDebuff()
	return false
end

function modifier_cheater_rage:IsPurgable()
	return false
end

function modifier_cheater_rage:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_cheater_rage:OnCreated( kv )
	if not IsServer() then return end
	self.bonus = self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
	self.reduction = self:GetAbility():GetSpecialValueFor( "focusfire_damage_reduction" )
	self:StartIntervalThink(0.1)
end

function modifier_cheater_rage:OnRefresh( kv )
	if not IsServer() then return end
	self.bonus = self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
	self.reduction = self:GetAbility():GetSpecialValueFor( "focusfire_damage_reduction" )
end

function modifier_cheater_rage:OnRemoved()
end

function modifier_cheater_rage:OnDestroy()
	self:GetParent():StartGesture(ACT_DOTA_IDLE)
end
function modifier_cheater_rage:OnIntervalThink()
	self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_6)
end
--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_cheater_rage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK,
	}

	return funcs
end
function modifier_cheater_rage:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
	}

	return state
end

function modifier_cheater_rage:GetModifierAttackSpeedBonus_Constant()
	return self.bonus
end
function modifier_cheater_rage:GetModifierDamageOutgoing_Percentage()
	return self.reduction
end

function modifier_cheater_rage:OnAttack( params )
	if params.attacker~=self:GetParent() then return end
	self:GetParent():EmitSound("scar")
end