modifier_stariy_bolt_debuff = class({})
--------------------------------------------------------------------------------
-- Classifications
function modifier_stariy_bolt_debuff:IsHidden()
	return false
end

function modifier_stariy_bolt_debuff:IsDebuff()
	return true
end

function modifier_stariy_bolt_debuff:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_stariy_bolt_debuff:OnCreated( kv )
	self.ms = self:GetAbility():GetSpecialValueFor( "ms" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
end

function modifier_stariy_bolt_debuff:OnRefresh( kv )
	-- references
	self.ms = self:GetAbility():GetSpecialValueFor( "ms" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
end

function modifier_stariy_bolt_debuff:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_stariy_bolt_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end


function modifier_stariy_bolt_debuff:GetModifierMoveSpeedBonus_Percentage( params )
	return self.ms
end
