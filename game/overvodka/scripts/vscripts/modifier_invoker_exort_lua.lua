modifier_invoker_exort_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_invoker_exort_lua:IsHidden()
	return false
end

function modifier_invoker_exort_lua:IsDebuff()
	return false
end

function modifier_invoker_exort_lua:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_invoker_exort_lua:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
function modifier_invoker_exort_lua:OnCreated( kv )
	self.damage = self:GetAbility():GetSpecialValueFor( "bonus_damage_per_instance" )
	self.dmg = self:GetAbility():GetSpecialValueFor( "dmg" )
	self.damage_sss = self.damage * 2
	self.dmg_sss = self.dmg * 2
	self:StartIntervalThink(0.5)
end

function modifier_invoker_exort_lua:OnRefresh( kv )
	self.damage = self:GetAbility():GetSpecialValueFor( "bonus_damage_per_instance" )
	self.dmg = self:GetAbility():GetSpecialValueFor( "dmg" )
	self.damage_sss = self.damage * 2
	self.dmg_sss = self.dmg * 2
	self:StartIntervalThink(0.5)
end
function modifier_invoker_exort_lua:OnIntervalThink()
	if self:GetParent():HasModifier("modifier_invoker_ghost_walk_lua") then
		self.damage = self.damage_sss
		self.dmg = self.dmg_sss
	else
		self.damage = self:GetAbility():GetSpecialValueFor( "bonus_damage_per_instance" )
		self.dmg = self:GetAbility():GetSpecialValueFor( "dmg" )
	end
end
function modifier_invoker_exort_lua:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_invoker_exort_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}

	return funcs
end
function modifier_invoker_exort_lua:GetModifierPreAttack_BonusDamage()
	return self.damage
end
function modifier_invoker_exort_lua:GetModifierSpellAmplify_Percentage()
	return self.dmg
end