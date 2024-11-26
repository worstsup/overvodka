modifier_otec = class({})
--------------------------------------------------------------------------------
function modifier_otec:IsPurgable()
	return false
end

function modifier_otec:OnCreated( kv )
	self.move_speed = self:GetAbility():GetSpecialValueFor( "move_speed" )
	self.model_scale = self:GetAbility():GetSpecialValueFor( "model_scale" )
	self.bonus_strength = self:GetAbility():GetSpecialValueFor( "bonus_strength" )
	self.bonus_intellect = self:GetAbility():GetSpecialValueFor( "bonus_intellect" )
	self.bonus_agility = 0
	if self:GetCaster():GetUnitName() == "npc_dota_hero_lion" then
		local Talented = self:GetCaster():FindAbilityByName("special_bonus_unique_enigma_2")
		if Talented:GetLevel() == 1 then
			self.bonus_agility = self.bonus_agility + 200
		end
	end
end

--------------------------------------------------------------------------------

function modifier_otec:OnRemoved()
end

--------------------------------------------------------------------------------

function modifier_otec:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}

	return funcs
end

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_otec:GetModifierModelScale( params )
	return self.model_scale
end

function modifier_otec:GetModifierBonusStats_Strength( params )
	return self.bonus_strength
end

function modifier_otec:GetModifierBonusStats_Intellect( params )
	return self.bonus_intellect
end

function modifier_otec:GetModifierMoveSpeed_Limit( params )
	return self.move_speed
end

function modifier_otec:GetModifierBonusStats_Agility( params )
	return self.bonus_agility
end