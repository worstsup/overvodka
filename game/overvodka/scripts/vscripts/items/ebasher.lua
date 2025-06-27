item_ebasher = item_ebasher or class({})

LinkLuaModifier("modifier_item_ebasher", "items/ebasher", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_ebasher_bash", "items/ebasher", LUA_MODIFIER_MOTION_NONE)

function item_ebasher:GetIntrinsicModifierName()
	return "modifier_item_ebasher"
end

modifier_item_ebasher = modifier_item_ebasher or class({})

function modifier_item_ebasher:IsHidden() return true end
function modifier_item_ebasher:IsPurgable() return false end
function modifier_item_ebasher:RemoveOnDeath() return false end
function modifier_item_ebasher:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_ebasher:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL
	}
end

function modifier_item_ebasher:GetModifierBonusStats_Strength()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_strength")
	end
end

function modifier_item_ebasher:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_damage")
	end
end

function modifier_item_ebasher:OnAttack(keys)
	if self:GetAbility() and
	keys.attacker == self:GetParent() and
	keys.attacker:FindAllModifiersByName(self:GetName())[1] == self and
	self:GetAbility():IsCooldownReady() and
	not keys.attacker:IsIllusion() and
	not keys.target:IsBuilding() and
	not keys.target:IsOther() and
	not keys.attacker:HasItemInInventory("item_obossal_blade") then
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

function modifier_item_ebasher:OnAttackLanded(keys)
	if self:GetAbility() and keys.attacker == self:GetParent() and self.bash_proc then
		self.bash_proc = false
		self:GetAbility():UseResources(false, false, false, true)
		if OVERVODKA_DISABLED_EBASHER == nil or not OVERVODKA_DISABLED_EBASHER[keys.attacker:GetUnitName()] then
			keys.target:EmitSound("DOTA_Item.SkullBasher")
			keys.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_ebasher_bash", {duration = self:GetAbility():GetSpecialValueFor("bash_duration") * (1 - keys.target:GetStatusResistance())})
		end
	end
end

function modifier_item_ebasher:GetModifierProcAttack_BonusDamage_Physical()
	if self:GetAbility() and self.bash_proc then
		return self:GetAbility():GetSpecialValueFor("bonus_chance_damage")
	end
end

modifier_item_ebasher_bash = modifier_item_ebasher_bash or class({})

function modifier_item_ebasher_bash:IsHidden() return false end
function modifier_item_ebasher_bash:IsPurgeException() return true end
function modifier_item_ebasher_bash:IsStunDebuff() return true end

function modifier_item_ebasher_bash:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true
	}
end

function modifier_item_ebasher_bash:GetEffectName()
	return "particles/generic_gameplay/generic_bashed.vpcf"
end

function modifier_item_ebasher_bash:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_item_ebasher_bash:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
end

function modifier_item_ebasher_bash:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end