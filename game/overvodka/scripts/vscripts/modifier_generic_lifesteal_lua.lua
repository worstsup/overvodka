modifier_generic_lifesteal_lua = class({})

function modifier_generic_lifesteal_lua:IsHidden()
	return false
end

function modifier_generic_lifesteal_lua:IsDebuff()
	return false
end

function modifier_generic_lifesteal_lua:IsPurgable()
	return true
end
 
function modifier_generic_lifesteal_lua:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.lifesteal = self:GetAbility():GetSpecialValueFor( "lifesteal_pct" )/100
	if not IsServer() then return end
	self:PlayEffects1()
end

function modifier_generic_lifesteal_lua:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_generic_lifesteal_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

function modifier_generic_lifesteal_lua:GetModifierProcAttack_Feedback( params )
	if not IsServer() then return end
	if params.target:GetTeamNumber()==self.parent:GetTeamNumber() then return end
	if params.target:IsBuilding() or params.target:IsOther() then return end
	self.attack_record = params.record
end

function modifier_generic_lifesteal_lua:OnTakeDamage( params )
	if not IsServer() then return end
	if self.attack_record ~= params.record then return end
	local heal = params.damage * self.lifesteal
	self.parent:Heal( heal, self.ability )
	self:PlayEffects2()
end

function modifier_generic_lifesteal_lua:ShouldUseOverheadOffset()
	return true
end

function modifier_generic_lifesteal_lua:GetStatusEffectName()
	return "particles/status_fx/status_effect_marci_sidekick.vpcf"
end

function modifier_generic_lifesteal_lua:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function modifier_generic_lifesteal_lua:PlayEffects2()
	local particle_cast = "particles/generic_gameplay/generic_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_generic_lifesteal_lua:PlayEffects1()
	local particle_cast = "particles/units/heroes/hero_marci/marci_sidekick_self_buff.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_OVERHEAD_FOLLOW, self.parent )
	ParticleManager:SetParticleControl( effect_cast, 1, self.parent:GetOrigin() )
	self:AddParticle(effect_cast, false, false, 1, false, true)
end