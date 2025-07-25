item_obossal_blade = item_obossal_blade or class({})

LinkLuaModifier("modifier_item_obossal_blade", "items/obossal_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_obossal_blade_internal_cd", "items/obossal_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_obossal_blade_bash", "items/obossal_blade", LUA_MODIFIER_MOTION_NONE)

function item_obossal_blade:GetIntrinsicModifierName()
	return "modifier_item_obossal_blade"
end

function item_obossal_blade:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local target = self:GetCursorTarget()
	local sound_cast = "DOTA_Item.AbyssalBlade.Activate"    
	local particle_abyssal = "particles/items_fx/abyssal_blade.vpcf"
	local modifier_bash = "modifier_item_obossal_blade_bash"
	local active_stun_duration = ability:GetSpecialValueFor("stun_duration")
	EmitSoundOn(sound_cast, target)
	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
		if target:TriggerSpellAbsorb(ability) then
			return nil
		end
	end
	local blink_start_particle = ParticleManager:CreateParticle("particles/econ/events/ti10/blink_dagger_start_ti10_lvl2.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:ReleaseParticleIndex(blink_start_particle)
	
	FindClearSpaceForUnit(self:GetCaster(), target:GetAbsOrigin() - self:GetCaster():GetForwardVector() * 56, false)
	
	local blink_end_particle = ParticleManager:CreateParticle("particles/econ/events/ti10/blink_dagger_end_ti10_lvl2.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:ReleaseParticleIndex(blink_end_particle)

	local particle_abyssal_fx = ParticleManager:CreateParticle(particle_abyssal, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle_abyssal_fx, 0, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_abyssal_fx)
	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = self:GetSpecialValueFor("bash_damage"),
		damage_type = DAMAGE_TYPE_PHYSICAL,
		ability = self
	}
	ApplyDamage(damageTable)
	if target and not target:IsNull() then
		if target:IsAlive() then
			target:AddNewModifier(caster, ability, modifier_bash, {duration = active_stun_duration * (1 - target:GetStatusResistance())})
		end
	end
end


modifier_item_obossal_blade = modifier_item_obossal_blade or class({})

function modifier_item_obossal_blade:IsHidden()			return true end
function modifier_item_obossal_blade:IsPurgable()		return false end
function modifier_item_obossal_blade:RemoveOnDeath()	return false end
function modifier_item_obossal_blade:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_obossal_blade:OnCreated()
	if not IsServer() then return end
	self.mod = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_vindicators_axe", {})
end

function modifier_item_obossal_blade:OnDestroy()
	if not IsServer() then
		return
	end
	if self.mod then
		self.mod:Destroy()
	end
end

function modifier_item_obossal_blade:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL
	}
end

function modifier_item_obossal_blade:GetModifierBonusStats_Strength()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_strength")
	end
end

function modifier_item_obossal_blade:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_damage")
	end
end

function modifier_item_obossal_blade:GetModifierHealthBonus()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_health")
	end
end

function modifier_item_obossal_blade:GetModifierHPRegenAmplify_Percentage()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("hp_regen_amp")
	end
end

function modifier_item_obossal_blade:OnAttack(keys)
	if self:GetAbility() and
	keys.attacker == self:GetParent() and
	keys.attacker:FindAllModifiersByName(self:GetName())[1] == self and
	not keys.attacker:IsIllusion() and
	not keys.target:IsBuilding() and
	not keys.target:IsOther() and
	not keys.attacker:HasModifier("modifier_item_obossal_blade_internal_cd") then
		if self:GetParent():IsRangedAttacker() then
			if RollPseudoRandom(self:GetAbility():GetSpecialValueFor("bash_chance_ranged"), self) then
				self.bash_proc = true
			end
		else
			if RollPseudoRandom(self:GetAbility():GetSpecialValueFor("bash_chance_melee"), self) then
				self.bash_proc = true
			end
		end
	end
end

function modifier_item_obossal_blade:OnAttackLanded(keys)
	if self:GetAbility() and keys.attacker == self:GetParent() and self.bash_proc then
		self.bash_proc = false
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_obossal_blade_internal_cd", {duration = self:GetAbility():GetSpecialValueFor("bash_cooldown")})
		if OVERVODKA_DISABLED_EBASHER == nil or not OVERVODKA_DISABLED_EBASHER[keys.attacker:GetUnitName()] then
			keys.target:EmitSound("DOTA_Item.SkullBasher")
			keys.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_obossal_blade_bash", {duration = self:GetAbility():GetSpecialValueFor("bash_duration") * (1 - keys.target:GetStatusResistance())})
		end
	end
end

function modifier_item_obossal_blade:GetModifierProcAttack_BonusDamage_Physical()
	if self:GetAbility() and self.bash_proc then
		return self:GetAbility():GetSpecialValueFor("bonus_chance_damage")
	end
end

modifier_item_obossal_blade_bash = modifier_item_obossal_blade_bash or class({})

function modifier_item_obossal_blade_bash:IsHidden() return false end
function modifier_item_obossal_blade_bash:IsPurgeException() return true end
function modifier_item_obossal_blade_bash:IsStunDebuff() return true end

function modifier_item_obossal_blade_bash:CheckState()
   return {[MODIFIER_STATE_STUNNED] = true} 
end

function modifier_item_obossal_blade_bash:GetEffectName()
	return "particles/generic_gameplay/generic_bashed.vpcf"
end

function modifier_item_obossal_blade_bash:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_item_obossal_blade_bash:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_item_obossal_blade_bash:GetOverrideAnimation()
	return ACT_DOTA_DISABLED 
end

modifier_item_obossal_blade_internal_cd = modifier_item_obossal_blade_internal_cd or class({})

function modifier_item_obossal_blade_internal_cd:IgnoreTenacity()	return true end
function modifier_item_obossal_blade_internal_cd:IsPurgable() 		return false end
function modifier_item_obossal_blade_internal_cd:IsDebuff() 		return true end
function modifier_item_obossal_blade_internal_cd:RemoveOnDeath()	return false end
