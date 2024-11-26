modifier_dropchik = class({})
--------------------------------------------------------------------------------
function modifier_dropchik:IsPurgable()
	return false
end

function modifier_dropchik:OnCreated( kv )
	self.move_speed = self:GetAbility():GetSpecialValueFor( "move_speed" )
	self.model_scale = self:GetAbility():GetSpecialValueFor( "model_scale" )
	self.bonus_strength = self:GetAbility():GetSpecialValueFor( "bonus_strength" )
	self.bonus_intellect = self:GetAbility():GetSpecialValueFor( "bonus_intellect" )
	self.bonus_range = self:GetAbility():GetSpecialValueFor( "bonus_range" )
	self.bonus_agility = 0
	self.drdr = self:GetAbility():GetSpecialValueFor( "drdr" )
	self.shard = self:GetCaster():HasModifier("modifier_item_aghanims_shard")
end

--------------------------------------------------------------------------------

function modifier_dropchik:OnRemoved()
end

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

function modifier_dropchik:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}

	return funcs
end
function modifier_dropchik:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = self.shard,
	}

	return state
end
--------------------------------------------------------------------------------


function modifier_dropchik:OnAttackLanded( params )
	if IsServer() then
		params.target:AddNewModifier( self:GetCaster(), self, "modifier_dima", { duration = self.drdr } )
	end
end

--------------------------------------------------------------------------------

function modifier_dropchik:GetModifierModelScale( params )
	return self.model_scale
end
function modifier_dropchik:GetModifierAttackRangeBonus( params )
	return self.bonus_range
end
function modifier_dropchik:GetModifierBonusStats_Strength( params )
	return self.bonus_strength
end

function modifier_dropchik:GetModifierBonusStats_Intellect( params )
	return self.bonus_intellect
end

function modifier_dropchik:GetModifierMoveSpeed_Limit( params )
	return self.move_speed
end

function modifier_dropchik:GetModifierBonusStats_Agility( params )
	return self.bonus_agility
end