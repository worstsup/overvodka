golovach_q = class({})
LinkLuaModifier( "modifier_golovach_q", "heroes/golovach/modifier_golovach_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_golovach_q_buff", "heroes/golovach/golovach_q", LUA_MODIFIER_MOTION_NONE )

function golovach_q:GetIntrinsicModifierName()
	return "modifier_golovach_q"
end

modifier_golovach_q_buff = class({})

function modifier_golovach_q_buff:IsHidden()
	return false
end
function modifier_golovach_q_buff:IsDebuff()
	return false
end
function modifier_golovach_q_buff:IsPurgable()
	return false
end

function modifier_golovach_q_buff:OnCreated( kv )
	self.reduction = self:GetAbility():GetSpecialValueFor( "back_damage_reduction" )
end

function modifier_golovach_q_buff:OnRefresh( kv )
	self.reduction = self:GetAbility():GetSpecialValueFor( "back_damage_reduction" )
end

function modifier_golovach_q_buff:OnDestroy( kv )
end

function modifier_golovach_q_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
	return funcs
end

function modifier_golovach_q_buff:GetModifierIncomingDamage_Percentage()
	return -self.reduction
end