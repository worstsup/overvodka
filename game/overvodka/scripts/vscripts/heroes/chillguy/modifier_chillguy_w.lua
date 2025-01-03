modifier_chillguy_w = class({})

function modifier_chillguy_w:IsHidden()
	return true
end
function modifier_chillguy_w:IsDebuff()
	return false
end
function modifier_chillguy_w:IsPurgable()
	return false
end
function modifier_chillguy_w:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT 
end

function modifier_chillguy_w:OnCreated( kv )
	if not IsServer() then return end
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.manacost = self:GetAbility():GetSpecialValueFor( "mana_cost_per_second" )
	local interval = 1
	-- precache
	self.parent = self:GetParent()
	self.parent:AddNewModifier(self.parent, self:GetAbility(), "modifier_chillguy_w_debuff", {})
	self:Burn()
	self:StartIntervalThink( interval )
	-- play effects
	local sound_loop = "chillguy_music"
	EmitSoundOn( sound_loop, self.parent )
end

function modifier_chillguy_w:OnRefresh( kv )
end

function modifier_chillguy_w:OnRemoved()
end

function modifier_chillguy_w:OnDestroy()
	if not IsServer() then return end
	local sound_loop = "chillguy_music"
	self.parent:RemoveModifierByName("modifier_chillguy_w_debuff")
	StopSoundOn( sound_loop, self.parent )
end

function modifier_chillguy_w:OnIntervalThink()
	-- check mana
	local mana = self.parent:GetMana()
	if mana < self.manacost then
		-- turn off
		if self:GetAbility():GetToggleState() then
			self:GetAbility():ToggleAbility()
		end
		return
	end
	self:Burn()
end

function modifier_chillguy_w:Burn()
	self.parent:SpendMana( self.manacost, self:GetAbility() )
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),	-- int, your team number
		self.parent:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )
	local damage_pct = self:GetAbility():GetSpecialValueFor( "damage_pct" )
	for _,enemy in pairs(enemies) do
		-- apply damage
		local damage_new = damage_pct * enemy:GetMaxHealth() * 0.01 + damage
		self.damageTable = {
			attacker = self:GetParent(),
			damage = damage_new,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(),
		}
		self.damageTable.victim = enemy
		ApplyDamage( self.damageTable )
		self:PlayEffects( enemy )
	end
end

function modifier_chillguy_w:GetEffectName()
	return "particles/treant_eyesintheforest_new.vpcf"
end

function modifier_chillguy_w:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_chillguy_w:PlayEffects( target )
	local particle_cast = "particles/units/heroes/hero_leshrac/leshrac_pulse_nova.vpcf"
	local sound_cast = "Hero_Leshrac.Pulse_Nova_Strike"

	-- radius
	local radius = 100

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, Vector(radius,0,0) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( sound_cast, target )
end
function modifier_chillguy_w:PlayEffects2()
	local particle_cast = "particles/units/heroes/hero_treant/treant_eyesintheforest.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, Vector(self.radius,0,0) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end
