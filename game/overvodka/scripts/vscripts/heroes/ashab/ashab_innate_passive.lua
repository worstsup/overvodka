LinkLuaModifier("modifier_ashab_innate_handler", "heroes/ashab/ashab_innate_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ashab_innate", "heroes/ashab/ashab_innate_passive", LUA_MODIFIER_MOTION_NONE)

ashab_innate						= class({})
modifier_ashab_innate_handler		= class({})
modifier_ashab_innate				= class({})

function ashab_innate:IsStealable()
	return false
end
function ashab_innate:ProcsMagicStick() return false end

function ashab_innate:GetIntrinsicModifierName()
	return "modifier_ashab_innate_handler"
end

function ashab_innate:OnSpellStart()
	self:GetCaster():EmitSound("Hero_Batrider.StickyNapalm.Cast")
	
	self.napalm_impact_particle = ParticleManager:CreateParticle("particles/batrider_stickynapalm_impact_new.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(self.napalm_impact_particle, 0, self:GetCursorPosition())
	ParticleManager:SetParticleControl(self.napalm_impact_particle, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))
	ParticleManager:SetParticleControl(self.napalm_impact_particle, 2, self:GetCaster():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(self.napalm_impact_particle)
	self.napalm_impact_particle = nil
	
	self.enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetCursorPosition(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	
	for _, enemy in pairs(self.enemies) do
		enemy:AddNewModifier(self:GetCaster(), self, "modifier_ashab_innate", {duration = self:GetSpecialValueFor("duration") * (1 - enemy:GetStatusResistance())})
	end
	AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), 400, 2, false)
	
	self.napalm_impact_particle = nil
	self.enemies				= nil
end


function modifier_ashab_innate_handler:IsHidden()	return true end

function modifier_ashab_innate_handler:OnIntervalThink()
	if not IsServer() then return end

	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if not caster or caster:IsNull() then return end
	if not ability or ability:IsNull() then return end
	if caster:PassivesDisabled() then return end

	if not caster:IsAlive() or not ability:IsFullyCastable() or ability:IsInAbilityPhase() then return end
	if caster:IsHexed() or caster:IsIllusion() or caster:IsInvisible() or caster:IsNightmared() or caster:IsOutOfGame() or caster:IsSilenced() or caster:IsStunned() or caster:IsChanneling() then
		return
	end

	local targets = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		600,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
		FIND_CLOSEST,
		false
	)

	if not targets or #targets == 0 then return end

	local point = targets[1]:GetAbsOrigin()
	caster:SetCursorPosition(point)
	ability:OnSpellStart()
	ability:UseResources(false, false, false, true)

	if RandomInt(1, 2) == 1 then
		EmitSoundOn("mohito_1", caster)
	else
		EmitSoundOn("mohito_2", caster)
	end

	EmitSoundOnLocationWithCaster(point, "Hero_Batrider.StickyNapalm.Impact", caster)
end


function modifier_ashab_innate_handler:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
end

function modifier_ashab_innate_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_IGNORE_CAST_ANGLE, MODIFIER_PROPERTY_DISABLE_TURNING}
end

function modifier_ashab_innate_handler:GetModifierIgnoreCastAngle()
	if not IsServer() or self.bActive == false then return end
	return 0
end

function modifier_ashab_innate_handler:GetModifierDisableTurning()
	if not IsServer() or self.bActive == false then return end
	return 0
end

function modifier_ashab_innate:GetEffectName()
	return "particles/units/heroes/hero_batrider/batrider_napalm_damage_debuff.vpcf"
end

function modifier_ashab_innate:GetStatusEffectName()
	return "particles/status_fx/status_effect_stickynapalm.vpcf"
end

function modifier_ashab_innate:OnCreated()
	self.max_stacks			= self:GetAbility():GetSpecialValueFor("max_stacks")
	self.movement_speed_pct	= self:GetAbility():GetSpecialValueFor("movement_speed_pct")
	self.turn_rate_pct		= self:GetAbility():GetSpecialValueFor("turn_rate_pct")
	self.damage				= self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():GetLevel() * self:GetAbility():GetSpecialValueFor("damage_per_level")
	
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
		["ashab_innate"] = true,
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

function modifier_ashab_innate:OnRefresh()
	self.max_stacks			= self:GetAbility():GetSpecialValueFor("max_stacks")
	self.movement_speed_pct	= self:GetAbility():GetSpecialValueFor("movement_speed_pct")
	self.turn_rate_pct		= self:GetAbility():GetSpecialValueFor("turn_rate_pct")
	self.damage				= self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():GetLevel() * self:GetAbility():GetSpecialValueFor("damage_per_level")

	if not IsServer() then return end

	if self:GetStackCount() < self.max_stacks then
		self:IncrementStackCount()
	end
	
	if self.stack_particle then
		ParticleManager:SetParticleControl(self.stack_particle, 1, Vector(math.floor(self:GetStackCount() / 10), self:GetStackCount() % 10, 0))
	end
end

function modifier_ashab_innate:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE, MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_ashab_innate:GetModifierMoveSpeedBonus_Percentage()
	return math.min(self:GetStackCount(), self.max_stacks) * self.movement_speed_pct
end

function modifier_ashab_innate:GetModifierTurnRate_Percentage()
	return self.turn_rate_pct
end

function modifier_ashab_innate:OnTakeDamage(keys)
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