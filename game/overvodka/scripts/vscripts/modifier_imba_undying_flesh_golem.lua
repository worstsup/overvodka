modifier_imba_undying_flesh_golem = modifier_imba_undying_flesh_golem or class({})

function modifier_imba_undying_flesh_golem:GetEffectName()
	return "particles/units/heroes/hero_undying/undying_fg_aura.vpcf"
end

function modifier_imba_undying_flesh_golem:OnCreated()
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		self.str_percentage = self:GetAbility():GetOrbSpecialValueFor( "str_percentage", "e")
		self.duration       = self:GetAbility():GetOrbSpecialValueFor( "duration", "w" )
	else
		self.str_percentage = 60
		self.duration       = 15
	end
	if not IsServer() then return end
	self:StartIntervalThink(0.5)
end

function modifier_imba_undying_flesh_golem:OnIntervalThink()
	self.strength   = 0
	self.strength   = self:GetParent():GetStrength() * self.str_percentage * 0.01
	self:GetParent():CalculateStatBonus(true)
end

function modifier_imba_undying_flesh_golem:OnDestroy()
	if not IsServer() then return end
	self:GetParent():EmitSound("Hero_Undying.FleshGolem.End")
end

function modifier_imba_undying_flesh_golem:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_EVENT_ON_DEATH
	}
end

function modifier_imba_undying_flesh_golem:OnTooltip()
	return self.str_percentage
end


function modifier_imba_undying_flesh_golem:GetModifierBonusStats_Strength()
	return self.strength
end

function modifier_imba_undying_flesh_golem:GetModifierModelChange()
	return "models/heroes/undying/undying_flesh_golem.vmdl"
end

function modifier_imba_undying_flesh_golem:OnDeath(keys)
	if keys.unit == self:GetParent() and (not self:GetAbility() or not self:GetAbility():IsStolen()) then
		self:Destroy()
	end
end