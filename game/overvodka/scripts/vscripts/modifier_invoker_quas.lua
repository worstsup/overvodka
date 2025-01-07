modifier_invoker_quas_lua = class({})

--------------------------------------------------------------------------------
function modifier_invoker_quas_lua:IsHidden()
	return false
end

function modifier_invoker_quas_lua:IsDebuff()
	return false
end

function modifier_invoker_quas_lua:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_invoker_quas_lua:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_invoker_quas_lua:OnCreated( kv )
	self.regen = self:GetAbility():GetSpecialValueFor( "health_regen_per_instance" ) -- special value
	self.regen_sss = self.regen * 2
	self:StartIntervalThink(0.5)
end

function modifier_invoker_quas_lua:OnRefresh( kv )
	self.regen = self:GetAbility():GetSpecialValueFor( "health_regen_per_instance" ) -- special value
	self.regen_sss = self.regen * 2
	self:StartIntervalThink(0.5)
end

function modifier_invoker_quas_lua:OnIntervalThink()
	if self:GetParent():HasModifier("modifier_invoker_ghost_walk_lua") then
		self.regen = self.regen_sss
	else
		self.regen = self:GetAbility():GetSpecialValueFor( "health_regen_per_instance" )
	end
end

function modifier_invoker_quas_lua:OnDestroy( kv )
end

--------------------------------------------------------------------------------
function modifier_invoker_quas_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}

	return funcs
end
function modifier_invoker_quas_lua:GetModifierConstantHealthRegen()
	return self.regen
end