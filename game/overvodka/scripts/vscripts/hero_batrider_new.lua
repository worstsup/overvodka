
LinkLuaModifier("modifier_imba_batrider_sticky_napalm_handler_new", "hero_batrider_new", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_batrider_sticky_napalm_new", "hero_batrider_new", LUA_MODIFIER_MOTION_NONE)

imba_batrider_sticky_napalm_new							= class({})
modifier_imba_batrider_sticky_napalm_handler_new		= class({})
modifier_imba_batrider_sticky_napalm_new				= class({})

function imba_batrider_sticky_napalm_new:IsStealable()
	return false
end
function imba_batrider_sticky_napalm_new:GetIntrinsicModifierName()
	return "modifier_imba_batrider_sticky_napalm_handler_new"
end

function imba_batrider_sticky_napalm_new:GetAOERadius()
	return 375
end

function imba_batrider_sticky_napalm_new:OnSpellStart()
	self:GetCaster():EmitSound("Hero_Batrider.StickyNapalm.Cast")
	EmitSoundOnLocationWithCaster(self:GetCursorPosition(), "Hero_Batrider.StickyNapalm.Impact", self:GetCaster())
	
	self.napalm_impact_particle = ParticleManager:CreateParticle("particles/batrider_stickynapalm_impact_new.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(self.napalm_impact_particle, 0, self:GetCursorPosition())
	ParticleManager:SetParticleControl(self.napalm_impact_particle, 1, Vector(375, 0, 0))
	ParticleManager:SetParticleControl(self.napalm_impact_particle, 2, self:GetCaster():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(self.napalm_impact_particle)
	self.napalm_impact_particle = nil
	
	self.enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetCursorPosition(), nil, 375, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	
	for _, enemy in pairs(self.enemies) do
		enemy:AddNewModifier(self:GetCaster(), self, "modifier_imba_batrider_sticky_napalm_new", {duration = 6 * (1 - enemy:GetStatusResistance())})
	end
	
	AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), 400, 2, false)
	
	self.napalm_impact_particle = nil
	self.enemies				= nil
end


function modifier_imba_batrider_sticky_napalm_handler_new:IsHidden()	return true end

function modifier_imba_batrider_sticky_napalm_handler_new:OnIntervalThink()
	if not IsServer() then return end
	if self:GetCaster():PassivesDisabled() then return end
	if self:GetCaster():IsAlive() and self:GetAbility():IsFullyCastable() and not self:GetAbility():IsInAbilityPhase() and not self:GetCaster():IsInvisible() and not self:GetCaster():IsHexed() and not self:GetCaster():IsNightmared() and not self:GetCaster():IsIllusion() and not self:GetCaster():IsOutOfGame() and not self:GetCaster():IsSilenced() and not self:GetCaster():IsStunned() and not self:GetCaster():IsChanneling() then
		local targets = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			self:GetCaster():GetAbsOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			600,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,	-- int, flag filter
			FIND_CLOSEST,	-- int, order filter
			false	-- bool, can grow cache
		)
		if #targets == 0 then return end
		for _,unit in pairs(targets) do
			self:GetCaster():SetCursorPosition(unit:GetAbsOrigin())
			break
		end
		self:GetAbility():CastAbility()
		self:GetCaster():FindAbilityByName("imba_batrider_sticky_napalm"):UseResources(false, false, false, true)
		local random_chance = RandomInt(1, 2)
		if random_chance == 1 then
			EmitSoundOn("mohito_1", self:GetCaster())
		else
			EmitSoundOn("mohito_2", self:GetCaster())
		end
	end
end

function modifier_imba_batrider_sticky_napalm_handler_new:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_IGNORE_CAST_ANGLE, MODIFIER_PROPERTY_DISABLE_TURNING}
	
	return decFuncs
end

function modifier_imba_batrider_sticky_napalm_handler_new:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
end

function modifier_imba_batrider_sticky_napalm_handler_new:GetModifierIgnoreCastAngle()
	if not IsServer() or self.bActive == false then return end
	return 0
end

function modifier_imba_batrider_sticky_napalm_handler_new:GetModifierDisableTurning()
	if not IsServer() or self.bActive == false then return end
	return 0
end

function modifier_imba_batrider_sticky_napalm_new:GetEffectName()
	return "particles/units/heroes/hero_batrider/batrider_napalm_damage_debuff.vpcf"
end

function modifier_imba_batrider_sticky_napalm_new:GetStatusEffectName()
	return "particles/status_fx/status_effect_stickynapalm.vpcf"
end

function modifier_imba_batrider_sticky_napalm_new:OnCreated()
	self.max_stacks			= 6
	self.movement_speed_pct	= -3
	self.turn_rate_pct		= -40
	self.damage				= 10 + self:GetCaster():GetLevel() * 2
	
	if not IsServer() then return end
	
	self.damage_table = {
		victim 			= self:GetParent(),
		damage 			= nil,
		damage_type		= DAMAGE_TYPE_MAGICAL,
		damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
		attacker 		= self:GetCaster(),
		ability 		= self:GetAbility()
	}
	
	self.non_trigger_inflictors = {
		["imba_batrider_sticky_napalm_new"] = true,
		
		["item_imba_cloak_of_flames"]	= true,
		["item_imba_radiance"]			= true,
		
		["item_imba_urn_of_shadows"]	= true,
		["item_imba_spirit_vessel"]		= true,
	}
	
	self:SetStackCount(1)
	
	self.stack_particle = ParticleManager:CreateParticleForTeam("particles/batrider_stickynapalm_stack_new.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber())
	ParticleManager:SetParticleControl(self.stack_particle, 1, Vector(math.floor(self:GetStackCount() / 10), self:GetStackCount() % 10, 0))
	self:AddParticle(self.stack_particle, false, false, -1, false, false)
end

function modifier_imba_batrider_sticky_napalm_new:OnRefresh()
	self.max_stacks			= 6
	self.movement_speed_pct	= -3
	self.turn_rate_pct		= -40
	self.damage				= 10 + self:GetCaster():GetLevel() * 2

	if not IsServer() then return end

	if self:GetStackCount() < self.max_stacks then
		self:IncrementStackCount()
	end
	
	if self.stack_particle then
		ParticleManager:SetParticleControl(self.stack_particle, 1, Vector(math.floor(self:GetStackCount() / 10), self:GetStackCount() % 10, 0))
	end
end

function modifier_imba_batrider_sticky_napalm_new:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE, MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_imba_batrider_sticky_napalm_new:GetModifierMoveSpeedBonus_Percentage()
	return math.min(self:GetStackCount(), self.max_stacks) * self.movement_speed_pct
end

function modifier_imba_batrider_sticky_napalm_new:GetModifierTurnRate_Percentage()
	return self.turn_rate_pct
end

function modifier_imba_batrider_sticky_napalm_new:OnTakeDamage(keys)
	if keys.attacker == self:GetCaster() and keys.unit == self:GetParent() and (not keys.inflictor or not self.non_trigger_inflictors[keys.inflictor:GetName()]) and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
		self.damage_debuff_particle = ParticleManager:CreateParticle("particles/batrider_napalm_damage_debuff_new.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:ReleaseParticleIndex(self.damage_debuff_particle)
		self.damage_debuff_particle = nil
		
		if self:GetParent():IsHero() then
			self.damage_table.damage = self.damage * self:GetStackCount()
		else
			self.damage_table.damage = self.damage * 0.5 * self:GetStackCount()
		end
		
		ApplyDamage(self.damage_table)
	end
end