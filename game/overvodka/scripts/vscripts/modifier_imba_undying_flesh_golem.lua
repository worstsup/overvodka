modifier_imba_undying_flesh_golem = modifier_imba_undying_flesh_golem or class({})

function modifier_imba_undying_flesh_golem:GetEffectName()
	return "particles/units/heroes/hero_undying/undying_fg_aura.vpcf"
end

function modifier_imba_undying_flesh_golem:OnCreated()
	self.slow           = self:GetAbility():GetSpecialValueFor("slow")
	self.damage         = self:GetAbility():GetSpecialValueFor("damage")
	self.slow_duration  = self:GetAbility():GetSpecialValueFor("slow_duration")
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		self.str_percentage = self:GetAbility():GetOrbSpecialValueFor( "str_percentage", "e")
		self.duration       = self:GetAbility():GetOrbSpecialValueFor( "duration", "w" )
	else
		self.str_percentage = 100
		self.duration       = 17
	end
	self.spawn_rate     = self:GetAbility():GetSpecialValueFor("spawn_rate")
	self.zombie_radius  = self:GetAbility():GetSpecialValueFor("zombie_radius")
	self.movement_bonus = self:GetAbility():GetSpecialValueFor("movement_bonus")
	self.zombie_multiplier  = self:GetAbility():GetSpecialValueFor("zombie_multiplier")
	self.remnants_aura_radius   = self:GetAbility():GetSpecialValueFor("remnants_aura_radius")
	
	if not IsServer() then return end
	
	if self:GetParent():HasAbility("imba_undying_flesh_golem_grab") then
		self:GetParent():FindAbilityByName("imba_undying_flesh_golem_grab"):SetActivated(true)
	end
	
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
	
	if self:GetParent():HasAbility("imba_undying_flesh_golem_grab") then
		self:GetParent():FindAbilityByName("imba_undying_flesh_golem_grab"):SetActivated(false)
	end
	
	if self:GetParent():HasAbility("imba_undying_flesh_golem_throw") and self:GetParent():FindAbilityByName("imba_undying_flesh_golem_throw"):IsActivated() then
		self:GetParent():FindAbilityByName("imba_undying_flesh_golem_throw"):SetActivated(false)
		self:GetParent():SwapAbilities("imba_undying_flesh_golem_grab", "imba_undying_flesh_golem_throw", true, false)
	end
end

function modifier_imba_undying_flesh_golem:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		-- MODIFIER_PROPERTY_STATS_STRENGTH_BONUS_PERCENTAGE, -- Yeah this still doesn't work
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MODEL_CHANGE,        
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TOOLTIP,
		-- IMBAfications: Remnants of Flesh Golem
		MODIFIER_EVENT_ON_DEATH
	}
end

function modifier_imba_undying_flesh_golem:OnTooltip()
	return self.str_percentage
end

function modifier_imba_undying_flesh_golem:GetModifierMoveSpeedBonus_Constant()
	return self.movement_bonus
end

function modifier_imba_undying_flesh_golem:GetModifierBonusStats_Strength()
	return self.strength
end

function modifier_imba_undying_flesh_golem:GetModifierModelChange()
	return "models/heroes/undying/undying_flesh_golem.vmdl"
end

-- This can affect allied units
function modifier_imba_undying_flesh_golem:OnAttackLanded(keys)
	if keys.attacker == self:GetParent() and not keys.target:IsBuilding() and not keys.target:IsOther() then
		keys.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_undying_flesh_golem_slow", {
			duration    = self.slow_duration * (1 - keys.target:GetStatusResistance()),
			slow        = self.slow,
			damage      = self.damage,
			zombie_multiplier   = self.zombie_multiplier
		})
	end
end

-- This isn't removed by default or something if I give it the Flesh Golem model?...
function modifier_imba_undying_flesh_golem:OnDeath(keys)
	-- "Flesh Golem is fully canceled on death."
	-- "Rubick stays in Flesh Golem form even after death." -- WTF
	if keys.unit == self:GetParent() and (not self:GetAbility() or not self:GetAbility():IsStolen()) then
		self:Destroy()
	end
end

-- Auras are not purged or removed on death? Setting IsPurgable and RemoveOnDeath flags seems to make no difference
function modifier_imba_undying_flesh_golem:IsAura()                         return true end
function modifier_imba_undying_flesh_golem:IsAuraActiveOnDeath()            return false end

function modifier_imba_undying_flesh_golem:GetAuraRadius()                  return self.remnants_aura_radius end
function modifier_imba_undying_flesh_golem:GetAuraSearchFlags()             return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_undying_flesh_golem:GetAuraSearchTeam()              return DOTA_UNIT_TARGET_TEAM_BOTH end
function modifier_imba_undying_flesh_golem:GetAuraSearchType()              return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_imba_undying_flesh_golem:GetModifierAura()                return "modifier_imba_undying_flesh_golem_plague_aura" end