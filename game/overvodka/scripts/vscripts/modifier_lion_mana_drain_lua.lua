modifier_lion_mana_drain_lua = class({})

function modifier_lion_mana_drain_lua:IsHidden()
	return false
end
function modifier_lion_mana_drain_lua:IsDebuff()
	return true
end
function modifier_lion_mana_drain_lua:IsStunDebuff()
	return false
end
function modifier_lion_mana_drain_lua:IsPurgable()
	return false
end

function modifier_lion_mana_drain_lua:OnCreated( kv )
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		self.mana = self:GetAbility():GetOrbSpecialValueFor( "mana_per_second", "q" )
		self.slow = -self:GetAbility():GetOrbSpecialValueFor( "movespeed", "q" )
	else
		self.mana = 120
		self.slow = 20
	end
	self.radius = self:GetAbility():GetSpecialValueFor( "break_distance" )
	local interval = self:GetAbility():GetSpecialValueFor( "tick_interval" )

	self.mana = self.mana * interval

	if IsServer() then
		self.parent = self:GetParent()
		self:StartIntervalThink( interval )
		self:PlayEffects()
	end
end

function modifier_lion_mana_drain_lua:OnRefresh( kv )
end
function modifier_lion_mana_drain_lua:OnRemoved()
end

function modifier_lion_mana_drain_lua:OnDestroy()
	if not IsServer() then return end
	if not self.forceDestroy then
		self:GetAbility():Unregister( self )
	end
	if self.parent:IsIllusion() then
		self.parent:Kill( self:GetAbility(), self:GetCaster() )
	end
end

function modifier_lion_mana_drain_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_lion_mana_drain_lua:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_lion_mana_drain_lua:OnIntervalThink()
	if self.parent:IsMagicImmune() or self.parent:IsInvulnerable() or self.parent:IsIllusion() then
		self:Destroy()
		return
	end
	if not self:GetCaster():IsAlive() then
		self:Destroy()
		return
	end
	if (self:GetParent():GetOrigin()-self:GetCaster():GetOrigin()):Length2D()>self.radius then
		self:Destroy()
		return
	end
	local mana = self:GetParent():GetMana()
	local empty = false
	if mana<self.mana then
		empty = true
		self.mana = mana
	end
	local damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = self.mana,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	self:GetParent():Script_ReduceMana( self.mana, self:GetAbility() )
	self:GetCaster():GiveMana( self.mana )
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		local Talented = self:GetCaster():FindAbilityByName("special_bonus_unique_enigma_6")
		if Talented:GetLevel() == 1 then
			ApplyDamage(damageTable)
		end
	end
	if empty then
		self:Destroy()
	end
end

function modifier_lion_mana_drain_lua:PlayEffects()
	local particle_cast = "particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_mouth",
		Vector(0,0,0),
		true
	)

	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
end