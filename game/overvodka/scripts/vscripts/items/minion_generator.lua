LinkLuaModifier("modifier_item_minion_generator", "items/minion_generator", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_minion_generator_aura_buff", "items/minion_generator", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_minion_generator_aura_buff_armor", "items/minion_generator", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_minion_generator_aura_debuff", "items/minion_generator", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_minion_generator_aura_debuff_armor", "items/minion_generator", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_minion_generator_minion_as", "items/minion_generator", LUA_MODIFIER_MOTION_NONE)

item_minion_generator = class({})

function item_minion_generator:GetIntrinsicModifierName()
    return "modifier_item_minion_generator"
end

function item_minion_generator:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target_point = self:GetCursorPosition()
	EmitSoundOnLocationWithCaster(target_point, "minion_generator_spawn", caster)
    local spawned_unit = CreateUnitByName("npc_dota_neutral_harpy_scout", target_point, true, caster, caster, caster:GetTeamNumber())
    if spawned_unit then
		spawned_unit:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
		spawned_unit:AddNewModifier(caster, self, "modifier_kill", {duration = self:GetSpecialValueFor("minion_duration")})
        spawned_unit:AddNewModifier(caster, self, "modifier_item_minion_generator_minion_as", {})
		spawned_unit:SetMinimumGoldBounty(100)
		spawned_unit:SetMaximumGoldBounty(100)
		spawned_unit:SetDeathXP(300)
		local particle = ParticleManager:CreateParticle("particles/minion_generator_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, spawned_unit)
		ParticleManager:SetParticleControl(particle, 0, spawned_unit:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle, 3, spawned_unit:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle)
		spawned_unit:EmitSound("minion_generator_minion")
    end
end

modifier_item_minion_generator_minion_as = class({})

function modifier_item_minion_generator_minion_as:IsHidden() return true end
function modifier_item_minion_generator_minion_as:IsPurgable() return false end
function modifier_item_minion_generator_minion_as:RemoveOnDeath() return false end

function modifier_item_minion_generator_minion_as:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_item_minion_generator_minion_as:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_attack_speed_minion")
    end
    return 0
end

function modifier_item_minion_generator_minion_as:GetModifierMoveSpeedBonus_Percentage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_movespeed_minion")
    end
    return 0
end

modifier_item_minion_generator = class({})

function modifier_item_minion_generator:IsHidden() return true end
function modifier_item_minion_generator:IsPurgable() return false end
function modifier_item_minion_generator:IsPurgeException() return false end
function modifier_item_minion_generator:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_minion_generator:OnCreated()
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_item_minion_generator_aura_buff") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_minion_generator_aura_buff", {})
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_minion_generator_aura_debuff", {})
	end
end

function modifier_item_minion_generator:OnDestroy()
	if IsServer() then
		if not self:GetCaster():HasModifier("modifier_item_minion_generator") then
			self:GetCaster():RemoveModifierByName("modifier_item_minion_generator_aura_buff")
			self:GetCaster():RemoveModifierByName("modifier_item_minion_generator_aura_debuff")
		end
	end
end

function modifier_item_minion_generator:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
end

function modifier_item_minion_generator:GetModifierPhysicalArmorBonus()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_armor_stats')
end

function modifier_item_minion_generator:GetModifierAttackSpeedBonus_Constant()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_attack_speed_stats')
end

function modifier_item_minion_generator:GetModifierConstantHealthRegen()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_hp_regen')
end

function modifier_item_minion_generator:GetModifierBonusStats_Strength()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_all_stats')
end
function modifier_item_minion_generator:GetModifierBonusStats_Agility()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_all_stats')
end
function modifier_item_minion_generator:GetModifierBonusStats_Intellect()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_all_stats')
end

modifier_item_minion_generator_aura_buff = class({})

function modifier_item_minion_generator_aura_buff:IsDebuff() return false end
function modifier_item_minion_generator_aura_buff:AllowIllusionDuplicate() return true end
function modifier_item_minion_generator_aura_buff:IsHidden() return true end
function modifier_item_minion_generator_aura_buff:IsPurgable() return false end

function modifier_item_minion_generator_aura_buff:GetAuraRadius()
	return 1200
end

function modifier_item_minion_generator_aura_buff:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_minion_generator_aura_buff:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_minion_generator_aura_buff:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING
end

function modifier_item_minion_generator_aura_buff:GetModifierAura()
	return "modifier_item_minion_generator_aura_buff_armor"
end

function modifier_item_minion_generator_aura_buff:IsAura()
	return true
end

modifier_item_minion_generator_aura_buff_armor = class({})

function modifier_item_minion_generator_aura_buff_armor:GetTexture()
  	return "items/cuiras"
end

function modifier_item_minion_generator_aura_buff_armor:OnCreated()
	self.aura_as_ally = self:GetAbility():GetSpecialValueFor("bonus_attack_speed_aura")
	self.aura_armor_ally = self:GetAbility():GetSpecialValueFor("bonus_armor_aura")
end

function modifier_item_minion_generator_aura_buff_armor:IsHidden() return false end
function modifier_item_minion_generator_aura_buff_armor:IsPurgable() return false end
function modifier_item_minion_generator_aura_buff_armor:IsDebuff() return false end

function modifier_item_minion_generator_aura_buff_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end

function modifier_item_minion_generator_aura_buff_armor:GetModifierAttackSpeedBonus_Constant()
	return self.aura_as_ally
end

function modifier_item_minion_generator_aura_buff_armor:GetModifierPhysicalArmorBonus()
	return self.aura_armor_ally
end

function modifier_item_minion_generator_aura_buff_armor:GetEffectName()
	return "particles/minion_generator_aura.vpcf"
end

function modifier_item_minion_generator_aura_buff_armor:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

modifier_item_minion_generator_aura_debuff = class({})

function modifier_item_minion_generator_aura_debuff:IsDebuff() return false end
function modifier_item_minion_generator_aura_debuff:AllowIllusionDuplicate() return true end
function modifier_item_minion_generator_aura_debuff:IsHidden() return true end
function modifier_item_minion_generator_aura_debuff:IsPurgable() return false end

function modifier_item_minion_generator_aura_debuff:GetAuraRadius()
	return 1200
end

function modifier_item_minion_generator_aura_debuff:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_item_minion_generator_aura_debuff:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_minion_generator_aura_debuff:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING
end

function modifier_item_minion_generator_aura_debuff:GetModifierAura()
	return "modifier_item_minion_generator_aura_debuff_armor"
end

function modifier_item_minion_generator_aura_debuff:IsAura()
	return true
end

modifier_item_minion_generator_aura_debuff_armor = class({})

function modifier_item_minion_generator_aura_debuff_armor:GetTexture()
  	return "items/cuiras"
end

function modifier_item_minion_generator_aura_debuff_armor:OnCreated()
	self.aura_armor_enemy = self:GetAbility():GetSpecialValueFor("minus_armor_aura")
end

function modifier_item_minion_generator_aura_debuff_armor:IsHidden() return false end
function modifier_item_minion_generator_aura_debuff_armor:IsPurgable() return false end
function modifier_item_minion_generator_aura_debuff_armor:IsDebuff() return true end

function modifier_item_minion_generator_aura_debuff_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end

function modifier_item_minion_generator_aura_debuff_armor:GetModifierPhysicalArmorBonus()
	return self.aura_armor_enemy
end
