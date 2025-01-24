LinkLuaModifier("modifier_imba_batrider_sticky_napalm_handler", "hero_batrider", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_batrider_sticky_napalm", "hero_batrider", LUA_MODIFIER_MOTION_NONE)

imba_batrider_sticky_napalm						= class({})
modifier_imba_batrider_sticky_napalm_handler		= class({})
modifier_imba_batrider_sticky_napalm				= class({})

function imba_batrider_sticky_napalm:IsStealable()
	return false
end
function imba_batrider_sticky_napalm:GetIntrinsicModifierName()
	return "modifier_imba_batrider_sticky_napalm_handler"
end

function imba_batrider_sticky_napalm:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function imba_batrider_sticky_napalm:OnSpellStart()
	self:GetCaster():EmitSound("Hero_Batrider.StickyNapalm.Cast")
	EmitSoundOnLocationWithCaster(self:GetCursorPosition(), "Hero_Batrider.StickyNapalm.Impact", self:GetCaster())
	
	self.napalm_impact_particle = ParticleManager:CreateParticle("particles/batrider_stickynapalm_impact_new.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(self.napalm_impact_particle, 0, self:GetCursorPosition())
	ParticleManager:SetParticleControl(self.napalm_impact_particle, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))
	ParticleManager:SetParticleControl(self.napalm_impact_particle, 2, self:GetCaster():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(self.napalm_impact_particle)
	self.napalm_impact_particle = nil
	
	self.enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetCursorPosition(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	
	for _, enemy in pairs(self.enemies) do
		enemy:AddNewModifier(self:GetCaster(), self, "modifier_imba_batrider_sticky_napalm", {duration = self:GetSpecialValueFor("duration") * (1 - enemy:GetStatusResistance())})
	end
	AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), 400, 2, false)
	
	self.napalm_impact_particle = nil
	self.enemies				= nil
end


function modifier_imba_batrider_sticky_napalm_handler:IsHidden()	return true end

function modifier_imba_batrider_sticky_napalm_handler:OnIntervalThink()
	if not IsServer() then return end

	if not self:GetCaster():IsHexed() and not self:GetCaster():IsInvisible() and not self:GetCaster():IsNightmared() and not self:GetCaster():IsOutOfGame() and not self:GetCaster():IsSilenced() and not self:GetCaster():IsStunned() and not self:GetCaster():IsChanneling() then
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
		if targets == nil then return end
		if self:GetCaster():IsInvisible() then return end
		for _,unit in pairs(targets) do
			local pointd = unit:GetAbsOrigin()
			break
		end
		self:GetCaster():SetCursorPosition(pointd)
		self:GetAbility():CastAbilityOnPosition(pointd, "imba_batrider_sticky_napalm_new", self:GetCaster():GetPlayerID())
	end
end

function modifier_imba_batrider_sticky_napalm_handler:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_ORDER, MODIFIER_PROPERTY_IGNORE_CAST_ANGLE, MODIFIER_PROPERTY_DISABLE_TURNING}
	
	return decFuncs
end

function modifier_imba_batrider_sticky_napalm_handler:OnOrder(keys)
	if not IsServer() or keys.unit ~= self:GetParent() then return end
	
	if keys.ability == self:GetAbility() then
		if keys.order_type == DOTA_UNIT_ORDER_CAST_POSITION and (keys.new_pos - self:GetCaster():GetAbsOrigin()):Length2D() <= self:GetAbility():GetCastRange(self:GetCaster():GetCursorPosition(), self:GetCaster()) + self:GetCaster():GetCastRangeBonus() then
			self.bActive = true
		else
			self.bActive = false
		end
		
		if keys.order_type == DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO then
			if self:GetAbility():GetAutoCastState() then
				self:SetStackCount(0)
				self:StartIntervalThink(-1)
			else
				self:StartIntervalThink(0.1)
				self:SetStackCount(1)
			end
		end
	else
		self.bActive = false
	end
end

function modifier_imba_batrider_sticky_napalm_handler:GetModifierIgnoreCastAngle()
	if not IsServer() or self.bActive == false then return end
	return 0
end

function modifier_imba_batrider_sticky_napalm_handler:GetModifierDisableTurning()
	if not IsServer() or self.bActive == false then return end
	return 0
end

function modifier_imba_batrider_sticky_napalm:GetEffectName()
	return "particles/units/heroes/hero_batrider/batrider_napalm_damage_debuff.vpcf"
end

function modifier_imba_batrider_sticky_napalm:GetStatusEffectName()
	return "particles/status_fx/status_effect_stickynapalm.vpcf"
end

function modifier_imba_batrider_sticky_napalm:OnCreated()
	self.max_stacks			= self:GetAbility():GetSpecialValueFor("max_stacks")
	self.movement_speed_pct	= self:GetAbility():GetSpecialValueFor("movement_speed_pct")
	self.turn_rate_pct		= self:GetAbility():GetSpecialValueFor("turn_rate_pct")
	self.damage				= self:GetAbility():GetSpecialValueFor("damage")
	
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
		["imba_batrider_sticky_napalm"] = true,
		
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

function modifier_imba_batrider_sticky_napalm:OnRefresh()
	self.max_stacks			= self:GetAbility():GetSpecialValueFor("max_stacks")
	self.movement_speed_pct	= self:GetAbility():GetSpecialValueFor("movement_speed_pct")
	self.turn_rate_pct		= self:GetAbility():GetSpecialValueFor("turn_rate_pct")
	self.damage				= self:GetAbility():GetSpecialValueFor("damage")

	if not IsServer() then return end

	if self:GetStackCount() < self.max_stacks then
		self:IncrementStackCount()
	end
	
	if self.stack_particle then
		ParticleManager:SetParticleControl(self.stack_particle, 1, Vector(math.floor(self:GetStackCount() / 10), self:GetStackCount() % 10, 0))
	end
end

function modifier_imba_batrider_sticky_napalm:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE, MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_imba_batrider_sticky_napalm:GetModifierMoveSpeedBonus_Percentage()
	return math.min(self:GetStackCount(), self.max_stacks) * self.movement_speed_pct
end

function modifier_imba_batrider_sticky_napalm:GetModifierTurnRate_Percentage()
	return self.turn_rate_pct
end

function modifier_imba_batrider_sticky_napalm:OnTakeDamage(keys)
	if keys.attacker == self:GetCaster() and keys.unit == self:GetParent() and (not keys.inflictor or not self.non_trigger_inflictors[keys.inflictor:GetName()]) and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
		self.damage_debuff_particle = ParticleManager:CreateParticle("particles/batrider_napalm_damage_debuff_new.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:ReleaseParticleIndex(self.damage_debuff_particle)
		self.damage_debuff_particle = nil
		
		-- The wikis don't say anything about creep-heroes so I'll just assume they'll be treated as creeps
		if self:GetParent():IsHero() then
			self.damage_table.damage = self.damage * self:GetStackCount()
		else
			self.damage_table.damage = self.damage * 0.5 * self:GetStackCount()
		end
		
		ApplyDamage(self.damage_table)
	end
end